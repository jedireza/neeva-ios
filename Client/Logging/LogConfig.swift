// Copyright Neeva. All rights reserved.

import Foundation
import Shared

public struct LogConfig {
    public enum Interaction: String {
        case OpenNeevaMenu  // Open neeva menu
        case OpenShield  // Open tracking shield
        case TapReload  // Tap reload page from url bar

        // bottom nav
        case ShowTabTray  // Click tab button to see all available tabs
        case HideTabTray  // Click done button to hide the tab tray
        case ClickNewTabButton  // Click the plus new tab button
        case ClickShareButton  // Click the share button
        case TurnOnIncognitoMode  // Click turn on incognito mode button
        case TurnOffIncognitoMode  // Click turn off incognito mode button
        case SaveToSpace  // Click bookmark button to save to space
        case ClickBack  // Click back button to navigate to previous page
        case ClickForward  // Click forward button to navigate to next page

        // tracking shield
        case TurnOnBlockTracking  // Turn on block tracking from shield
        case TurnOffBlockTracking  // Turn on block tracking from shield

        // neeva menu
        case OpenHome  // Open home from neeva menu
        case OpenSpaces  // Open spaces from neeva menu
        case OpenDownloads  // Open downloads from neeva menu
        case OpenHistory  // Open history from neeva menu
        case OpenSetting  // Open settings from neeva menu
        case OpenSendFeedback  // Open send feedback from neeva menu

        // settings
        case SettingSignin  // Sign in from setting
        case SettingAccountSettings  // Click search setting/account setting
        case SettingDefaultBrowser  // Click default browser in setting
        case SettingSignout  // Click sign out in setting
        case ViewDataManagement  // Click Data Management in setting
        case ViewTrackingProtection  // Click Tracking Protection in setting
        case ViewPrivacyPolicy  // Click Privacy Policy in setting
        case ViewShowTour  // Click Show Tour in setting
        case ViewHelpCenter  // Click Help Center in setting
        case ViewLicenses  // Click Licenses in setting
        case ViewTerms  // Click Terms in setting

        case ClearPrivateData  // Click Clear Private Data in Data Management
        case ClearAllWebsiteData  // Click Clear All Website Data in Data Management > Website Data

        // First Run
        case FirstRunSignupWithApple // Click Sign up with Apple on first run
        case FirstRunOtherSignUpOptions  // Click Other sign up options on first run
        case FirstRunSignin  // Click sign in on first run
        case FirstRunSkipToBrowser  // Click skip to browser on first run
        case FirstRunImpression  // First run screen rendered
        case LoginAfterFirstRun  // Login after first run

        // promo card
        case PromoSignin  // Sign in from promo card
        case PromoDefaultBrowser  // Click set default browser from promo
        case CloseDefaultBrowserPromo  // Close default browser promo card

        // selected suggestion
        case QuerySuggestion
        case MemorizedSuggestion
        case HistorySuggestion
        case AutocompleteSuggestion
        case PersonalSuggestion
        case BangSuggestion
        case LensSuggestion
        case NoSuggestion
        case FindOnPageSuggestion

        // referral promo
        case OpenReferralPromo  // Open referral promo
        case CloseReferralPromo  // Close referral promo card

        // performance
        case AppCrashWithPageLoad  // App Crash # With Page load #

        // spaces
        case SpacesUIVisited
        case SpacesDetailUIVisited
        case SpacesDetailEntityClicked
        case SpacesDetailEditButtonClicked
        case SpacesDetailShareButtonClicked
        case OwnerSharedSpace
        case FollowerSharedSpace
        case RecommendedSpaceVisited
    }

    // Specify a comma separated string with these values to
    // enable specific logging category on the server:
    // ios_logging_categories.experiment.yaml
    public enum InteractionCategory: String, CaseIterable {
        case UI = "UI"
        case NeevaMenu = "NeevaMenu"
        case Settings = "Settings"
        case Suggestions = "Suggestions"
        case ReferralPromo = "ReferralPromo"
        case Performance = "Performance"
        case FirstRun = "FirstRun"
        case PromoCard = "PromoCard"
        case Spaces = "Spaces"
    }

    public static var enabledLoggingCategories: Set<InteractionCategory>?

    public static func featureFlagEnabled(for category: InteractionCategory) -> Bool {
        if category == .FirstRun {
            return true
        }

        if enabledLoggingCategories == nil {
            enabledLoggingCategories = Set<InteractionCategory>()
            NeevaFeatureFlags[.loggingCategories].components(separatedBy: ",").forEach { token in
                if let category = InteractionCategory(
                    rawValue: token.stringByTrimmingLeadingCharactersInSet(.whitespaces)
                ) {
                    enabledLoggingCategories?.insert(category)
                }
            }
        }
        return enabledLoggingCategories?.contains(category) ?? false
    }

    public static func category(for interaction: Interaction) -> InteractionCategory {
        switch interaction {
        case .OpenNeevaMenu: return .UI
        case .OpenShield: return .UI
        case .TapReload: return .UI
        case .ShowTabTray: return .UI
        case .HideTabTray: return .UI
        case .ClickNewTabButton: return .UI
        case .ClickShareButton: return .UI
        case .TurnOnIncognitoMode: return .UI
        case .TurnOffIncognitoMode: return .UI
        case .SaveToSpace: return .UI
        case .ClickBack: return .UI
        case .ClickForward: return .UI
        case .TurnOnBlockTracking: return .UI
        case .TurnOffBlockTracking: return .UI

        case .OpenHome: return .NeevaMenu
        case .OpenSpaces: return .NeevaMenu
        case .OpenDownloads: return .NeevaMenu
        case .OpenHistory: return .NeevaMenu
        case .OpenSetting: return .NeevaMenu
        case .OpenSendFeedback: return .NeevaMenu

        case .SettingSignin: return .Settings
        case .SettingAccountSettings: return .Settings
        case .SettingDefaultBrowser: return .Settings
        case .SettingSignout: return .Settings
        case .ViewDataManagement: return .Settings
        case .ViewTrackingProtection: return .Settings
        case .ViewPrivacyPolicy: return .Settings
        case .ViewShowTour: return .Settings
        case .ViewHelpCenter: return .Settings
        case .ViewLicenses: return .Settings
        case .ViewTerms: return .Settings
        case .ClearPrivateData: return .Settings
        case .ClearAllWebsiteData: return .Settings

        case .FirstRunSignupWithApple: return .FirstRun
        case .FirstRunOtherSignUpOptions: return .FirstRun
        case .FirstRunSignin: return .FirstRun
        case .FirstRunSkipToBrowser: return .FirstRun
        case .FirstRunImpression: return .FirstRun
        case .LoginAfterFirstRun: return .FirstRun

        case .PromoSignin: return .PromoCard
        case .PromoDefaultBrowser: return .PromoCard
        case .CloseDefaultBrowserPromo: return .PromoCard

        case .QuerySuggestion: return .Suggestions
        case .MemorizedSuggestion: return .Suggestions
        case .HistorySuggestion: return .Suggestions
        case .AutocompleteSuggestion: return .Suggestions
        case .PersonalSuggestion: return .Suggestions
        case .BangSuggestion: return .Suggestions
        case .NoSuggestion: return .Suggestions
        case .LensSuggestion: return .Suggestions
        case .FindOnPageSuggestion: return .Suggestions

        case .OpenReferralPromo: return .ReferralPromo
        case .CloseReferralPromo: return .ReferralPromo

        case .AppCrashWithPageLoad: return .Performance

        case .SpacesUIVisited: return .Spaces
        case .SpacesDetailUIVisited: return .Spaces
        case .SpacesDetailEntityClicked: return .Spaces
        case .SpacesDetailEditButtonClicked: return .Spaces
        case .SpacesDetailShareButtonClicked: return .Spaces
        case .RecommendedSpaceVisited: return .Spaces
        case .OwnerSharedSpace: return .Spaces
        case .FollowerSharedSpace: return .Spaces
        }
    }

    public struct Attribute {
        /// Is selected tab in private mode
        public static let IsInPrivateMode = "IsInPrivateMode"
        /// Number of normal tabs opened
        public static let NormalTabsOpened = "NormalTabsOpened"
        /// Number of incognito tabs opened
        public static let PrivateTabsOpened = "PrivateTabsOpened"
        /// User theme setting, i.e dark, light
        public static let UserInterfaceStyle = "UserInterfaceStyle"
        /// Device orientation, i.e. portrait, landscape
        public static let DeviceOrientation = "DeviceOrientation"
        /// Device screen size width x height
        public static let DeviceScreenSize = "DeviceScreenSize"
        /// Is user signed in
        public static let isUserSignedIn = "IsUserSignedIn"
    }

    public struct SuggestionAttribute {
        /// suggestion position
        public static let suggestionPosition = "suggestionPosition"
        /// chip suggestion position
        public static let chipSuggestionPosition = "chipSuggestionPosition"
        /// number of characters typed in url bar
        public static let urlBarNumOfCharsTyped = "urlBarNumOfCharsTyped"
        /// suggestion impression position index
        public static let suggestionTypePosition = "SuggestionTypeAtPosition"
        /// number of total chip suggestions
        public static let numberOfChipSuggestions = "NumberOfChipSuggestions"
        /// annotation type at position
        public static let annotationTypeAtPosition = "AnnotationTypeAtPosition"
        public static let numberOfMemorizedSuggestions = "NumberOfMemorizedSuggestions"
        public static let numberOfHistorySuggestions = "NumberOfHistorySuggestions"
        public static let numberOfPersonalSuggestions = "NumberOfPersonalSuggestions"
        public static let numberOfCalculatorAnnotations = "NumberOfCalculatorAnnotations"
        public static let numberOfWikiAnnotations = "NumberOfWikiAnnotations"
        public static let numberOfStockAnnotations = "NumberOfStockAnnotations"
    }

    public struct SpacesAttribute {
        public static let isShared = "isShared"
        public static let isPublic = "isPublic"
        public static let numberOfSpaceEntities = "NumberOfSpaceEntities"
    }
}
