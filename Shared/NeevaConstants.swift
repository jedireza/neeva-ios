// Copyright Neeva. All rights reserved.

import Defaults
import Foundation
import KeychainAccess
import UIKit

extension Defaults.Keys {
    public static let neevaHost = Defaults.Key<String>(
        "neevaHost", default: "neeva.com", suite: UserDefaults(suiteName: NeevaConstants.appGroup)!)
}

public struct NeevaConstants {
    /// The App Group, used for the keychain and UserDefaults
    public static let appGroup = "group." + AppInfo.baseBundleIdentifier

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
    public static let appMarketingURL: URL = "https://neeva.com/"
    public static let appHelpCenterURL: URL = "https://help.neeva.com/"

    public static var appHomeURL: URL { appURL }
    public static var appSearchURL: URL { appURL / "search" }
    public static var appSpacesURL: URL { appURL / "spaces" }
    public static var appSettingsURL: URL { appURL / "settings" }
    public static var appReferralsURL: URL { appSettingsURL / "referrals" }
    public static var appConnectionsURL: URL { appURL / "connections" }
    public static var appMemoryModeURL: URL { URL(string: "\(appURL)settings#memory-mode")! }
    public static var appSigninURL: URL { appURL / "signin" }
    public static var appSignupURL: URL { appURL / "p/signup" }
    public static var appFAQURL: URL { appURL / "faq" }
    public static var appWelcomeToursURL: URL { URL(string: "\(appURL)#modal-hello")! }

    public static let appPrivacyURL = appMarketingURL / "privacy"
    public static let appTermsURL = appMarketingURL / "terms"

    /// The keychain key to store the Neeva login cookie into
    public static var loginKeychainKey: String { "neevaHttpdLogin-\(appHost)" }

    /// The shared keychain accessible to the Neeva app and its extensions
    public static let keychain = Keychain(service: "Neeva", accessGroup: appGroup)

    public static var deviceTypeValue: String {
        UIDevice.current.userInterfaceIdiom == .pad ? "tablet" : "phone"
    }

    public static var deviceNameValue: String = DeviceInfo.specificModelName

    public struct Header {
        public let name: String
        public let value: String
        private init(_ name: String, _ value: String) {
            self.name = name
            self.value = value
        }

        /// Pass this header to all requests to Neeva from the iOS app.
        public static let deviceType = Header("X-Neeva-Device-Type", deviceTypeValue)
        public static let deviceName = Header("X-Neeva-Device-Name", deviceNameValue)
    }

    /// This cookie is set on requests to identify the requester as the iOS app.
    public static var deviceTypeCookie: HTTPCookie {
        HTTPCookie(properties: [
            .name: "DeviceType",
            .value: deviceTypeValue,
            .domain: NeevaConstants.appHost,
            .path: "/",
            .expires: Date.distantFuture,
        ])!
    }

    /// This cookie is set on requests to identify the requester as the iOS app.
    public static var deviceNameCookie: HTTPCookie {
        HTTPCookie(properties: [
            .name: "DeviceName",
            .value: deviceNameValue,
            .domain: NeevaConstants.appHost,
            .path: "/",
            .expires: Date.distantFuture,
        ])!
    }

    /// This cookie is set on requests to identify the requester as the iOS app.
    public static var browserTypeCookie: HTTPCookie {
        HTTPCookie(properties: [
            .name: "BrowserType",
            .value: "neeva-ios",
            .domain: NeevaConstants.appHost,
            .path: "/",
            .expires: Date.distantFuture,
        ])!
    }

    /// This cookie is set on requests to identify the version of the browser.
    public static var browserVersionCookie: HTTPCookie {
        HTTPCookie(properties: [
            .name: "BrowserVersion",
            .value: AppInfo.appVersionReportedToNeeva,
            .domain: NeevaConstants.appHost,
            .path: "/",
            .expires: Date.distantFuture,
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
            .init("HttpOnly"): true,
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

private class BundleHookClass {}
