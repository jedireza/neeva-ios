/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import Foundation
import Shared
import SwiftUI

extension UIColor {
    // These are defaults from http://design.firefox.com/photon/visuals/color.html
    struct Defaults {
        static let MobileGreyF = UIColor(rgb: 0x636369)
        static let iOSTextHighlightBlue = UIColor(rgb: 0xccdded) // This color should exactly match the ios text highlight
        static let Purple60A30 = UIColor(rgba: 0x8000d74c)
        static let MobilePrivatePurple = UIColor.Photon.Purple60
        static let PrivateBlue = UIColor(rgba: 0x64C7FF4C)
    // Reader Mode Sepia
        static let LightBeige = UIColor(rgb: 0xf0e6dc)
        static let SystemGray01 = UIColor(rgb: 0x8E8E93)
    }
}

extension Color {
    public struct Neeva {
        public struct Tour {
            public static let Background = Color(UIColor.Neeva.Tour.Background)
            public static let Title = Color(UIColor.Neeva.Tour.Title)
            public static let Description = Color(UIColor.Neeva.Tour.Description)
            public static let ButtonBackground = Color(UIColor.Neeva.Tour.ButtonBackground)
            public static let ButtonText = Color(UIColor.Neeva.Tour.ButtonText)
        }
    }
}

public struct UIConstants {
    static let DefaultPadding: CGFloat = 10
    static let SnackbarButtonHeight: CGFloat = 57
    static let TextFieldHeight: CGFloat = 42

    // Portrait mode on a phone:
    static let TopToolbarPaddingTop: CGFloat = 4
    static let TopToolbarPaddingBottom: CGFloat = 12
    static let TopToolbarHeight: CGFloat = TextFieldHeight + TopToolbarPaddingTop + TopToolbarPaddingBottom

    // Landscape and tablet mode:
    static let TopToolbarHeightWithToolbarButtonsShowing: CGFloat = TextFieldHeight + (9 * 2)

    // Bottom bar when in portrait mode on a phone:
    static var ToolbarHeight: CGFloat = 46
    static func BottomToolbarHeight(in window: UIWindow? = nil) -> CGFloat {
        return ToolbarHeight + (window?.safeAreaInsets.bottom ?? 0)
    }

    static let SystemBlueColor = UIColor.Photon.Blue40

    // Static fonts
    static let DefaultChromeSize: CGFloat = 16
    static let DefaultChromeSmallSize: CGFloat = 11
    static let PasscodeEntryFontSize: CGFloat = 36
    static let DefaultChromeFont = UIFont.systemFont(ofSize: DefaultChromeSize, weight: UIFont.Weight.regular)
    static let DefaultChromeSmallFontBold = UIFont.boldSystemFont(ofSize: DefaultChromeSmallSize)
    static let PasscodeEntryFont = UIFont.systemFont(ofSize: PasscodeEntryFontSize, weight: UIFont.Weight.bold)

    /// JPEG compression quality for persisted screenshots. Must be between 0-1.
    static let ScreenshotQuality: Float = 0.3
    static let ActiveScreenshotQuality: CGFloat = 0.5
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
        public static let background = UIColor.Neeva.DefaultBackground
        public static let urlBarDivider = UIColor.systemGray5
        public static let tint = UIColor.Neeva.DefaultTextAndTint
    }

    public struct LoadingBar {
        public static func start(_ isPrivate: Bool) -> UIColor { return !isPrivate ? UIColor.Neeva.Brand.Maya : UIColor.systemGray }
        public static func end(_ isPrivate: Bool) -> UIColor { return !isPrivate ? UIColor.Neeva.Brand.Maya : UIColor.systemGray }
    }

    public struct ToolbarButton {
        public static let selectedTint = UIColor.Neeva.UI.Blue40
        public static let disabledTint = UIColor.quaternaryLabel
    }


    public struct URLBar {
        public static let border = UIColor.Neeva.UI.Blue40
        public static func activeBorder(_ isPrivate: Bool) -> UIColor {
            return !isPrivate ? UIColor.Neeva.UI.Blue40.withAlphaComponent(0.3) : UIColor(rgb: 0x8E8E93)
        }
        public static let tint: UIColor = UIColor.Neeva.UI.Blue40.withAlphaComponent(0.3)

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
                return (labelMode: UIColor.Neeva.TextSelectionHighlight, textFieldMode: nil)
            }
        }

        public static let readerModeButtonSelected = UIColor.Neeva.UI.Blue40
        public static let readerModeButtonUnselected = UIColor.Neeva.UI.Gray50
        public static let pageOptionsSelected = UIColor.Neeva.UI.Blue40
        public static let pageOptionsUnselected = UIColor.Browser.tint

        public static func neevaMenuTint(_ isPrivate: Bool) -> UIColor? {
            return isPrivate ? UIColor.Neeva.NeevaMenuIncognito : nil
        }
    }

    public struct TabTray {
        public static let tabsButton = UIColor.label

        // Custom color for the background of the tab grid
        public static let background = UIColor() { traits in
            switch traits.userInterfaceStyle {
            case .dark:
                return UIColor.black
            default:
                return UIColor.Neeva.UI.DefaultBackground
            }
        }
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
        public static let privateModeButtonOffTint = buttonTint
        public static let privateModeButtonOnTint = UIColor.Photon.Grey10
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
        public static let toolbarBackground = UIColor.Neeva.DefaultBackground
        public static let toolbarHighlight = UIColor.Neeva.UI.Blue40
        public static let toolbarTint = UIColor.secondaryLabel
        public static let panelBackground = UIColor.systemBackground
        public static let welcomeScreenText = UIColor.secondaryLabel
        public static let siteTableHeaderBorder = UIColor.Neeva.UI.Gray30.withAlphaComponent(0.8)
        public static let readingListActive = UIColor.Neeva.DefaultTextAndTint
        public static let readingListDimmed = UIColor.Photon.Grey40
        public static let downloadedFileIcon = UIColor.secondaryLabel
    }
    
    public struct PopupMenu {
        public static let background = UIColor.Neeva.MenuBackground
        public static let foreground = UIColor.Browser.background
        public static let textColor = UIColor.label
        public static let secondaryTextColor = UIColor.secondaryLabel
        public static let buttonColor = UIColor.label
        public static let disabledButtonColor = UIColor.secondaryLabel

    }
}

extension UIColor {
    public struct Neeva {
        public struct Tour {
            public static let Background = UIColor(named: "Tour-Background")!
            public static let Title = UIColor(named: "Tour-Title")!
            public static let Description = UIColor(named: "Tour-Description")!
            public static let ButtonBackground = UIColor(named: "Tour-Button-Background")!
            public static let ButtonText = UIColor(named: "Tour-Button-Text")!
        }
    }
}
