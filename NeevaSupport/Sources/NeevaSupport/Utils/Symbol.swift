// Copyright Neeva. All rights reserved.

import SwiftUI

// This file provides conveniences for using Neeva Icons (aka Nicons).

public enum NiconFont: String {
    case regular = "nicons-400"
    case medium = "nicons-500"
    case semibold = "nicons-600"
}

public enum Nicon: Character {
    case arrowDown = "\u{100129}"
    case arrowDownLeft = "\u{100130}"
    case arrowDownRight = "\u{100131}"
    case arrowDownRightAndArrowTopLeft = "\u{10014B}"
    case arrowLeft = "\u{10012A}"
    case arrowRight = "\u{10012B}"
    case arrowRightArrowLeft = "\u{10012D}"
    case arrowTopRightOnSquare = "\u{101000}"
    case arrowUp = "\u{100128}"
    case arrowUpArrowDown = "\u{10012C}"
    case arrowUpLeft = "\u{10012E}"
    case arrowUpLeftAndArrowDownRight = "\u{10014A}"
    case arrowUpRight = "\u{10012F}"
    case arrowUpRightDiamondFill = "\u{10065F}"
    case bookmark = "\u{10025E}"
    case bookmarkFill = "\u{10025F}"
    case bubbleLeft = "\u{10032A}"
    case gear = "\u{10035F}"
    case house = "\u{10039E}"
    // TODO: Add more here
}

public enum SFSymbol: String {
    case squareAndArrowDown = "square.and.arrow.down"
    case clock = "clock"
    case magnifyingGlass = "magnifyingglass"
    case plus = "plus"
    case xmark = "xmark"
    case xmarkCircleFill = "xmark.circle.fill"
    // TODO: Add more here
}

public struct Symbol {
    public static func neeva(_ nicon: Nicon, size: CGFloat = 16, weight: NiconFont = .regular) -> some View {
        Text(String(nicon.rawValue))
            .font(Font.custom(weight.rawValue, size: size))
    }

    public static func system(_ symbol: SFSymbol, size: CGFloat = 16, weight: Font.Weight = .regular) -> some View {
        Image(systemName: symbol.rawValue)
            .renderingMode(.template)
            .font(.system(size: size, weight: weight))
    }
}
