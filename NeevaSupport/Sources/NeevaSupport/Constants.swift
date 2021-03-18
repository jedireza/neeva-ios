import Foundation
import Defaults
import KeychainAccess

let neevaHostKey = Defaults.Key<String>("neevaHost", default: "alpha.neeva.co", suite: UserDefaults(suiteName: NeevaConstants.appGroup)!)

public struct NeevaConstants {
    /// The App Group, used for the keychain and UserDefaults
    public static let appGroup = "group.co.neeva.app.ios.browser"

    public static let appPrivacyURL = "https://neeva.co/privacy"
    public static let appHelpCenterURL = "https://neeva.co/contact"
    public static let appSettingsURL = "https://\(appHost)/settings"

    /// The host for the Neeva API/website, such as `alpha.neeva.co`
    public static var appHost: String {
        get { Defaults[neevaHostKey] }
        set { Defaults[neevaHostKey] = newValue }
    }

    /// Check if the given |host| matches |appHost| or is an equivalent value.
    /// This is to support migration via HTTP redirect to future hostnames.
    public static func isAppHostOrEquivalent(_ host: String?) -> Bool {
        return host == appHost ||
            (host == "neeva.com" && appHost == "alpha.neeva.co") ||
            (host == "m1.neeva.com" && appHost == "m1.neeva.co")
    }

    /// The URL form of `appHost`
    public static var appURL: URL { URL(string: "https://\(appHost)/")! }

    /// The keychain key to store the Neeva login cookie into
    public static var loginKeychainKey: String { "neevaHttpdLogin-\(appHost)" }

    /// The shared keychain accessible to the Neeva app and its extensions
    public static let keychain = Keychain(service: Bundle.module.bundleIdentifier ?? "Neeva", accessGroup: appGroup)

    public struct Header {
        public let name: String
        public let value: String
        private init(_ name: String, _ value: String) {
            self.name = name
            self.value = value
        }

        /// Pass this header to all requests to Neeva from the iOS app.
        public static let deviceType = Header("X-Neeva-Device-Type", "ios-browser")
    }
}

/// append a given path component to the provided URL.
/// ```
/// URL(string: "https://example.com") / "foo" / "bar" == URL(string: "https://example.com/foo/bar")
/// ```
public func / (_ lhs: URL, rhs: String) -> URL {
    lhs.appendingPathComponent(rhs)
}
