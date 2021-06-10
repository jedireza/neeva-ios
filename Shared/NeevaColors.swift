// Copyright Neeva. All rights reserved.

import UIKit
import SwiftUI

extension UIColor {
    public enum neeva {
        public enum brand {
            public static let blue = UIColor(named: "Brand/Blue", in: NeevaConstants.sharedBundle, compatibleWith: nil)!
            public static let seafoam = UIColor(named: "Brand/Seafoam", in: NeevaConstants.sharedBundle, compatibleWith: nil)!
            public static let polar = UIColor(named: "Brand/Polar", in: NeevaConstants.sharedBundle, compatibleWith: nil)!
            public static let pistachio = UIColor(named: "Brand/Pistachio", in: NeevaConstants.sharedBundle, compatibleWith: nil)!
            public static let offwhite = UIColor(named: "Brand/Offwhite", in: NeevaConstants.sharedBundle, compatibleWith: nil)!
            public static let red = UIColor(named: "Brand/Red", in: NeevaConstants.sharedBundle, compatibleWith: nil)!
            public static let orange = UIColor(named: "Brand/Orange", in: NeevaConstants.sharedBundle, compatibleWith: nil)!
            public static let peach = UIColor(named: "Brand/Peach", in: NeevaConstants.sharedBundle, compatibleWith: nil)!
            public static let yellow = UIColor(named: "Brand/Yellow", in: NeevaConstants.sharedBundle, compatibleWith: nil)!
            public static let pink = UIColor(named: "Brand/Pink", in: NeevaConstants.sharedBundle, compatibleWith: nil)!
            public static let green = UIColor(named: "Brand/Green", in: NeevaConstants.sharedBundle, compatibleWith: nil)!
            public static let mint = UIColor(named: "Brand/Mint", in: NeevaConstants.sharedBundle, compatibleWith: nil)!
            public static let maya = UIColor(named: "Brand/Maya", in: NeevaConstants.sharedBundle, compatibleWith: nil)!
            public static let gold = UIColor(named: "Brand/Gold", in: NeevaConstants.sharedBundle, compatibleWith: nil)!
            public static let purple = UIColor(named: "Brand/Purple", in: NeevaConstants.sharedBundle, compatibleWith: nil)!

            /// These colors have their light and dark mode values reversed from the standard color
            public enum variant {
                public static let purple = UIColor(named: "Brand/Purple Variant", in: NeevaConstants.sharedBundle, compatibleWith: nil)!
            }

            /// ⚠️ These colors do not automatically adapt to dark mode.
            public enum fixed {
                public static let charcoal = UIColor(named: "Brand/Charcoal", in: NeevaConstants.sharedBundle, compatibleWith: nil)!
                public static let white = UIColor(named: "Brand/White", in: NeevaConstants.sharedBundle, compatibleWith: nil)!
                public static let beige = UIColor(named: "Brand/Beige", in: NeevaConstants.sharedBundle, compatibleWith: nil)!
            }

            /// ⚠️ These colors do not automatically adapt to dark mode.
            public enum candidate {
                public static let pistachio = UIColor(named: "Brand/Pistachio Candidate", in: NeevaConstants.sharedBundle, compatibleWith: nil)!
                public static let blueUI = UIColor(named: "Brand/Blue UI Candidate", in: NeevaConstants.sharedBundle, compatibleWith: nil)!
            }
        }

        public enum ui {
            public static let aqua = UIColor(named: "UI/Aqua", in: NeevaConstants.sharedBundle, compatibleWith: nil)!
            public static let blue = UIColor(named: "UI/Blue", in: NeevaConstants.sharedBundle, compatibleWith: nil)!

            public enum fixed {
                public static let background = UIColor(named: "UI/Background", in: NeevaConstants.sharedBundle, compatibleWith: nil)!
                public static let gray10 = UIColor(named: "UI/Gray 10", in: NeevaConstants.sharedBundle, compatibleWith: nil)!
                public static let gray96 = UIColor(named: "UI/Gray 96", in: NeevaConstants.sharedBundle, compatibleWith: nil)!
                public static let gray97 = UIColor(named: "UI/Gray 97", in: NeevaConstants.sharedBundle, compatibleWith: nil)!
                public static let gray98 = UIColor(named: "UI/Gray 98", in: NeevaConstants.sharedBundle, compatibleWith: nil)!
            }

            public static let gray20 = UIColor(named: "UI/Gray 20", in: NeevaConstants.sharedBundle, compatibleWith: nil)!
            public static let gray30 = UIColor(named: "UI/Gray 30", in: NeevaConstants.sharedBundle, compatibleWith: nil)!
            public static let gray50 = UIColor(named: "UI/Gray 50", in: NeevaConstants.sharedBundle, compatibleWith: nil)!
            public static let gray60 = UIColor(named: "UI/Gray 60", in: NeevaConstants.sharedBundle, compatibleWith: nil)!
            public static let gray70 = UIColor(named: "UI/Gray 70", in: NeevaConstants.sharedBundle, compatibleWith: nil)!
            public static let gray80 = UIColor(named: "UI/Gray 80", in: NeevaConstants.sharedBundle, compatibleWith: nil)!
        }

        public static let DarkElevated = UIColor(named: "DarkElevated", in: NeevaConstants.sharedBundle, compatibleWith: nil)!
        public static let GlobeFavGray = UIColor(named: "GlobeFavGray", in: NeevaConstants.sharedBundle, compatibleWith: nil)!
        public static let Backdrop = UIColor(named: "Backdrop", in: NeevaConstants.sharedBundle, compatibleWith: nil)!
        public static let NeevaMenuIncognito = UIColor(named: "NeevaMenuIncognito", in: NeevaConstants.sharedBundle, compatibleWith: nil)!
        public static let TextSelectionHighlight = UIColor(named: "TextSelectionHighlight", in: NeevaConstants.sharedBundle, compatibleWith: nil)!

        public static let DefaultBackground = UIColor(named: "Background", in: NeevaConstants.sharedBundle, compatibleWith: nil)!
        public static let DefaultSeparator = UIColor(named: "Separator", in: NeevaConstants.sharedBundle, compatibleWith: nil)!
        public static let DefaultTextAndTint = UIColor(named: "TextAndTint", in: NeevaConstants.sharedBundle, compatibleWith: nil)!
        public static let MenuBackground = UIColor(named: "MenuBackground", in: NeevaConstants.sharedBundle, compatibleWith: nil)!
    }
}

extension Color {
    public enum neeva {
        public enum brand {
            public static let blue = Color(UIColor.neeva.brand.blue)
            public static let seafoam = Color(UIColor.neeva.brand.seafoam)
            public static let polar = Color(UIColor.neeva.brand.polar)
            public static let pistachio = Color(UIColor.neeva.brand.pistachio)
            public static let offwhite = Color(UIColor.neeva.brand.offwhite)
            public static let red = Color(UIColor.neeva.brand.red)
            public static let orange = Color(UIColor.neeva.brand.orange)
            public static let peach = Color(UIColor.neeva.brand.peach)
            public static let yellow = Color(UIColor.neeva.brand.yellow)
            public static let pink = Color(UIColor.neeva.brand.pink)
            public static let green = Color(UIColor.neeva.brand.green)
            public static let mint = Color(UIColor.neeva.brand.mint)
            public static let maya = Color(UIColor.neeva.brand.maya)
            public static let gold = Color(UIColor.neeva.brand.gold)
            public static let purple = Color(UIColor.neeva.brand.purple)

            /// These colors have their light and dark mode values reversed from the standard color
            public enum variant {
                public static let purple = Color(UIColor.neeva.brand.variant.purple)
            }

            /// ⚠️ These colors do not automatically adapt to dark mode.
            public enum fixed {
                public static let charcoal = Color(UIColor.neeva.brand.fixed.charcoal)
                public static let white = Color(UIColor.neeva.brand.fixed.white)
                public static let beige = Color(UIColor.neeva.brand.fixed.beige)
            }

            /// ⚠️ These colors do not automatically adapt to dark mode.
            public enum candidate {
                public static let pistachio = Color(UIColor.neeva.brand.candidate.pistachio)
                public static let blueUI = Color(UIColor.neeva.brand.candidate.blueUI)
            }
        }

        public enum ui {
            public static let aqua = Color(UIColor.neeva.ui.aqua)
            public static let blue = Color(UIColor.neeva.ui.blue)

            public enum fixed {
                public static let background = Color(UIColor.neeva.ui.fixed.background)
                public static let gray10 = Color(UIColor.neeva.ui.fixed.gray10)
                public static let gray96 = Color(UIColor.neeva.ui.fixed.gray96)
                public static let gray97 = Color(UIColor.neeva.ui.fixed.gray97)
                public static let gray98 = Color(UIColor.neeva.ui.fixed.gray98)
            }

            public static let gray20 = Color(UIColor.neeva.ui.gray20)
            public static let gray30 = Color(UIColor.neeva.ui.gray30)
            public static let gray50 = Color(UIColor.neeva.ui.gray50)
            public static let gray60 = Color(UIColor.neeva.ui.gray60)
            public static let gray70 = Color(UIColor.neeva.ui.gray70)
            public static let gray80 = Color(UIColor.neeva.ui.gray80)
        }

        public static let DarkElevated = Color(UIColor.neeva.DarkElevated)
        public static let GlobeFavGray = Color(UIColor.neeva.GlobeFavGray)
        public static let Backdrop = Color(UIColor.neeva.Backdrop)
    }
}
