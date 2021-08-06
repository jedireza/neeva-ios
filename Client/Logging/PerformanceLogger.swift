// Copyright Neeva. All rights reserved.
import Defaults
import Shared


enum PerformanceLoggerAttribute: String {
    case crashed
    case pageLoaded
}

public class PerformanceLogger {

    public static let shared = PerformanceLogger()

    // increment user default page load if scheme is http or https
    public func incrementPageLoad(url: URL) {
        if url.scheme == "http" || url.scheme == "https" {
            let currentCount = Defaults[.pageLoadedCounter]
            Defaults[.pageLoadedCounter] = currentCount + 1
        }
    }

    // reset user default page load to 0
    private func reset() {
        Defaults[.pageLoadedCounter] = 0
    }

    // sent last crash status with page load number
    public func logPageLoadWithCrashedStatus(crashed: Bool) {
        var attributes = [ClientLogCounterAttribute]()
        let pageLoadedCount = Defaults[.pageLoadedCounter]
        attributes.append(
            ClientLogCounterAttribute(
                key: PerformanceLoggerAttribute.crashed.rawValue, value: String(crashed)))

        attributes.append(
            ClientLogCounterAttribute(
                key: PerformanceLoggerAttribute.pageLoaded.rawValue,
                value: String(pageLoadedCount)))
        ClientLogger.shared.logCounter(.AppCrashWithPageLoad, attributes: attributes)
        reset()
    }
}
