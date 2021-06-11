/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */
import Foundation

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
    var accessoryViewTint: UIColor { return UIColor.Photon.Grey40 }
    var selectedBackground: UIColor { return UIColor.Custom.selectedHighlightLight }
}

class ActionMenuColor {
    var foreground: UIColor { return defaultTextAndTint }
    var iPhoneBackgroundBlurStyle: UIBlurEffect.Style { return UIBlurEffect.Style.light }
    var iPhoneBackground: UIColor { return defaultBackground.withAlphaComponent(0.9) }
    var closeButtonBackground: UIColor { return defaultBackground }
}

protocol Theme {
    var name: String { get }
    var tableView: TableViewColor { get }
    var actionMenu: ActionMenuColor { get }
    var userInterfaceStyle: UIUserInterfaceStyle { get }
}

class NormalTheme: Theme {
    var name: String { return BuiltinThemeName.normal.rawValue }
    var tableView: TableViewColor { return TableViewColor() }
    var actionMenu: ActionMenuColor { return ActionMenuColor() }
    var userInterfaceStyle: UIUserInterfaceStyle { .light }
}
