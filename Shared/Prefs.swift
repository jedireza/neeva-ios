// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

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
    public static let lastSessionPrivate = Defaults.BoolKey("wasLastSessionPrivate")

    // explicit/implicit settings
    public static let contextMenuShowLinkPreviews = Defaults.Key(
        "profile.ContextMenuShowLinkPreviews", default: true)
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
        "profile.tracking_protection.unblockedDomains", default: [])
    public static let customSearchEngine = Defaults.Key<String?>("profile_customSearchEngine")

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
    public static let neevaUserInfo = Defaults.Key<[String: String]>("UserInfo", default: [:])

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

    public static let ratingsCardHidden = Defaults.BoolKey("RatingsCardHidden")

    public static let notificationToken = Defaults.Key<String?>("notificationToken")

    // spaces
    public static let seenSpacesIntro = Defaults.BoolKey("spacesIntroSeen")
    public static let seenSpacesShareIntro = Defaults.BoolKey("spacesShareIntroSeen")
    public static let showDescriptions = Defaults.BoolKey("showSpaceEntityDescription")

    // cheatsheet
    public static let seenCheatsheetIntro = Defaults.BoolKey("cheatsheetIntroSeen")
    public static let cheatsheetDebugQuery = Defaults.BoolKey("cheatsheetDebugQuery")
    public static let showNeevaMenuWillMove = Defaults.BoolKey("showNeevaMenuWillMove", default: false)

    // notification
    public static let lastScheduledNeevaPromoID = Defaults.Key<String?>("lastScheduledNeevaPromoID")
    public static let lastNeevaPromoScheduledTimeInterval = Defaults.Key<Int?>(
        "lastNeevaPromoScheduledTimeInterval")
    public static let didRegisterNotificationTokenOnServer = Defaults.BoolKey(
        "didRegisterNotificationTokenOnServer")
    public static let productSearchPromoTimeInterval = Defaults.Key<Int>(
        "productSearchPromoTimeInterval", default: 259200)
    public static let newsProviderPromoTimeInterval = Defaults.Key<Int>(
        "newsProviderPromoTimeInterval", default: 86400)
    public static let fastTapPromoTimeInterval = Defaults.Key<Int>(
        "fastTapPromoTimeInterval", default: 432000)
    /// 0: Undecided, 1: Accepted, 2: Denied
    public static let notificationPermissionState = Defaults.Key<Int>(
        "notificationPermissionState", default: 0)
    public static let seenNotificationPermissionPromo = Defaults.BoolKey(
        "seenNotificationPermissionPromo")
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
    public static let tabGroupNames = Defaults.Key<[String: String]>("tabGroupNames", default: [:])
    public static let tabGroupExpanded = Defaults.Key<Set<String>>("tabGroupExpanded", default: [])

    public static let seenBlackFridayFollowPromo = Defaults.BoolKey("seenBlackFridayFollowPromo")
    public static let seenBlackFridayNotifyPromo = Defaults.BoolKey("seenBlackFridayNotifyPromo")

    // Feedback
    public static let feedbackBeingSent = Defaults.BoolKey("feedbackBeingSent")

    // preview mode
    public static let previewModeQueries = Defaults.Key<Set<String>>(
        "previewModeQueries", default: [])
    public static let signupPromptInterval = Defaults.Key<Int>("signupPromptInterval", default: 5)
    public static let maxQueryLimit = Defaults.Key<Int>("maxQueryLimit", default: 25)

    // crypto wallet
    public static let cryptoPhrases = Defaults.Key<String>("cryptoPhrases", default: "")
    public static let cryptoPublicKey = Defaults.Key<String>("cryptoPublicKey", default: "")
    public static let cryptoPrivateKey = Defaults.Key<String>("cryptoPrivateKey", default: "")
    public static let cryptoTransactionHashStore = Defaults.Key<Set<String>>(
        "cryptoTransactionHashStore", default: [])
    public static let sessionsPeerIDs = Defaults.Key<Set<String>>(
        "web3SessionsPeerIDs", default: [])

    // default browser
    public static let didDismissDefaultBrowserCard = Defaults.BoolKey(
        "profile.didDismissDefaultBrowserCard")
    public static let didShowDefaultBrowserInterstitial = Defaults.BoolKey(
        "didShowDefaultBrowserInterstitial")
    public static let didSetDefaultBrowser = Defaults.BoolKey(
        "didSetDefaultBrowser")

    public static let loggedDefaultBrowserExperiment = Defaults.BoolKey(
        "loggedDefaultBrowserExperiment", default: false)
    public static let lastDefaultBrowserPromptInteraction = Defaults.Key<String?>(
        "lastDefaultBrowserPromptInteraction")
}

extension Defaults {
    static func BoolKey(
        _ key: String,
        default defaultValue: Bool = false,
        suite: UserDefaults = .standard
    ) -> Key<Bool> {
        Key<Bool>(key, default: defaultValue, suite: suite)
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
