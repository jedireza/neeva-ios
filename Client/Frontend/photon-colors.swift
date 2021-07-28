/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

/* Photon Colors iOS Variables v3.3.1
 From https://github.com/FirefoxUX/photon-colors/#readme */
import UIKit

// Used as backgrounds for favicons
public let DefaultFaviconBackgroundColors = [
    "2e761a", "399320", "40a624", "57bd35", "70cf5b", "90e07f", "b1eea5", "881606", "aa1b08",
    "c21f09", "d92215", "ee4b36", "f67964", "ffa792", "025295", "0568ba", "0675d3", "0996f8",
    "2ea3ff", "61b4ff", "95cdff", "00736f", "01908b", "01a39d", "01bdad", "27d9d2", "58e7e6",
    "89f4f5", "c84510", "e35b0f", "f77100", "ff9216", "ffad2e", "ffc446", "ffdf81", "911a2e",
    "b7223b", "cf2743", "ea385e", "fa526e", "ff7a8d", "ffa7b3",
]

extension UIColor {
    struct Photon {
        static let Blue40 = UIColor(rgb: 0x45a1ff)
        static let Blue50 = UIColor(rgb: 0x0a84ff)
        static let Blue60 = UIColor(rgb: 0x0060df)

        static let Orange60 = UIColor(rgb: 0xd76e00)

        static let Grey10 = UIColor(rgb: 0xf9f9fa)
        static let Grey20 = UIColor(rgb: 0xededf0)
        static let Grey30 = UIColor(rgb: 0xd7d7db)
        static let Grey40 = UIColor(rgb: 0xb1b1b3)
        static let Grey50 = UIColor(rgb: 0x737373)
        static let Grey60 = UIColor(rgb: 0x4a4a4f)
        static let Grey70 = UIColor(rgb: 0x38383d)
        static let Grey80 = UIColor(rgb: 0x2a2a2e)
        static let Grey90 = UIColor(rgb: 0x0c0c0d)

        static let Ink90 = UIColor(rgb: 0x1D1133)

        static let White100 = UIColor(rgb: 0xffffff)

    }
}
