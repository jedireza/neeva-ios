// Copyright Neeva. All rights reserved.

import Combine
import SFSafeSymbols
import Shared
import SwiftUI

class ReaderModeBrightnessModel: ObservableObject {
    let levels: [CGFloat] = [0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1]

    var brightness: CGFloat {
        UIScreen.main.brightness
    }
    var canDecrease: Bool { brightness > levels.first! }
    var canIncrease: Bool { brightness < levels.last! }

    func setBrightness(to: CGFloat) {
        UIScreen.main.brightness = to
    }

    func increase() {
        if brightness < levels.first! {
            setBrightness(to: levels.first!)
        } else if brightness < levels.last! {
            for (lower, upper) in zip(levels, levels.dropFirst()) {
                if lower <= brightness, brightness < upper {
                    setBrightness(to: upper)
                    return
                }
            }
        }
    }

    func decrease() {
        if brightness > levels.last! {
            setBrightness(to: levels.first!)
        } else if brightness > levels.first! {
            for (lower, upper) in zip(levels, levels.dropFirst()) {
                if lower < brightness, brightness <= upper {
                    setBrightness(to: lower)
                    return
                }
            }
        }
    }

    var symbol: Symbol {
        if brightness < 0.5 {
            return Symbol(decorative: .sunMin, style: .headingLarge)
        } else {
            return Symbol(decorative: .sunMax, style: .headingLarge)
        }
    }
}
