/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */
import Foundation

class ThemeManager {
    static let instance = ThemeManager()

    var current: Theme = NormalTheme() {
        didSet {
            NotificationCenter.default.post(name: .DisplayThemeChanged, object: nil)
        }
    }

    var currentName: BuiltinThemeName {
        return BuiltinThemeName(rawValue: ThemeManager.instance.current.name) ?? .normal
    }

    let systemThemeIsOn: Bool = true

    // UIViewControllers / UINavigationControllers need to have `preferredStatusBarStyle` and call this.
    var statusBarStyle: UIStatusBarStyle {
        if #available(iOS 13.0, *) {
            if UIScreen.main.traitCollection.userInterfaceStyle == .dark && currentName == .normal {
                return .darkContent
            }
        }
        return currentName == .dark ? .lightContent : .default
    }

    @available(iOS 13.0, *)
    var userInterfaceStyle: UIUserInterfaceStyle {
        switch currentName {
        case .dark:
            return .dark
        default:
            return .light
        }
    }
}

fileprivate func themeFrom(name: String?) -> Theme {
    guard let name = name, let theme = BuiltinThemeName(rawValue: name) else { return NormalTheme() }
    switch theme {
    case .dark:
        return DarkTheme()
    default:
        return NormalTheme()
    }
}
