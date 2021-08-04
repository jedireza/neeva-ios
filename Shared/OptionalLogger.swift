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

    init(key: Defaults.Key<Bool>, filenameRoot: String, logDirectoryPath: String?) {
        super.init(
            filenameRoot: filenameRoot, logDirectoryPath: logDirectoryPath,
            includeDefaultDestinations: false)

        Defaults.publisher(key).map(\.newValue).combineLatest(
            Defaults.publisher(.enableLogToConsole).map(\.newValue),
            Defaults.publisher(.enableLogToFile).map(\.newValue)
        ).sink { [weak self] (enable, logToConsole, logToFile) in
            self?.configure(enable: enable, logToConsole: logToConsole, logToFile: logToFile)
        }.store(in: &subscriptions)
    }

    private func configure(enable: Bool, logToConsole: Bool, logToFile: Bool) {
        if enable {
            // Configure output to console
            let consoleId = XCGLogger.Constants.baseConsoleDestinationIdentifier
            if logToConsole {
                if destination(withIdentifier: consoleId) == nil {
                    add(destination: ConsoleDestination(identifier: consoleId))
                }
            } else {
                remove(destinationWithIdentifier: consoleId)
            }

            // Configure output to file
            if logToFile {
                if destination(withIdentifier: fileLogIdentifier) == nil {
                    if let fileDestination = createFileDestination(date: Date()) {
                        add(destination: fileDestination)
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
