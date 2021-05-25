/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import Foundation

// Convenience reference to these normal mode colors which are used in a few color classes.
fileprivate let defaultBackground = UIColor.tertiarySystemBackground
fileprivate let defaultSeparator = UIColor.Photon.Grey60
fileprivate let defaultTextAndTint = UIColor.Photon.Grey10

fileprivate class DarkTableViewColor: TableViewColor {
    override var rowBackground: UIColor { return UIColor.Photon.Grey70 }
    override var rowText: UIColor { return defaultTextAndTint }
    override var rowDetailText: UIColor { return UIColor.Photon.Grey30 }
    override var disabledRowText: UIColor { return UIColor.Photon.Grey40 }
    override var separator: UIColor { return UIColor.Photon.Grey60 }
    override var headerBackground: UIColor { return UIColor.Photon.Grey80 }
    override var headerTextLight: UIColor { return UIColor.Photon.Grey30 }
    override var headerTextDark: UIColor { return UIColor.Photon.Grey30 }
    override var syncText: UIColor { return defaultTextAndTint }
    override var accessoryViewTint: UIColor { return UIColor.Photon.Grey40 }
    override var selectedBackground: UIColor { return UIColor.Custom.selectedHighlightDark }
}

fileprivate class DarkActionMenuColor: ActionMenuColor {
    override var foreground: UIColor { return UIColor.Photon.White100 }
    override var iPhoneBackgroundBlurStyle: UIBlurEffect.Style { return UIBlurEffect.Style.dark }
    override var iPhoneBackground: UIColor { return defaultBackground.withAlphaComponent(0.9) }
    override var closeButtonBackground: UIColor { return defaultBackground }
}

fileprivate class DarkTabTrayColor: TabTrayColor {
    override var tabTitleText: UIColor { return defaultTextAndTint }
    override var tabTitleBlur: UIBlurEffect.Style { return UIBlurEffect.Style.dark }
    override var cellBackground: UIColor { return defaultBackground }
    override var toolbarButtonTint: UIColor { return defaultTextAndTint }
    override var privateModeButtonOnTint: UIColor { return UIColor.black }
    override var cellCloseButton: UIColor { return defaultTextAndTint }
    override var cellTitleBackground: UIColor { return UIColor.Photon.Grey70 }
    override var faviconTint: UIColor { return UIColor.Photon.White100 }
}

fileprivate class DarkSnackBarColor: SnackBarColor {
// Use defaults
}

fileprivate class DarkGeneralColor: GeneralColor {
    override var settingsTextPlaceholder: UIColor { return UIColor.Photon.Grey40 }
    override var faviconBackground: UIColor { return UIColor.Photon.White100 }
    override var passcodeDot: UIColor { return UIColor.Photon.Grey40 }
    override var switchToggle: UIColor { return UIColor.Photon.Grey40 }
}

class DarkTheme: NormalTheme {
    override var name: String { return BuiltinThemeName.dark.rawValue }
    override var tableView: TableViewColor { return DarkTableViewColor() }
    override var tabTray: TabTrayColor { return DarkTabTrayColor() }
    override var snackbar: SnackBarColor { return DarkSnackBarColor() }
    override var general: GeneralColor { return DarkGeneralColor() }
    override var actionMenu: ActionMenuColor { return DarkActionMenuColor() }
    override var userInterfaceStyle: UIUserInterfaceStyle { .dark }
}
