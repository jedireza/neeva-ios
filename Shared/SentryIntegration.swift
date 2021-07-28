/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import Foundation

// TODO: Migrate to our own Client logging system. Firefox used
// Sentry, and this is now just a stubbed out version of that.

public typealias SentryRequestFinished = (Error?) -> Void

public enum SentrySeverity {
    case fatal
    case error
    case warning
    case info
    case debug
}

public enum SentryTag: String {
    case swiftData = "SwiftData"
    case browserDB = "BrowserDB"
    case rustPlaces = "RustPlaces"
    case rustLogins = "RustLogins"
    case rustLog = "RustLog"
    case notificationService = "NotificationService"
    case unifiedTelemetry = "UnifiedTelemetry"
    case general = "General"
    case tabManager = "TabManager"
    case bookmarks = "Bookmarks"
}

public class Sentry {
    public static let shared = Sentry()

    public static var crashedLastLaunch: Bool {
        return false  // TODO: implement
    }

    private var enabled = false

    private var attributes: [String: Any] = [:]

    public func setup(sendUsageData: Bool) {
        assert(!enabled, "Sentry.setup() should only be called once")

        if DeviceInfo.isSimulator() {
            Logger.browserLogger.debug("Not enabling Sentry; Running in Simulator")
            return
        }

        if !sendUsageData {
            Logger.browserLogger.debug("Not enabling Sentry; Not enabled by user choice")
            return
        }

        // TODO: Uncomment this once we have an implementation.
        //enabled = true

        // Ignore SIGPIPE exceptions globally.
        // https://stackoverflow.com/questions/108183/how-to-prevent-sigpipes-or-handle-them-properly
        signal(SIGPIPE, SIG_IGN)
    }

    public func crash() {
        let ptr = UnsafeMutablePointer<Int>(bitPattern: 1)
        ptr?.pointee = 0
    }

    /*
         This is the behaviour we want for Sentry logging
                   .info .error .severe
         Debug      y      y       y
         Beta       y      y       y
         Relase     n      n       y
     */
    private func shouldNotSendEventFor(_ severity: SentrySeverity) -> Bool {
        return !enabled || (AppConstants.BuildChannel == .release && severity != .fatal)
    }

    public func send(
        message: String, tag: SentryTag = .general, severity: SentrySeverity = .info,
        extra: [String: Any]? = nil, description: String? = nil,
        completion: SentryRequestFinished? = nil
    ) {
        // Build the dictionary
        var extraEvents: [String: Any] = [:]
        if let paramEvents = extra {
            extraEvents.merge(with: paramEvents)
        }
        if let extraString = description {
            extraEvents.merge(with: ["errorDescription": extraString])
        }
        printMessage(message: message, extra: extraEvents)

        // Only report fatal errors on release
        if shouldNotSendEventFor(severity) {
            completion?(nil)
            return
        }

        // TODO: Implement
        completion?(nil)
    }

    public func sendWithStacktrace(
        message: String, tag: SentryTag = .general, severity: SentrySeverity = .info,
        extra: [String: Any]? = nil, description: String? = nil,
        completion: SentryRequestFinished? = nil
    ) {
        var extraEvents: [String: Any] = [:]
        if let paramEvents = extra {
            extraEvents.merge(with: paramEvents)
        }
        if let extraString = description {
            extraEvents.merge(with: ["errorDescription": extraString])
        }
        printMessage(message: message, extra: extraEvents)

        // Do not send messages to Sentry if disabled OR if we are not on beta and the severity isnt severe
        if shouldNotSendEventFor(severity) {
            completion?(nil)
            return
        }

        // TODO: Implement
        completion?(nil)
    }

    public func addAttributes(_ attributes: [String: Any]) {
        self.attributes.merge(with: attributes)
    }

    public func breadcrumb(category: String, message: String) {
        // TODO: Implement
    }

    public func clearBreadcrumbs() {
        // TODO: Implement
    }

    private func printMessage(message: String, extra: [String: Any]? = nil) {
        let string = extra?.reduce("") { (result: String, arg1) in
            let (key, value) = arg1
            return "\(result), \(key): \(value)"
        }
        Logger.browserLogger.debug("Sentry: \(message) \(string ??? "")")
    }
}
