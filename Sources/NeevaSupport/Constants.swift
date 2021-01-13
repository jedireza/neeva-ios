import Foundation
import Defaults
import SwiftKeychainWrapper

// will return default value if an invalid value is set
let neevaHostKey = Defaults.Key<String>("neevaHost", default: "alpha.neeva.co", suite: UserDefaults(suiteName: NeevaConstants.appGroup)!)

public struct NeevaConstants {
    public static let appGroup = "group.co.neeva.app.ios.browser"

    public static var appHost: String {
        get { Defaults[neevaHostKey] }
        set { Defaults[neevaHostKey] = newValue }
    }
    public static var appURL: URL { URL(string: "https://\(appHost)/")! }

    public static var loginKeychainKey: String { "neevaHttpdLogin-\(appHost)" }
    public static let keychain = KeychainWrapper(serviceName: Bundle.module.bundleIdentifier ?? "Neeva", accessGroup: appGroup)

    public struct Header {
        public let name: String
        public let value: String
        private init(_ name: String, _ value: String) {
            self.name = name
            self.value = value
        }

        // all Neeva requests
        public static let deviceType = Header("X-Neeva-Device-Type", "ios-browser")
    }
}

public func / (_ lhs: URL, rhs: String) -> URL {
    lhs.appendingPathComponent(rhs)
}
