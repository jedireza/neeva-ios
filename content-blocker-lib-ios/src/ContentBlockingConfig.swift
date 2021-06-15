// Copyright Neeva. All rights reserved.

import Foundation
import os

struct ContentBlockingFlag {
    private var flagKey: String

    init(flagKey: String, defaultVal: Bool?) {
        self.flagKey = flagKey


        if defaultVal != nil {
            //Handle
        }


        if UserDefaults.standard.object(forKey: flagKey) == nil {
            //Handle
        }

        if UserDefaults.standard.object(forKey: flagKey) == nil  && defaultVal != nil {
            UserDefaults.standard.set(defaultVal!, forKey: flagKey)
        }

        //Handle
    }

    func FlagExist() -> Bool {
        return UserDefaults.standard.object(forKey: self.flagKey) != nil
    }

    func RemoveFlagKey() {
        UserDefaults.standard.removeObject(forKey: self.flagKey)
    }

    func IsEnabled() -> Bool {
        return UserDefaults.standard.bool(forKey: self.flagKey)
    }

    func Enable() {
        UserDefaults.standard.set(true, forKey: self.flagKey)
    }

    func Disable() {
        UserDefaults.standard.set(false, forKey: self.flagKey)
    }

    func Toggle() -> Bool {
        UserDefaults.standard.set(!UserDefaults.standard.bool(forKey: self.flagKey), forKey: self.flagKey)
        return UserDefaults.standard.bool(forKey: self.flagKey)
    }
}

struct NeevaContentBlockingConfig {
    static var search = ContentBlockingFlag(flagKey: "NeevaSearchEnabled", defaultVal: false)

    static var upgradeAllToHTTPS = ContentBlockingFlag(flagKey: "NeevaUpgradeAllToHTTPS", defaultVal: false)

    static var blockThirdPartyTrackingCookies = ContentBlockingFlag(flagKey: "NeevaBlockThirdPartyTrackingCookies", defaultVal: true)

    static var blockThirdPartyTrackingRequests = ContentBlockingFlag(flagKey: "NeevaBlockThirdPartyTrackingRequests",  defaultVal: true)

    struct PerSite {
        static let unblockedDomainsKey = "UnblockedDomainsKey"

        private static func addDomainToUnblockedList(domain: String) {
            let unblockedDomains = UserDefaults.standard.mutableArrayValue(forKey: unblockedDomainsKey)
            unblockedDomains.add(domain)
            UserDefaults.standard.set(unblockedDomains, forKey: unblockedDomainsKey)
        }

        private static func removeDomainFromUnblockedList(domain: String) {
            let unblockedDomains = UserDefaults.standard.mutableArrayValue(forKey: unblockedDomainsKey)
            unblockedDomains.remove(domain)
            UserDefaults.standard.set(unblockedDomains, forKey: unblockedDomainsKey)
        }

        static func getUnblockedList() -> [String] {
            return UserDefaults.standard.stringArray(forKey: unblockedDomainsKey) ?? []
        }

        static let perSiteKeyprefix = "PerSiteAllowTrackersFlagKey:"
        static func siteKey(domain: String)-> String {
            return perSiteKeyprefix + domain
        }

        static func AllowTrackersForDomain(domain: String) {
            let siteFlag = ContentBlockingFlag(flagKey: siteKey(domain: domain), defaultVal: true)
            siteFlag.Enable()
            addDomainToUnblockedList(domain: domain)
        }

        static func DisallowTrackersForDomain(domain: String) {
            let siteFlag = ContentBlockingFlag(flagKey: siteKey(domain: domain), defaultVal: nil)
            if (siteFlag.FlagExist()) {
                siteFlag.RemoveFlagKey()
            }
            removeDomainFromUnblockedList(domain: domain)
        }

        static func AreTrackersAllowedFor(domain: String) -> Bool {
            let trackersAllowed = ContentBlockingFlag(flagKey: siteKey(domain: domain), defaultVal: nil)
            return trackersAllowed.IsEnabled()
        }
    }
}
