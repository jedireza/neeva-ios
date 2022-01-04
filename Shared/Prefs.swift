<<<<<<< HEAD
// Copyright Neeva. All rights reserved.

import Defaults

// If you add a setting here, make sure it’s either exposed through
// user-visible settings or in InternalSettingsView
//
// TODO(Issue #1209): Migrate all pref names to use "_" in place of "." to
// support Defaults.publisher.
//
extension Defaults.Keys {
    // automatically recorded
    public static let searchInputPromptDismissed = Defaults.BoolKey(
        "profile.SearchInputPromptDismissed")
    public static let introSeen = Defaults.BoolKey("profile.IntroViewControllerSeen")
    public static let didFirstNavigation = Defaults.BoolKey("profile_didFirstNavigation")
    public static let lastVersionNumber = Defaults.Key<String?>("profile.KeyLastVersionNumber")
    public static let didShowDefaultBrowserOnboarding = Defaults.BoolKey(
        "didShowDefaultBrowserOnboarding")
    public static let didDismissDefaultBrowserCard = Defaults.BoolKey(
        "profile.didDismissDefaultBrowserCard")
    public static let didDismissReferralPromoCard =
        Defaults.BoolKey("profile.didDismissReferralPromoCard")
    public static let firstRunSeenAndNotSignedIn = Defaults.BoolKey(
        "firstRunSeenAndNotSignedIn")
    public static let signedInOnce = Defaults.BoolKey("signedInOnce")
    public static let firstRunPath = Defaults.Key<String>(
        "firstRunPath", default: "none")
    public static let firstRunImpressionLogged = Defaults.BoolKey(
        "firstRunImpressionLogged")
    public static let sessionUUID = Defaults.Key<String>(
        "sessionUUID", default: "")
    public static let firstSessionUUID = Defaults.Key<String>(
        "firstSessionUUID", default: "")
    public static let sessionUUIDExpirationTime = Defaults.Key<Date>(
        "sessionUUIDExpirationTime", default: Date(timeIntervalSince1970: 0))

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
    public static let enableBrowserLogging = Defaults.BoolKey("profile_enableBrowserLogging")
    public static let enableWebKitConsoleLogging = Defaults.BoolKey(
        "profile_enableWebKitConsoleLogging")
    public static let enableNetworkLogging = Defaults.BoolKey("profile_enableNetworkLogging")
    public static let enableStorageLogging = Defaults.BoolKey("profile_enableStorageLogging")
    public static let enableLogToConsole = Defaults.BoolKey("profile_enableLogToConsole")
    public static let enableLogToFile = Defaults.BoolKey("profile_enableLogToFile")
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

    // performance
    public static let applicationCleanlyBackgrounded = Defaults.Key<Bool>(
        "ApplicationCrashedLastTime", default: true)
    public static let pageLoadedCounter = Defaults.Key<Int32>("PageLoadedCounter", default: 0)

    public static let loginLastWeekTimeStamp = Defaults.Key<[Date]>(
        "LoginLastWeekTimeStamp", default: [])

    public static let ratingsCardHidden = Defaults.Key<Bool>("RatingsCardHidden", default: false)

    public static let notificationToken = Defaults.Key<String?>(
        "notificationToken", default: nil)

    // spaces
    public static let seenSpacesIntro = Defaults.Key<Bool>(
        "spacesIntroSeen", default: false)
    public static let seenSpacesShareIntro = Defaults.Key<Bool>(
        "spacesShareIntroSeen", default: false)
    public static let showDescriptions = Defaults.Key<Bool>(
        "showSpaceEntityDescription", default: false)

    // notification
    public static let lastScheduledNeevaPromoID = Defaults.Key<String?>(
        "lastScheduledNeevaPromoID", default: nil)
    public static let lastNeevaPromoScheduledTimeInterval = Defaults.Key<Int?>(
        "lastNeevaPromoScheduledTimeInterval")
    public static let didRegisterNotificationTokenOnServer = Defaults.Key<Bool>(
        "didRegisterNotificationTokenOnServer", default: false)
    public static let productSearchPromoTimeInterval = Defaults.Key<Int>(
        "productSearchPromoTimeInterval", default: 259200)
    public static let newsProviderPromoTimeInterval = Defaults.Key<Int>(
        "newsProviderPromoTimeInterval", default: 86400)
    public static let fastTapPromoTimeInterval = Defaults.Key<Int>(
        "fastTapPromoTimeInterval", default: 432000)
    /// 0: Undecided, 1: Accepted, 2: Denied
    public static let notificationPermissionState = Defaults.Key<Int>(
        "notificationPermissionState", default: 0)
    public static let seenNotificationPermissionPromo = Defaults.Key<Bool>(
        "seenNotificationPermissionPromo", default: false)
    public static let debugNotificationTitle = Defaults.Key<String?>(
        "debugNotificationTitle", default: "Neeva Space")
    public static let debugNotificationBody = Defaults.Key<String?>(
        "debugNotificationBody", default: "Check out our recommended space: Cookie Monster Space")
    public static let debugNotificationDeeplink = Defaults.Key<String?>(
        "debugNotificationDeeplink",
        default: "neeva://space?id=B-ZzfqeytWS-n3YHKRi77h6Ore1kQ7EuojJIm4b7")
    public static let debugNotificationTimeInterval = Defaults.Key<Int>(
        "debugNotificationTimeInterval", default: 10)

    // tab groups
    public static let tabGroupNames = Defaults.Key<[String: String]>(
        "tabGroupNames", default: [String: String]())

    public static let seenBlackFridayFollowPromo = Defaults.Key<Bool>(
        "seenBlackFridayFollowPromo", default: false)
    public static let seenBlackFridayNotifyPromo = Defaults.Key<Bool>(
        "seenBlackFridayNotifyPromo", default: false)

    // Feedback
    public static let feedbackBeingSent = Defaults.Key<Bool>(
        "feedbackBeingSent", default: false)

    // preview mode
    public static let previewModeQueries = Defaults.Key<Set<String>>(
        "previewModeQueries", default: Set<String>())
    public static let signupPromptInterval = Defaults.Key<Int>(
        "signupPromptInterval", default: 5)
    public static let maxQueryLimit = Defaults.Key<Int>(
        "maxQueryLimit", default: 25)

    // crypto wallet
    public static let cryptoPhrases = Defaults.Key<String>(
        "cryptoPhrases", default: "")
    public static let cryptoPublicKey = Defaults.Key<String>(
        "cryptoPublicKey", default: "")
    public static let cryptoPrivateKey = Defaults.Key<String>(
        "cryptoPrivateKey", default: "")
    public static let cryptoTransactionHashStore = Defaults.Key<Set<String>>(
        "cryptoTransactionHashStore", default: Set<String>())
    public static let sessionsPeerIDs = Defaults.Key<Set<String>>(
        "web3SessionsPeerIDs", default: Set<String>())
=======
/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import Foundation

public struct PrefsKeys {
    // When this pref is set (by the user) it overrides default behaviour which is just based on app locale.
    public static let KeyEnableChinaSyncService = "useChinaSyncService"
    public static let KeyLastRemoteTabSyncTime = "lastRemoteTabSyncTime"
    public static let KeyLastSyncFinishTime = "lastSyncFinishTime"
    public static let KeyDefaultHomePageURL = "KeyDefaultHomePageURL"
    public static let KeyNoImageModeStatus = "NoImageModeStatus"
    public static let KeyNightModeButtonIsInMenu = "NightModeButtonIsInMenuPrefKey"
    public static let KeyNightModeStatus = "NightModeStatus"
    public static let KeyNightModeEnabledDarkTheme = "NightModeEnabledDarkTheme"
    public static let KeyMailToOption = "MailToOption"
    public static let KeyLastVersionNumber = "KeyLastVersionNumber"
    public static let HasFocusInstalled = "HasFocusInstalled"
    public static let HasPocketInstalled = "HasPocketInstalled"
    public static let IntroSeen = "IntroViewControllerSeen"
    public static let HomePageTab = "HomePageTab"
    public static let HomeButtonHomePageURL = "HomeButtonHomepageURL"
    public static let NumberOfTopSiteRows = "NumberOfTopSiteRows"
    public static let LoginsSaveEnabled = "saveLogins"
    public static let LoginsShowShortcutMenuItem = "showLoginsInAppMenu"
    public static let KeyInstallSession = "installSessionNumber"
    public static let KeyETPCoverSheetShowType = "etpCoverSheetShowType"
    public static let KeyDefaultBrowserCardShowType = "defaultBrowserCardShowType"
    public static let KeyDidShowDefaultBrowserOnboarding = "didShowDefaultBrowserOnboarding"
    public static let ShowNewTabToolbarButton = "newTabToolbarButton"
    public static let ContextMenuShowLinkPreviews = "showLinkPreviews"
    public static let NewTabCustomUrlPrefKey = "HomePageURLPref"
    public static let ChronTabsPrefKey = "chronTabsPrefKey"
    public static let SessionCount = "sessionCount"
    
    //Activity Stream
    public static let KeyTopSitesCacheIsValid = "topSitesCacheIsValid"
    public static let KeyTopSitesCacheSize = "topSitesCacheSize"
    public static let KeyNewTab = "NewTabPrefKey"
    public static let ASPocketStoriesVisible = "ASPocketStoriesVisible"
    public static let ASRecentHighlightsVisible = "ASRecentHighlightsVisible"
    public static let ASBookmarkHighlightsVisible = "ASBookmarkHighlightsVisible"
    public static let ASLastInvalidation = "ASLastInvalidation"
    public static let KeyUseCustomSyncTokenServerOverride = "useCustomSyncTokenServerOverride"
    public static let KeyCustomSyncTokenServerOverride = "customSyncTokenServerOverride"
    public static let KeyUseCustomFxAContentServer = "useCustomFxAContentServer"
    public static let KeyCustomFxAContentServer = "customFxAContentServer"
    public static let UseStageServer = "useStageSyncService"
    public static let KeyFxALastCommandIndex = "FxALastCommandIndex"
    public static let KeyFxAHandledCommands = "FxAHandledCommands"
    public static let AppExtensionTelemetryOpenUrl = "AppExtensionTelemetryOpenUrl"
    public static let AppExtensionTelemetryEventArray = "AppExtensionTelemetryEvents"
    public static let KeyBlockPopups = "blockPopups"
    
    // Widgetkit Key
    public static let WidgetKitSimpleTabKey = "WidgetKitSimpleTabKey"
    public static let WidgetKitSimpleTopTab = "WidgetKitSimpleTopTab"
>>>>>>> parent of 4e81b3f2d (Remove search engine switching, Neeva branding and Search Engine view modifications)
}

extension Defaults {
    static func BoolKey(_ key: String, suite: UserDefaults = .standard) -> Key<Bool> {
        Key<Bool>(key, default: false, suite: suite)
    }
}

extension UserDefaults {
    public func clearProfilePrefs() {
        for key in dictionaryRepresentation().keys {
            if key.hasPrefix("profile") {
                UserDefaults.standard.removeObject(forKey: key)
            }
        }
    }
}
