import Foundation
import Defaults
import KeychainAccess

let neevaHostKey = Defaults.Key<String>("neevaHost", default: "neeva.com", suite: UserDefaults(suiteName: NeevaConstants.appGroup)!)

public struct NeevaConstants {
    /// The App Group, used for the keychain and UserDefaults
    public static let appGroup = "group.co.neeva.app.ios.browser"

    public static let appPrivacyURL = "https://neeva.com/privacy"
    public static let appHelpCenterURL = "https://neeva.com/contact"
    public static let appSettingsURL = "https://\(appHost)/settings"
    public static let appLoginURL = "https://\(appHost)/login"
    public static let appSigninURL = "https://\(appHost)/signin"

    /// The host for the Neeva API/website, such as `neeva.com`
    public static var appHost: String {
        get { Defaults[neevaHostKey] }
        set { Defaults[neevaHostKey] = newValue }
    }

    public static func isAppHost(_ host: String?) -> Bool {
        return host == appHost
    }

    /// The URL form of `appHost`
    public static var appURL: URL { URL(string: "https://\(appHost)/")! }

    public static var appHomeURL: URL { appURL }
    public static var appSpacesURL: URL { appURL / "spaces" }

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
