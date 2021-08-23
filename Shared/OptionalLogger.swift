// Copyright Neeva. All rights reserved.

import Combine
import Defaults
import Foundation
import XCGLogger

/// Extends RollingFileLogger to provide support for optionally enabling
/// logging. Logging is controlled by a Defaults key as well as Defaults
/// for whether or not to enable console and/or file output.
public class OptionalLogger: RollingFileLogger {
    private var subscriptions: Set<AnyCancellable> = []
    private let key: Defaults.Key<Bool>

    init(key: Defaults.Key<Bool>, filenameRoot: String, logDirectoryPath: String?) {
        self.key = key

        super.init(
            filenameRoot: filenameRoot, logDirectoryPath: logDirectoryPath,
            includeDefaultDestinations: false)

        // Note, this only notifies us when there is a change in defaults, so we
        // still need to call `configure` manually.
        Defaults.publisher(key).combineLatest(
            Defaults.publisher(.enableLogToConsole),
            Defaults.publisher(.enableLogToFile)
        ).sink { [weak self] _ in
            self?.configure()
        }.store(in: &subscriptions)

        configure()
    }

    private func configure() {
        if Defaults[key] {
            // Configure output to console
            let consoleId = XCGLogger.Constants.baseConsoleDestinationIdentifier
            if Defaults[.enableLogToConsole] {
                if destination(withIdentifier: consoleId) == nil {
                    add(destination: ConsoleDestination(identifier: consoleId))
                }
            } else {
                remove(destinationWithIdentifier: consoleId)
            }

            // Configure output to file
            if Defaults[.enableLogToFile] {
                if destination(withIdentifier: fileLogIdentifier) == nil {
                    if let fileDestination = createFileDestination(date: Date()) {
                        add(destination: fileDestination)
                        // Limit number of files created.
                        deleteOldLogsDownToSizeLimit()
                    }
                }
            } else {
                remove(destinationWithIdentifier: fileLogIdentifier)
            }
        } else {
            for destination in destinations {
                remove(destination: destination)
            }
        }
    }
}
