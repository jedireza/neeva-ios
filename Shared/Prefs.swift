// Copyright Neeva. All rights reserved.

import Defaults

// If you add a setting here, make sure it’s either exposed through
// user-visible settings or in InternalSettingsView
extension Defaults.Keys {
    // automatically recorded
    public static let searchInputPromptDismissed = Defaults.BoolKey(
        "profile.SearchInputPromptDismissed")
    public static let introSeen = Defaults.BoolKey("profile.IntroViewControllerSeen")
    public static let lastVersionNumber = Defaults.Key<String?>("profile.KeyLastVersionNumber")
    public static let didShowDefaultBrowserOnboarding = Defaults.BoolKey(
        "didShowDefaultBrowserOnboarding")
    public static let didDismissDefaultBrowserCard = Defaults.BoolKey(
        "profile.didDismissDefaultBrowserCard")
    public static let didDismissReferralPromoCard =
        Defaults.BoolKey("profile.didDismissReferralPromoCard")

    // explicit/implicit settings
    public static let contextMenuShowLinkPreviews = Defaults.Key(
        "profile.ContextMenuShowLinkPreviews", default: true)
    public static let showClipboardBar = Defaults.BoolKey("profile.showClipboardBar")
    public static let deletedSuggestedSites = Defaults.Key<[String]>(
        "profile.topSites.deletedSuggestedSites", default: [])
    public static let showSearchSuggestions = Defaults.Key(
        "profile.search.suggestions.show", default: true)
    public static let blockPopups = Defaults.Key("profile.blockPopups", default: true)
    public static let closePrivateTabs = Defaults.BoolKey("profile.settings.closePrivateTabs")
    public static let recentlyClosedTabs = Defaults.Key<Data?>("profile.recentlyClosedTabs")
    public static let saveLogins = Defaults.BoolKey("profile.saveLogins")
    public static let upgradeAllToHttps = Defaults.BoolKey(
        "profile.tracking_protection.upgradeAllToHttps")
    public static let blockThirdPartyTrackingCookies = Defaults.Key(
        "profile.tracking_protection.blockThirdPartyTrackingCookies", default: true)
    public static let blockThirdPartyTrackingRequests = Defaults.Key(
        "profile.tracking_protection.blockThirdPartyTrackingRequests", default: true)
    public static let unblockedDomains = Defaults.Key<Set<String>>(
        "profile.tracking_protection.unblockedDomains", default: Set<String>())

    // debug settings
    public static let enableGeigerCounter = Defaults.BoolKey("profile.enableGeigerCounter")

    // caches
    public static let topSitesCacheIsValid = Defaults.BoolKey("profile.topSitesCacheIsValid")
    public static let topSitesCacheSize = Defaults.Key<Int32?>("profile.topSitesCacheSize")

    // telemetry
    public static let appExtensionTelemetryOpenUrl = Defaults.Key<Bool?>(
        "profile.AppExtensionTelemetryOpenUrl",
        suite: UserDefaults(suiteName: AppInfo.sharedContainerIdentifier)!)

    // widgets
    public static let widgetKitSimpleTabKey = Defaults.Key<Data?>(
        "WidgetKitSimpleTabKey", suite: UserDefaults(suiteName: AppInfo.sharedContainerIdentifier)!)
    public static let widgetKitSimpleTopTab = Defaults.Key<Data?>(
        "WidgetKitSimpleTopTab", suite: UserDefaults(suiteName: AppInfo.sharedContainerIdentifier)!)
}

extension Defaults {
    static func BoolKey(_ key: String, suite: UserDefaults = .standard) -> Key<Bool> {
        Key<Bool>(key, default: false, suite: suite)
    }
}

extension UserDefaults {
    public func clearProfilePrefs() {
        for key in dictionaryRepresentation().keys {
            if key.hasPrefix("profile.") {
                UserDefaults.standard.removeObject(forKey: key)
            }
        }
    }
}
