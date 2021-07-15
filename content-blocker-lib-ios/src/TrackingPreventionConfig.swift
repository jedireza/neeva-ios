// Copyright Neeva. All rights reserved.

import Foundation
import os
import Defaults

struct TrackingPreventionConfig {
    static var upgradeAllToHTTPS: Bool {
        set {
            Defaults[.upgradeAllToHttps] = newValue
        }

        get {
            Defaults[.upgradeAllToHttps]
        }
    }

    static var blockThirdPartyTrackingCookies: Bool {
        set {
            Defaults[.blockThirdPartyTrackingCookies] = newValue
        }

        get {
            Defaults[.blockThirdPartyTrackingCookies]
        }
    }

    static var blockThirdPartyTrackingRequests: Bool {
        set {
            Defaults[.blockThirdPartyTrackingRequests] = newValue
        }

        get {
            Defaults[.blockThirdPartyTrackingRequests]
        }
    }

    struct PerSite {
        static var unblockedDomains: Set<String> {
            set {
                Defaults[.unblockedDomains] = newValue
            }

            get {
                Defaults[.unblockedDomains]
            }
        }

        static var unblockedDomainsRegex: [String] {
            unblockedDomains
                .compactMap { wildcardContentBlockerDomainToRegex(domain: "*" + $0) }
        }

        static func allowTrackersFor(_ domain: String) {
            Defaults[.unblockedDomains].insert(domain)
        }

        static func disallowTrackersFor(_ domain: String) {
            guard Defaults[.unblockedDomains].contains(domain) else {
                return
            }

            Defaults[.unblockedDomains].remove(domain)
        }

        static func trackersAllowedFor(_ domain: String) -> Bool {
            Defaults[.unblockedDomains].contains(domain)
        }
    }
}
