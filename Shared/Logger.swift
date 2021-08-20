/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import Defaults
import Foundation
import XCGLogger

public struct Logger {}

// MARK: - Singleton Logger Instances
extension Logger {
    public static let logPII = false

    /// Logger used for recording frontend/browser happenings
    public static let browser = OptionalLogger(
        key: .enableBrowserLogging,
        filenameRoot: "browser",
        logDirectoryPath: Logger.logFileDirectoryPath(inDocuments: false))

    /// Logger used for recording network happenings
    public static let network = OptionalLogger(
        key: .enableNetworkLogging,
        filenameRoot: "network",
        logDirectoryPath: Logger.logFileDirectoryPath(inDocuments: false))

    /// Logger used for recording happenings with Providers, Storage, and Profiles
    public static let storage = OptionalLogger(
        key: .enableStorageLogging,
        filenameRoot: "storage",
        logDirectoryPath: Logger.logFileDirectoryPath(inDocuments: false))

    /// Tells all loggers to close their existing log file and start using a new log
    /// file. Also, prunes back the set of old log files, keeping the total set of
    /// log files below a threshold number of bytes.
    public static func rollLogs() {
        // If we are actively logging to files, then temporarily disable and re-enabled
        // afterwards, so that new log files get created.
        if Defaults[.enableLogToFile] {
            Defaults[.enableLogToFile].toggle()
        }
        DispatchQueue.global(qos: .background).async {
            Logger.browser.deleteOldLogsDownToSizeLimit()
            Logger.network.deleteOldLogsDownToSizeLimit()
            Logger.storage.deleteOldLogsDownToSizeLimit()

            DispatchQueue.main.async {
                if !Defaults[.enableLogToFile] {
                    Defaults[.enableLogToFile].toggle()
                }
            }
        }
    }

    /// Deletes all log files and triggers the creation of new, empty log files for
    /// all loggers.
    public static func deleteLogs() {
        guard let logDirectoryPath = Logger.logFileDirectoryPath(inDocuments: false) else {
            return
        }
        // If we are actively logging to files, then temporarily disable and re-enabled
        // afterwards, so that new log files get created.
        if Defaults[.enableLogToFile] {
            Defaults[.enableLogToFile].toggle()
        }
        DispatchQueue.global(qos: .background).async {
            do {
                let logFiles = try FileManager.default.contentsOfDirectory(atPath: logDirectoryPath)
                for logFile in logFiles {
                    try FileManager.default.removeItem(
                        atPath: "\(logDirectoryPath)/\(logFile)")
                }
            } catch _ as NSError {
                return
            }
            DispatchQueue.main.async {
                if !Defaults[.enableLogToFile] {
                    Defaults[.enableLogToFile].toggle()
                }
            }
        }
    }

    /// Makes a snapshot copy of all log files into the user's documents folder.
    public static func copyPreviousLogsToDocuments() {
        if let defaultLogDirectoryPath = logFileDirectoryPath(inDocuments: false),
            let documentsLogDirectoryPath = logFileDirectoryPath(inDocuments: true),
            let previousLogFiles = try? FileManager.default.contentsOfDirectory(
                atPath: defaultLogDirectoryPath)
        {
            let defaultLogDirectoryURL = URL(
                fileURLWithPath: defaultLogDirectoryPath, isDirectory: true)
            let documentsLogDirectoryURL = URL(
                fileURLWithPath: documentsLogDirectoryPath, isDirectory: true)
            for previousLogFile in previousLogFiles {
                let previousLogFileURL = defaultLogDirectoryURL.appendingPathComponent(
                    previousLogFile)
                let targetLogFileURL = documentsLogDirectoryURL.appendingPathComponent(
                    previousLogFile)
                try? FileManager.default.copyItem(at: previousLogFileURL, to: targetLogFileURL)
            }
        }
    }

    /// Return the log file directory path. If the directory doesn't exist, make sure it exist first before returning the path.
    /// - returns: Directory path where log files are stored
    public static func logFileDirectoryPath(inDocuments: Bool) -> String? {
        let searchPathDirectory: FileManager.SearchPathDirectory =
            inDocuments ? .documentDirectory : .cachesDirectory
        if let targetDirectory = NSSearchPathForDirectoriesInDomains(
            searchPathDirectory, .userDomainMask, true
        ).first {
            let logsDirectory = "\(targetDirectory)/Logs"
            if !FileManager.default.fileExists(atPath: logsDirectory) {
                do {
                    try FileManager.default.createDirectory(
                        atPath: logsDirectory, withIntermediateDirectories: true, attributes: nil)
                    return logsDirectory
                } catch _ as NSError {
                    return nil
                }
            } else {
                return logsDirectory
            }
        }

        return nil
    }

    static private func fileLoggerWithName(_ name: String) -> XCGLogger {
        let log = XCGLogger()
        if let logFileURL = urlForLogNamed(name) {
            let fileDestination = FileDestination(
                owner: log,
                writeToFile: logFileURL.absoluteString,
                identifier: "co.neeva.app.ios.browser.filelogger.\(name)"
            )
            log.add(destination: fileDestination)
        }
        return log
    }

    static private func urlForLogNamed(_ name: String) -> URL? {
        guard let logDir = Logger.logFileDirectoryPath(inDocuments: false) else {
            return nil
        }

        return URL(string: "\(logDir)/\(name).log")
    }
}
