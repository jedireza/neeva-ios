/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import UIKit
import SwiftUI

extension UIColor {
    public struct Neeva {
        public struct Brand {
            public static let Charcoal = UIColor(named: "Brand-Charcoal", in: NeevaConstants.sharedBundle, compatibleWith: nil)!
            public static let Blue = UIColor(named: "Brand-Blue", in: NeevaConstants.sharedBundle, compatibleWith: nil)!
            public static let Beige = UIColor(named: "Brand-Beige", in: NeevaConstants.sharedBundle, compatibleWith: nil)!
            public static let Polar = UIColor(named: "Brand-Polar", in: NeevaConstants.sharedBundle, compatibleWith: nil)!
            public static let Maya = UIColor(named: "Brand-Maya", in: NeevaConstants.sharedBundle, compatibleWith: nil)!
            public static let White = UIColor(named: "Brand-White", in: NeevaConstants.sharedBundle, compatibleWith: nil)!
            public static let Offwhite = UIColor(named: "Brand-Offwhite", in: NeevaConstants.sharedBundle, compatibleWith: nil)!
            public static let Pistachio = UIColor(named: "Brand-Pistachio", in: NeevaConstants.sharedBundle, compatibleWith: nil)!
            public static let Purple = UIColor(named: "Brand-Purple", in: NeevaConstants.sharedBundle, compatibleWith: nil)!
        }

        public struct UI {
            public static let Aqua = UIColor(named: "UI-Aqua", in: NeevaConstants.sharedBundle, compatibleWith: nil)!
            public static let Blue40 = UIColor(named: "UI-Blue40", in: NeevaConstants.sharedBundle, compatibleWith: nil)!
            public static let Gray10 = UIColor(named: "UI-Gray10", in: NeevaConstants.sharedBundle, compatibleWith: nil)!
            public static let Gray20 = UIColor(named: "UI-Gray20", in: NeevaConstants.sharedBundle, compatibleWith: nil)!
            public static let Gray30 = UIColor(named: "UI-Gray30", in: NeevaConstants.sharedBundle, compatibleWith: nil)!
            public static let Gray50 = UIColor(named: "UI-Gray50", in: NeevaConstants.sharedBundle, compatibleWith: nil)!
            public static let Gray60 = UIColor(named: "UI-Gray60", in: NeevaConstants.sharedBundle, compatibleWith: nil)!
            public static let Gray70 = UIColor(named: "UI-Gray70", in: NeevaConstants.sharedBundle, compatibleWith: nil)!
            public static let Gray96 = UIColor(named: "UI-Gray96", in: NeevaConstants.sharedBundle, compatibleWith: nil)!
            public static let Gray97 = UIColor(named: "UI-Gray97", in: NeevaConstants.sharedBundle, compatibleWith: nil)!
            public static let Gray98 = UIColor(named: "UI-Gray98", in: NeevaConstants.sharedBundle, compatibleWith: nil)!
        }

        public static let DarkElevated = UIColor(named: "DarkElevated", in: NeevaConstants.sharedBundle, compatibleWith: nil)!
        public static let GlobeFavGray = UIColor(named: "GlobeFavGray", in: NeevaConstants.sharedBundle, compatibleWith: nil)!
        public static let Backdrop = UIColor(named: "Backdrop", in: NeevaConstants.sharedBundle, compatibleWith: nil)!
        public static let NeevaMenuIncognito = UIColor(named: "NeevaMenuIncognito", in: NeevaConstants.sharedBundle, compatibleWith: nil)!
        public static let TextSelectionHighlight = UIColor(named: "TextSelectionHighlight", in: NeevaConstants.sharedBundle, compatibleWith: nil)!

        public static let DefaultBackground = UIColor(named: "Background", in: NeevaConstants.sharedBundle, compatibleWith: nil)!
        public static let DefaultSeparator = UIColor(named: "Separator", in: NeevaConstants.sharedBundle, compatibleWith: nil)!
        public static let DefaultTextAndTint = UIColor(named: "TextAndTint", in: NeevaConstants.sharedBundle, compatibleWith: nil)!
    }
}

extension Color {
    public struct Neeva {
        public struct Brand {
            public static let Charcoal = Color(UIColor.Neeva.Brand.Charcoal)
            public static let Blue = Color(UIColor.Neeva.Brand.Blue)
            public static let Beige = Color(UIColor.Neeva.Brand.Beige)
            public static let Polar = Color(UIColor.Neeva.Brand.Polar)
            public static let Maya = Color(UIColor.Neeva.Brand.Maya)
            public static let White = Color(UIColor.Neeva.Brand.White)
            public static let Offwhite = Color(UIColor.Neeva.Brand.Offwhite)
            public static let Pistachio = Color(UIColor.Neeva.Brand.Pistachio)
            public static let Purple = Color(UIColor.Neeva.Brand.Purple)
        }

        public struct UI {
            public static let Aqua = Color(UIColor.Neeva.UI.Aqua)
            public static let Gray10 = Color(UIColor.Neeva.UI.Gray10)
            public static let Gray20 = Color(UIColor.Neeva.UI.Gray20)
            public static let Gray30 = Color(UIColor.Neeva.UI.Gray30)
            public static let Gray50 = Color(UIColor.Neeva.UI.Gray50)
            public static let Gray60 = Color(UIColor.Neeva.UI.Gray60)
            public static let Gray70 = Color(UIColor.Neeva.UI.Gray70)
            public static let Gray96 = Color(UIColor.Neeva.UI.Gray96)
            public static let Gray97 = Color(UIColor.Neeva.UI.Gray97)
            public static let Gray98 = Color(UIColor.Neeva.UI.Gray98)
        }

        public static let DarkElevated = Color(UIColor.Neeva.DarkElevated)
        public static let GlobeFavGray = Color(UIColor.Neeva.GlobeFavGray)
        public static let Backdrop = Color(UIColor.Neeva.Backdrop)
    }
}
