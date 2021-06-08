/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import Defaults

// Data type for the type of sheet which is helpful to know when / how to show the ETP Cover Sheet
public enum ETPCoverSheetShowType: String, Codable {
    case CleanInstall
    case Upgrade
    case DoNotShow
    case Unknown
}

extension Defaults.Keys {
    // automatically recorded
    public static let sessionCount = Defaults.Key<Int32>("profile.sessionCount", default: 0)
    public static let latestAppVersion = Defaults.Key<String?>("profile.latestAppVersion")
    public static let etpCoverSheetShowType = Defaults.Key<ETPCoverSheetShowType?>("profile.etpCoverSheetShowType")
    public static let installSession = Defaults.Key<Int32>("profile.installSessionNumber", default: 0)
    public static let searchInputPromptDismissed = Defaults.BoolKey("profile.SearchInputPromptDismissed")
    public static let introSeen = Defaults.BoolKey("profile.IntroViewControllerSeen")
    public static let lastVersionNumber = Defaults.Key<String?>("profile.KeyLastVersionNumber")
    public static let didShowDefaultBrowserOnboarding = Defaults.BoolKey("didShowDefaultBrowserOnboarding")

    // explicit/implicit settings
    public static let noImageModeStatus = Defaults.BoolKey("profile.NoImageModeStatus")
    public static let nightModeStatus = Defaults.BoolKey("profile.NightModeStatus")
    public static let nightModeEnabledDarkTheme = Defaults.BoolKey("profile.NightModeEnabledDarkTheme")
    public static let mailToOption = Defaults.Key<String?>("profile.MailToOption")
    public static let contextMenuShowLinkPreviews = Defaults.Key("profile.ContextMenuShowLinkPreviews", default: true)
    public static let showClipboardBar = Defaults.BoolKey("profile.showClipboardBar")
    public static let deletedSuggestedSites = Defaults.Key<[String]>("profile.topSites.deletedSuggestedSites", default: [])
    public static let showSearchSuggestions = Defaults.Key("profile.search.suggestions.show", default: true)
    public static let blockPopups = Defaults.Key("profile.blockPopups", default: true)
    public static let closePrivateTabs = Defaults.BoolKey("profile.settings.closePrivateTabs")
    public static let recentlyClosedTabs = Defaults.Key<Data?>("profile.recentlyClosedTabs")
    public static let showLoginsInAppMenu = Defaults.BoolKey("profile.showLoginsInAppMenu")
    public static let saveLogins = Defaults.BoolKey("profile.saveLogins")

    // caches
    public static let topSitesCacheIsValid = Defaults.BoolKey("profile.topSitesCacheIsValid")
    public static let topSitesCacheSize = Defaults.Key<Int32?>("profile.topSitesCacheSize")

    // telemetry
    public static let appExtensionTelemetryOpenUrl = Defaults.Key<Bool?>("profile.AppExtensionTelemetryOpenUrl", suite: UserDefaults(suiteName: AppInfo.sharedContainerIdentifier)!)

    // widgets
    public static let widgetKitSimpleTabKey = Defaults.Key<Data?>("WidgetKitSimpleTabKey", suite: UserDefaults(suiteName: AppInfo.sharedContainerIdentifier)!)
    public static let widgetKitSimpleTopTab = Defaults.Key<Data?>("WidgetKitSimpleTopTab", suite: UserDefaults(suiteName: AppInfo.sharedContainerIdentifier)!)
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
