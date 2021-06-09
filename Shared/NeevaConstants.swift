// Copyright Neeva. All rights reserved.

import Foundation
import Defaults
import KeychainAccess

extension Defaults.Keys {
    public static let neevaHost = Defaults.Key<String>("neevaHost", default: "neeva.com", suite: UserDefaults(suiteName: NeevaConstants.appGroup)!)
}

public struct NeevaConstants {
    /// The App Group, used for the keychain and UserDefaults
    public static let appGroup = "group.co.neeva.app.ios.browser"

    /// The host for the Neeva API/website, such as `neeva.com`
    public static var appHost: String {
        get { Defaults[.neevaHost] }
        set { Defaults[.neevaHost] = newValue }
    }

    public static func isAppHost(_ host: String?) -> Bool {
        return host == appHost
    }

    /// The URL form of `appHost`
    public static var appURL: URL { URL(string: "https://\(appHost)/")! }
    public static let appMarketingURL = URL(string: "https://neeva.com/")!

    public static var appHomeURL: URL { appURL }
    public static var appSearchURL: URL { appURL / "search" }
    public static var appSpacesURL: URL { appURL / "spaces" }
    public static var appSettingsURL: URL { appURL / "settings" }
    public static var appSigninURL: URL { appURL / "signin" }
    public static var appSignupURL: URL { appURL / "signup" }
    public static var appFAQURL: URL { appURL / "faq" }

    public static let appPrivacyURL = appMarketingURL / "privacy"
    public static let appTermsURL = appMarketingURL / "terms"
    public static let appHelpCenterURL = appMarketingURL / "contact"

    /// The keychain key to store the Neeva login cookie into
    public static var loginKeychainKey: String { "neevaHttpdLogin-\(appHost)" }

    /// The shared keychain accessible to the Neeva app and its extensions
    public static let keychain = Keychain(service: "Neeva", accessGroup: appGroup)

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

    /// This cookie is set on requests to identify the requester as the iOS app.
    public static var deviceTypeCookie: HTTPCookie {
        HTTPCookie(properties: [
            .name: "DeviceType",
            .value: "ios-browser",
            .domain: NeevaConstants.appHost,
            .path: "/",
            .expires: Date.distantFuture
        ])!
    }

    /// Generates a login cookie from the given cookie value.
    public static func loginCookie(for value: String) -> HTTPCookie {
        HTTPCookie(properties: [
            .name: "httpd~login",
            .value: value,
            .domain: NeevaConstants.appHost,
            .path: "/",
            .expires: Date.distantFuture,
            .secure: true,
            .sameSitePolicy: HTTPCookieStringPolicy.sameSiteLax,
            // ! potentially undocumented API
            .init("HttpOnly"): true
        ])!
    }

    public static let sharedBundle = Bundle(for: BundleHookClass.self)

    public static func isNeevaHome(url: URL?) -> Bool {
        return url?.scheme == NeevaConstants.appHomeURL.scheme
            && url?.host == NeevaConstants.appHomeURL.host
            && url?.path == NeevaConstants.appHomeURL.path
    }

    // Returns true if the page has an embedded search box, indicating that we
    // should not show the same query in the URL bar.
    // TODO: This should probably be server controlled through a feature flag.
    public static func isNeevaPageWithSearchBox(url: URL?) -> Bool {
        return url?.scheme == NeevaConstants.appSearchURL.scheme
            && url?.host == NeevaConstants.appSearchURL.host
            && url?.path == NeevaConstants.appSearchURL.path
            && url?.hasQueryParam("c", value: "Maps") == true
    }
}

fileprivate class BundleHookClass {}

/// append a given path component to the provided URL.
/// ```
/// URL(string: "https://example.com") / "foo" / "bar" == URL(string: "https://example.com/foo/bar")
/// ```
public func / (_ lhs: URL, rhs: String) -> URL {
    lhs.appendingPathComponent(rhs)
}
