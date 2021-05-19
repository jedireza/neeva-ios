/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */
import Foundation
import NeevaSupport

protocol Themeable: AnyObject {
    func applyTheme()
}

protocol PrivateModeUI {
    func applyUIMode(isPrivate: Bool)
}

extension UIColor {
    static var theme: Theme {
        return ThemeManager.instance.current
    }
}

enum BuiltinThemeName: String {
    case normal
    case dark
}

// Convenience reference to these normal mode colors which are used in a few color classes.
fileprivate let defaultBackground = UIColor.white
fileprivate let defaultSeparator = UIColor.Photon.Grey30
fileprivate let defaultTextAndTint = UIColor.Photon.Grey80

class TableViewColor {
    var rowBackground: UIColor { return UIColor.Photon.White100 }
    var rowText: UIColor { return UIColor.Photon.Grey90 }
    var rowDetailText: UIColor { return UIColor.Photon.Grey60 }
    var disabledRowText: UIColor { return UIColor.Photon.Grey40 }
    var separator: UIColor { return defaultSeparator }
    var headerBackground: UIColor { return defaultBackground }
    // Used for table headers in Settings and Photon menus
    var headerTextLight: UIColor { return UIColor.Photon.Grey50 }
    // Used for table headers in home panel tables
    var headerTextDark: UIColor { return UIColor.Photon.Grey90 }
    var rowActionAccessory: UIColor { return UIColor.Photon.Blue40 }
    var controlTint: UIColor { return rowActionAccessory }
    var syncText: UIColor { return defaultTextAndTint }
    var errorText: UIColor { return UIColor.Photon.Red50 }
    var warningText: UIColor { return UIColor.Photon.Orange50 }
    var accessoryViewTint: UIColor { return UIColor.Photon.Grey40 }
    var selectedBackground: UIColor { return UIColor.Custom.selectedHighlightLight }
}

class ActionMenuColor {
    var foreground: UIColor { return defaultTextAndTint }
    var iPhoneBackgroundBlurStyle: UIBlurEffect.Style { return UIBlurEffect.Style.light }
    var iPhoneBackground: UIColor { return defaultBackground.withAlphaComponent(0.9) }
    var closeButtonBackground: UIColor { return defaultBackground }
}

class TabTrayColor {
    var tabTitleText: UIColor { return UIColor.black }
    var tabTitleBlur: UIBlurEffect.Style { return UIBlurEffect.Style.extraLight }
    var background: UIColor { return UIColor.Photon.Grey80 }
    var cellBackground: UIColor { return defaultBackground }
    var toolbar: UIColor { return defaultBackground }
    var toolbarButtonTint: UIColor { return defaultTextAndTint }
    var privateModeLearnMore: UIColor { return UIColor.Photon.Purple60 }
    var privateModePurple: UIColor { return UIColor.Photon.Purple60 }
    var privateModeButtonOffTint: UIColor { return toolbarButtonTint }
    var privateModeButtonOnTint: UIColor { return UIColor.Photon.Grey10 }
    var cellCloseButton: UIColor { return UIColor.Photon.Grey50 }
    var cellTitleBackground: UIColor { return UIColor.clear }
    var faviconTint: UIColor { return UIColor.black }
    var searchBackground: UIColor { return UIColor.Photon.Grey30 }
    var toggleButon: UIColor { return UIColor.black }
}

class TopTabsColor {
    var background: UIColor { return UIColor.Photon.Grey80 }
    var tabBackgroundSelected: UIColor { return UIColor.Photon.Grey10 }
    var tabBackgroundUnselected: UIColor { return UIColor.Photon.Grey80 }
    var tabForegroundSelected: UIColor { return UIColor.Photon.Grey90 }
    var tabForegroundUnselected: UIColor { return UIColor.Photon.Grey40 }
    func tabSelectedIndicatorBar(_ isPrivate: Bool) -> UIColor {
        return !isPrivate ? UIColor.Photon.Blue40 : UIColor.Defaults.SystemGray01
    }
    var buttonTint: UIColor { return UIColor.Photon.Grey40 }
    var privateModeButtonOffTint: UIColor { return buttonTint }
    var privateModeButtonOnTint: UIColor { return UIColor.Photon.Grey10 }
    var closeButtonSelectedTab: UIColor { return tabBackgroundUnselected }
    var closeButtonUnselectedTab: UIColor { return tabBackgroundSelected }
    var separator: UIColor { return UIColor.Photon.Grey70 }
}

class HomePanelColor {
    var toolbarBackground: UIColor { return defaultBackground }
    var toolbarHighlight: UIColor { return UIColor.Photon.Blue40 }
    var toolbarTint: UIColor { return UIColor.Photon.Grey50 }

    var panelBackground: UIColor { return UIColor.Photon.White100 }

    var separator: UIColor { return defaultSeparator }
    var border: UIColor { return UIColor.Photon.Grey60 }
    var buttonContainerBorder: UIColor { return separator }
    
    var welcomeScreenText: UIColor { return UIColor.Photon.Grey50 }
    
    var siteTableHeaderBorder: UIColor { return UIColor.Photon.Grey30.withAlphaComponent(0.8) }

    var topSitesFavBg: UIColor { return UIColor.Neeva.UI.Gray97 }
    var topSitesLabel: UIColor { return UIColor.Neeva.UI.Gray60 }

    var activityStreamHeaderText: UIColor { return UIColor.Photon.Grey50 }
    var activityStreamCellTitle: UIColor { return UIColor.black }
    var activityStreamCellDescription: UIColor { return UIColor.Photon.Grey60 }

    var readingListActive: UIColor { return defaultTextAndTint }
    var readingListDimmed: UIColor { return UIColor.Photon.Grey40 }
    
    var downloadedFileIcon: UIColor { return UIColor.Photon.Grey60 }
    
    var historyHeaderIconsBackground: UIColor { return UIColor.Photon.White100 }

    var searchSuggestionPillBackground: UIColor { return UIColor.Photon.White100 }
    var searchSuggestionPillForeground: UIColor { return UIColor.Photon.Blue40 }
}

class SnackBarColor {
    var highlight: UIColor { return UIColor.Defaults.iOSTextHighlightBlue.withAlphaComponent(0.9) }
    var highlightText: UIColor { return UIColor.Photon.Blue40 }
    var border: UIColor { return UIColor.Photon.Grey30 }
    var title: UIColor { return UIColor.Photon.Blue40 }
}

class GeneralColor {
    var faviconBackground: UIColor { return UIColor.clear }
    var passcodeDot: UIColor { return UIColor.Photon.Grey60 }
    var highlightBlue: UIColor { return UIColor.Photon.Blue40 }
    var destructiveRed: UIColor { return UIColor.Photon.Red50 }
    var separator: UIColor { return defaultSeparator }
    var settingsTextPlaceholder: UIColor { return UIColor.Photon.Grey40 }
    var controlTint: UIColor { return UIColor.Photon.Blue40 }
    var switchToggle: UIColor { return UIColor.Photon.Grey90A40 }
}

class PopupMenu {
    var background: UIColor { return UIColor(rgb: 0xF2F2F7); }
    var foreground: UIColor { return UIColor.white }
    var textColor: UIColor { return UIColor.black }
    var secondaryTextColor: UIColor { return UIColor.Photon.Grey60 }
    var buttonColor: UIColor { return UIColor.black }
    var disabledButtonColor: UIColor { return UIColor.Custom.disabledButtonLightGray}
}

protocol Theme {
    var name: String { get }
    var tableView: TableViewColor { get }
    var tabTray: TabTrayColor { get }
    var topTabs: TopTabsColor { get }
    var homePanel: HomePanelColor { get }
    var snackbar: SnackBarColor { get }
    var general: GeneralColor { get }
    var actionMenu: ActionMenuColor { get }
    var switchToggleTheme: GeneralColor { get }
    var userInterfaceStyle: UIUserInterfaceStyle { get }
    var popupMenu: PopupMenu { get }
}

class NormalTheme: Theme {
    var name: String { return BuiltinThemeName.normal.rawValue }
    var tableView: TableViewColor { return TableViewColor() }
    var tabTray: TabTrayColor { return TabTrayColor() }
    var topTabs: TopTabsColor { return TopTabsColor() }
    var homePanel: HomePanelColor { return HomePanelColor() }
    var snackbar: SnackBarColor { return SnackBarColor() }
    var general: GeneralColor { return GeneralColor() }
    var actionMenu: ActionMenuColor { return ActionMenuColor() }
    var switchToggleTheme: GeneralColor { return GeneralColor() }
    var userInterfaceStyle: UIUserInterfaceStyle { .light }
    var popupMenu: PopupMenu { return PopupMenu() }
}
