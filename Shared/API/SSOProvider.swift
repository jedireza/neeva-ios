// Copyright Neeva. All rights reserved.

import SwiftUI

// ****** IMPORTANT *****
// Please KEEP IN SYNC with "serving/constants/sso_providers.go"
// and "client/packages/neeva-lib/src/constants/sso-providers.ts"
// in the main repo.
// ***********************
public enum SSOProvider: String, CaseIterable {
    /// Unknown means the SSO provider is not known. This is the default value,
    /// and generally means that no SSO has occurred.
    case unknown = "Unknown"
    /// Google is for Google SSO, e.g. "Sign in with Google"
    case google = "neeva.co/auth/oauth2/authenticators/google"
    /// Apple is for Apple SSO, e.g. "Sign in with Apple"
    case apple = "neeva.co/auth/oauth2/authenticators/apple"
    /// Microsoft is for Microsoft SSO.
    case microsoft = "neeva.co/auth/oauth2/authenticators/microsoft"
    /// Okta is for Neeva Account
    case okta = "neeva.co/auth/oauth2/authenticators/okta"

    public var displayName: String {
        switch self {
        case .unknown: return "Unknown"
        case .google: return "Google"
        case .apple: return "Apple"
        case .microsoft: return "Microsoft"
        case .okta: return "Neeva"
        }
    }

    public var icon: Image {
        switch self {
        case .unknown: return Image("placeholder-avatar")
        case .google: return Image("google")
        case .apple: return Image("apple")
        case .microsoft: return Image("o365")
        case .okta: return Image("neeva-logo")
        }
    }
}
