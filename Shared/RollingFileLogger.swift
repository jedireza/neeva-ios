/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import Foundation
import XCGLogger

//// A rolling file logger that saves to a different log file based on given timestamp.
open class RollingFileLogger: XCGLogger {

    public static let TwoMBsInBytes: Int64 = 2 * 100000
    fileprivate let sizeLimit: Int64
    fileprivate let logDirectoryPath: String?

    let fileLogIdentifierPrefix = "co.neeva.app.ios.browser.filelogger."

    fileprivate static let DateFormatter: DateFormatter = {
        let formatter = Foundation.DateFormatter()
        formatter.dateFormat = "yyyyMMdd'T'HHmmssZ"
        return formatter
    }()

    let root: String
    var fileLogIdentifier: String {
        fileLogIdentifierWithRoot(root)
    }

    public init(
        filenameRoot: String, logDirectoryPath: String?, includeDefaultDestinations: Bool = true,
        sizeLimit: Int64 = TwoMBsInBytes
    ) {
        root = filenameRoot
        self.sizeLimit = sizeLimit
        self.logDirectoryPath = logDirectoryPath
        super.init(identifier: "", includeDefaultDestinations: includeDefaultDestinations)
    }

    /// Create a new log file with the given timestamp to log events into
    /// - parameter date: Date for with to start and mark the new log file
    open func newLogWithDate(_ date: Date) {
        if let fileDestination = createFileDestination(date: date) {
            remove(destinationWithIdentifier: fileLogIdentifier)
            add(destination: fileDestination)
        }
    }

    /// Create a new log file destination with the given timestamp to log events into
    /// - parameter date: Date for with to start and mark the new log file
    open func createFileDestination(date: Date) -> FileDestination? {
        guard let filename = filenameWithRoot(root, withDate: date) else { return nil }
        return FileDestination(owner: self, writeToFile: filename, identifier: fileLogIdentifier)
    }

    @discardableResult open func deleteOldLogsDownToSizeLimit() -> DispatchWorkItem? {
        guard let path = logDirectoryPath else { return nil }
        let prefix = root
        let sizeLimit = sizeLimit

        let work = DispatchWorkItem {
            // Check to see that we haven't hit our size limit and if we did, clear out some old
            // logs to make room. This will avoid deleting the latest log file as that could be
            // currently in use.
            while Self.sizeOfAllLogFilesWithPrefix(
                prefix, inDirectory: path, exceedsSizeInBytes: sizeLimit)
            {
                if !Self.deleteOldestLogWithPrefix(prefix, inDirectory: path) {
                    break
                }
            }
        }

        // Run lazily on a background thread.
        DispatchQueue.global(qos: .background).async(execute: work)

        return work
    }

    fileprivate static func deleteOldestLogWithPrefix(_ prefix: String, inDirectory path: String) -> Bool {
        var removed = false
        do {
            let logFiles = try FileManager.default.contentsOfDirectoryAtPath(
                path, withFilenamePrefix: prefix)
            // Avoid deleting the latest log file.
            if logFiles.count > 1, let oldestLogFilename = logFiles.first {
                try FileManager.default.removeItem(atPath: "\(path)/\(oldestLogFilename)")
                removed = true
            }
        } catch _ as NSError {
            error("Shouldn't get here")
        }
        return removed
    }

    fileprivate static func sizeOfAllLogFilesWithPrefix(
        _ prefix: String, inDirectory path: String, exceedsSizeInBytes threshold: Int64
    ) -> Bool {
        let logDirURL = URL(fileURLWithPath: path)
        do {
            return try FileManager.default.allocatedSizeOfDirectoryAtURL(
                logDirURL, forFilesPrefixedWith: prefix, isLargerThanBytes: threshold)
        } catch let errorValue as NSError {
            error("Error determining log directory size: \(errorValue)")
        }
        return false
    }

    fileprivate func filenameWithRoot(_ root: String, withDate date: Date) -> String? {
        if let dir = logDirectoryPath {
            return "\(dir)/\(root).\(RollingFileLogger.DateFormatter.string(from: date)).log"
        }

        return nil
    }

    fileprivate func fileLogIdentifierWithRoot(_ root: String) -> String {
        return "\(fileLogIdentifierPrefix).\(root)"
    }
}
