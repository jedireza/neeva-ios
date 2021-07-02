/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */
import Foundation
import Shared

protocol PrivateModeUI {
    func applyUIMode(isPrivate: Bool)
}

// Convenience reference to these normal mode colors which are used in a few color classes.
fileprivate let defaultBackground = UIColor(light: .white, dark: .tertiarySystemBackground)

extension UIColor {
    enum legacyTheme {
        enum tableView {
            static let rowBackground = UIColor(light: .Photon.White100, dark: .Photon.Grey70)
            static let rowText = UIColor(light: .Photon.Grey90, dark: .Photon.Grey90)
            static let rowDetailText = UIColor(light: .Photon.Grey60, dark: .Photon.Grey30)
            static let disabledRowText = UIColor.Photon.Grey40
            static let separator = UIColor(light: .Photon.Grey30, dark: .Photon.Grey60)
            static let headerBackground = UIColor(light: .white, dark: .Photon.Grey80)
            // Used for table headers in Settings and Photon menus
            static let headerTextLight = UIColor(light: .Photon.Grey50, dark: .Photon.Grey30)
            // Used for table headers in home panel tables
            static let headerTextDark = UIColor(light: .Photon.Grey90, dark: .Photon.Grey30)
            static let selectedBackground = UIColor(light: .init(rgb: 0xd1d1d6), dark: .init(rgb: 0x2D2D2D))
        }

        enum actionMenu {
            static let foreground = UIColor(light: .Photon.Grey80, dark: .Photon.White100)
            static let iPhoneBackgroundBlurStyle = UIBlurEffect.Style.regular
            static let iPhoneBackground = defaultBackground.withAlphaComponent(0.9)
            static let closeButtonBackground = defaultBackground
        }
    }
}
