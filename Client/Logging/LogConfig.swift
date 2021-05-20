//
//  File.swift
//  
//
//  Created by Macy Ngan on 5/1/21.
//

import Foundation

public struct LogConfig {
    public enum Interaction: String {
        case OpenNeevaMenu // Open neeva menu
        case OpenShield // Open tracking shield
        case TapReload // Tap reload page from url bar

        // neeva menu
        case OpenHome // Open home from neeva menu
        case OpenSpaces // Open spaces from neeva menu
        case OpenDownloads // Open downloads from neeva menu
        case OpenHistory // Open history from neeva menu
        case OpenSetting // Open settings from neeva menu
        case OpenSendFeedback // Open send feedback from neeva menu

        // tracking shield
        case TurnOnBlockTracking // Turn on block tracking from shield
        case TurnOffBlockTracking // Turn on block tracking from shield

        // settings
        case SettingSignin // Sign in from setting
        case SettingAccountSettings // Click search setting/account setting
        case SettingDefaultBrowser // Click default browser in setting
        case SettingSignout // Click sign out in setting
        case ViewDataManagement // Click Data Management in setting
        case ViewTrackingProtection // Click Tracking Protection in setting
        case ViewPrivacyPolicy // Click Privacy Policy in setting
        case ViewShowTour // Click Show Tour in setting
        case ViewHelp // Click Help in setting
        case ViewLicenses // Click Licenses in setting
        case ViewTerms // Click Terms in setting

        case ClearPrivateData // Click Clear Private Data in Data Management
        case ClearAllWebsiteData // Click Clear All Website Data in Data Management > Website Data

        case ShowReaderMode // Show reader mode

        // First Run
        case FirstRunSignUp // Click sign up on first run
        case FirstRunSignin // Click sign in on first run
        case FirstRunSkipToBrowser // Click skip to browser on first run

        // promo card
        case PromoSignin // Sign in from promo card
        case PromoDefaultBrowser // Click set default browser from promo
        case CloseDefaultBrowserPromo // Close default browser promo card

        // bottom nav
        case ShowTabTray // Click tab button to see all available tabs
        case HideTabTray // Click done button to hide the tab tray
        case ClickNewTabButton // Click the plus new tab button
        case ClickShareButton // Click the share button
        case TurnOnIncognitoMode // Click turn on incognito mode button
        case TurnOffIncognitoMode // Click turn off incognito mode button
        case SaveToSpace // Click bookmark button to save to space
        case ClickBack // Click back button to navigate to previous page
        case ClickForward // Click forward button to navigate to next page
    }

    public struct Attribute {
        public static let IsInPrivateMode = "IsInPrivateMode" // Is selected tab in private mode
        public static let NormalTabsOpened = "NormalTabsOpened" // Number of normal tabs opened
        public static let PrivateTabsOpened = "PrivateTabsOpened" // Number of incognito tabs opened
        public static let UserInterfaceStyle = "UserInterfaceStyle" // User theme setting, i.e dark, light
        public static let DeviceOrientation = "DeviceOrientation" // Device orientation, i.e. portrait, landscape
        public static let DeviceScreenSize = "DeviceScreenSize" // Device screen size width x height
        public static let isUserSignedIn = "IsUserSignedIn" // Is user signed in
    }
}
