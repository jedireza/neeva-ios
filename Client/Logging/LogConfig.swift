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
        case FirstRunSignUp  // Click sign up on first run
        case FirstRunSignin  // Click sign in on first run
        case FirstRunSkipToBrowser  // Click skip to browser on first run

        // promo card
        case PromoSignin  // Sign in from promo card
        case PromoDefaultBrowser  // Click set default browser from promo
        case CloseDefaultBrowserPromo  // Close default browser promo card

        // selected suggestion
        case QuerySuggestion
        case NavSuggestion
        case HistorySuggestion
        case AutocompleteSuggestion
        case URLSuggestion
        case BangSuggestion
        case NoSuggestion
    }

    public enum InteractionCategory {
        case UI
        case NeevaMenu
        case Settings
        case FirstRun
        case Suggestions
    }

    public static func featureFlagEnabled(for category: InteractionCategory) -> Bool {
        switch category {
        case .Suggestions:
            return NeevaFeatureFlags[.suggestionsLogging]
        default:
            return false
        }
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

        case .FirstRunSignUp: return .FirstRun
        case .FirstRunSignin: return .FirstRun
        case .FirstRunSkipToBrowser: return .FirstRun
        case .PromoSignin: return .FirstRun
        case .PromoDefaultBrowser: return .FirstRun
        case .CloseDefaultBrowserPromo: return .FirstRun

        case .QuerySuggestion: return .Suggestions
        case .NavSuggestion: return .Suggestions
        case .HistorySuggestion: return .Suggestions
        case .AutocompleteSuggestion: return .Suggestions
        case .URLSuggestion: return .Suggestions
        case .BangSuggestion: return .Suggestions
        case .NoSuggestion: return .Suggestions
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
}
