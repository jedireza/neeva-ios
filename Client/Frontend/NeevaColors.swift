/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import UIKit
import SwiftUI

extension UIColor {
    struct Neeva {
        struct Brand {
            static let Charcoal = UIColor(named: "Brand-Charcoal")!
            static let Blue = UIColor(named: "Brand-Blue")!
            static let Beige = UIColor(named: "Brand-Beige")!
            static let Polar = UIColor(named: "Brand-Polar")!
            static let Maya = UIColor(named: "Brand-Maya")!
            static let White = UIColor(named: "Brand-White")!
            static let Offwhite = UIColor(named: "Brand-Offwhite")!
        }

        struct UI {
            static let Aqua = UIColor(named: "UI-Aqua")!
            static let Gray10 = UIColor(named: "UI-Gray10")!
            static let Gray20 = UIColor(named: "UI-Gray20")!
            static let Gray30 = UIColor(named: "UI-Gray30")!
            static let Gray60 = UIColor(named: "UI-Gray60")!
            static let Gray70 = UIColor(named: "UI-Gray70")!
            static let Gray96 = UIColor(named: "UI-Gray96")!
            static let Gray97 = UIColor(named: "UI-Gray97")!
        }

        static let DarkElevated = UIColor(named: "DarkElevated")!
        static let GlobeFavGray = UIColor(named: "GlobeFavGray")!
        static let Backdrop = UIColor(named: "Backdrop")!  // Black + 40% transparency
    }
}

extension Color {
    struct Neeva {
        struct Brand {
            static let Charcoal = Color(UIColor(named: "Brand-Charcoal")!)
            static let Blue = Color(UIColor(named: "Brand-Blue")!)
            static let Beige = Color(UIColor(named: "Brand-Beige")!)
            static let Polar = Color(UIColor(named: "Brand-Polar")!)
            static let Maya = Color(UIColor(named: "Brand-Maya")!)
            static let White = Color(UIColor(named: "Brand-White")!)
            static let Offwhite = Color(UIColor(named: "Brand-Offwhite")!)
        }

        struct UI {
            static let Aqua = Color(UIColor(named: "UI-Aqua")!)
            static let Gray10 = Color(UIColor(named: "UI-Gray10")!)
            static let Gray20 = Color(UIColor(named: "UI-Gray20")!)
            static let Gray30 = Color(UIColor(named: "UI-Gray30")!)
            static let Gray60 = Color(UIColor(named: "UI-Gray60")!)
            static let Gray70 = Color(UIColor(named: "UI-Gray70")!)
            static let Gray96 = Color(UIColor(named: "UI-Gray96")!)
            static let Gray97 = Color(UIColor(named: "UI-Gray97")!)
        }

        static let DarkElevated = Color(UIColor(named: "DarkElevated")!)
        static let GlobeFavGray = Color(UIColor(named: "GlobeFavGray")!)
        static let Backdrop = Color(UIColor(named: "Backdrop")!)  // Black + 40% transparency
    }
}
