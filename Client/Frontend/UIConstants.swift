/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import Foundation
import Shared
import SwiftUI

extension UIColor {
    // These are defaults from http://design.firefox.com/photon/visuals/color.html
    struct Defaults {
        static let LightBeige = UIColor(rgb: 0xf0e6dc)
        static let SystemGray01 = UIColor(rgb: 0x8E8E93)
    }
}

extension Color {
    public enum Tour {
        public static let Background = Color(UIColor.Tour.Background)
        public static let Title = Color(UIColor.Tour.Title)
        public static let Description = Color(UIColor.Tour.Description)
        public static let ButtonBackground = Color(UIColor.Tour.ButtonBackground)
        public static let ButtonText = Color(UIColor.Tour.ButtonText)
    }
}

public struct UIConstants {
    static let TextFieldHeight: CGFloat = 42

    // Portrait mode on a phone:
    static let TopToolbarPaddingTop: CGFloat = 4
    static let TopToolbarPaddingBottom: CGFloat = 12
    static let TopToolbarHeight: CGFloat = TextFieldHeight + TopToolbarPaddingTop + TopToolbarPaddingBottom

    // Landscape and tablet mode:
    static let TopToolbarHeightWithToolbarButtonsShowing: CGFloat = TextFieldHeight + (9 * 2)

    // Bottom bar when in portrait mode on a phone:
    static var ToolbarHeight: CGFloat = 46
    static var BottomToolbarHeight: CGFloat {
        get {
            return ToolbarHeight + safeArea.bottom
        }
    }

    static let SystemBlueColor = UIColor.Photon.Blue40

    // Static fonts
    static let DefaultChromeSize: CGFloat = 16
    static let DefaultChromeFont = UIFont.systemFont(ofSize: DefaultChromeSize, weight: UIFont.Weight.regular)

    /// JPEG compression quality for persisted screenshots. Must be between 0-1.
    static let ScreenshotQuality: Float = 0.3
    static let ActiveScreenshotQuality: CGFloat = 0.5

    static var safeArea: UIEdgeInsets {
        let window = UIApplication.shared.windows[0]
        return window.safeAreaInsets
    }

    static var enableBottomURLBar: Bool {
        FeatureFlag[.bottomURLBar] && UIDevice.current.userInterfaceIdiom != .pad
    }
}

extension UIColor {
    public struct TextField {
        public static func background(isPrivate: Bool) -> UIColor { return isPrivate ? .black : UIColor.systemFill }
        public static func textAndTint(isPrivate: Bool) -> UIColor { return isPrivate ? .white : .label }
        public static func disabledTextAndTint(isPrivate: Bool) -> UIColor { isPrivate ? UIColor(rgba: 0x3C3C4399) : .secondaryLabel }
        public static func placeholder(isPrivate: Bool) -> UIColor {
            if isPrivate {
                return .secondaryLabel.resolvedColor(with: UITraitCollection(userInterfaceStyle: .dark))
            } else {
                return .secondaryLabel
            }
        }
    }

    public struct Browser {
        public static let background = UIColor.DefaultBackground
        // Hidden in dark mode
        public static let urlBarDivider = UIColor.ui.adaptive.separator
        public static let tint = UIColor.DefaultTextAndTint
    }

    public struct LoadingBar {
        public static func start(_ isPrivate: Bool) -> UIColor { return !isPrivate ? UIColor.brand.adaptive.maya : UIColor.systemGray }
        public static func end(_ isPrivate: Bool) -> UIColor { return !isPrivate ? UIColor.brand.adaptive.maya : UIColor.systemGray }
    }

    public struct ToolbarButton {
        public static let selectedTint = UIColor.ui.adaptive.blue
        public static let disabledTint = UIColor.quaternaryLabel
    }


    public struct URLBar {
        // This text selection color is used in two ways:
        // 1) <UILabel>.background = textSelectionHighlight.withAlphaComponent(textSelectionHighlightAlpha)
        // To simulate text highlighting when the URL bar is tapped once, this is a background color to create a simulated selected text effect. The color will have an alpha applied when assigning it to the background.
        // 2) <UITextField>.tintColor = textSelectionHighlight.
        // When the text is in edit mode (tapping URL bar second time), this is assigned to the to set the selection (and cursor) color. The color is assigned directly to the tintColor.
        public typealias TextSelectionHighlight = (labelMode: UIColor, textFieldMode: UIColor?)
        public static func textSelectionHighlight(_ isPrivate: Bool) -> TextSelectionHighlight {
            if isPrivate {
                let color = UIColor(rgba: 0x64C7FF4C)
                return (labelMode: color.withAlphaComponent(0.25), textFieldMode: color)
            } else {
                return (labelMode: UIColor.textSelectionHighlight, textFieldMode: nil)
            }
        }

        public static func neevaMenuTint(_ isPrivate: Bool) -> UIColor? {
            return isPrivate ? UIColor(light: .brand.charcoal, dark: .brand.white) : nil
        }
    }

    public struct TabTray {
        public static let tabsButton = UIColor.label

        // Custom color for the background of the tab grid
        public static let background = UIColor.TrayBackground
    }

    public struct TopTabs {
        public static let background = UIColor.Photon.Grey80

        public static let tabBackgroundSelected = UIColor() { traits in
            switch traits.userInterfaceStyle {
            case .dark:
                return UIColor.Photon.Grey80
            default:
                return UIColor.Photon.Grey10
            }
        }

        public static let tabBackgroundUnselected = UIColor.Photon.Grey80

        public static let tabForegroundSelected = UIColor() { traits in
            switch traits.userInterfaceStyle {
            case .dark:
                return UIColor.Photon.Grey10
            default:
                return UIColor.Photon.Grey90
            }
        }
        public static let tabForegroundUnselected =  UIColor.Photon.Grey40

        public static func tabSelectedIndicatorBar(_ isPrivate: Bool) -> UIColor {
            return !isPrivate ? UIColor.Photon.Blue40 : UIColor.Defaults.SystemGray01
        }

        public static let buttonTint = UIColor.Photon.Grey40
        public static let closeButtonSelectedTab = UIColor() { traits in
            switch traits.userInterfaceStyle {
            case .dark:
                return UIColor.Photon.Grey10
            default:
                return UIColor.Photon.Grey80
            }
        }

        public static let closeButtonUnselectedTab = UIColor() { traits in
            switch traits.userInterfaceStyle {
            case .dark:
                return UIColor.Photon.Grey40
            default:
                return UIColor.Photon.Grey10
            }
        }

        public static let separator = UIColor() { traits in
            switch traits.userInterfaceStyle {
            case .dark:
                return UIColor.Photon.Grey50
            default:
                return UIColor.Photon.Grey70
            }
        }
    }

    public struct HomePanel {
        public static let topSitesBackground = UIColor.systemBackground
        public static let toolbarBackground = UIColor.DefaultBackground
        public static let toolbarHighlight = UIColor.ui.adaptive.blue
        public static let toolbarTint = UIColor.secondaryLabel
        public static let welcomeScreenText = UIColor.secondaryLabel
        public static let readingListActive = UIColor.DefaultTextAndTint
        public static let readingListDimmed = UIColor.Photon.Grey40
        public static let downloadedFileIcon = UIColor.secondaryLabel
    }
}

extension UIColor {
    public enum Tour {
        public static let Background = UIColor(named: "Tour-Background")!
        public static let Title = UIColor(named: "Tour-Title")!
        public static let Description = UIColor(named: "Tour-Description")!
        public static let ButtonBackground = UIColor(named: "Tour-Button-Background")!
        public static let ButtonText = UIColor(named: "Tour-Button-Text")!
    }
}
