// Copyright Neeva. All rights reserved.

import SwiftUI
import SFSafeSymbols

// This file provides conveniences for using Neeva Icons (aka Nicons).

public enum NiconFont: String {
    case regular = "nicons-400"
    case medium = "nicons-500"
    case semibold = "nicons-600"
}

public enum Nicon: Character {
    /// 􀄩
    case arrowDown = "\u{100129}"
    /// 􀄰
    case arrowDownLeft = "\u{100130}"
    /// 􀄱
    case arrowDownRight = "\u{100131}"
    /// 􀅋
    case arrowDownRightAndArrowTopLeft = "\u{10014B}"
    /// 􀄪
    case arrowLeft = "\u{10012A}"
    /// 􀄫
    case arrowRight = "\u{10012B}"
    /// 􀄭
    case arrowRightArrowLeft = "\u{10012D}"

    case arrowTopRightOnSquare = "\u{101000}"
    /// 􀄨
    case arrowUp = "\u{100128}"
    /// 􀄬
    case arrowUpArrowDown = "\u{10012C}"
    /// 􀄮
    case arrowUpLeft = "\u{10012E}"
    /// 􀅊
    case arrowUpLeftAndArrowDownRight = "\u{10014A}"
    /// 􀄯
    case arrowUpRight = "\u{10012F}"
    /// 􀙟
    case arrowUpRightDiamondFill = "\u{10065F}"
    /// 􀉞
    case bookmark = "\u{10025E}"
    /// 􀉟
    case bookmarkFill = "\u{10025F}"
    
    case bookmarkOnBookmark = "\u{101010}"
    /// 􀌪
    case bubbleLeft = "\u{10032A}"
    /// 􀆈
    case chevronDown = "\u{100188}"
    /// 􀆇
    case chevronUp = "\u{100187}"

    case doubleChevronDown = "\u{101006}"
    /// 􀍟
    case gear = "\u{10035F}"
    /// 􀎞
    case house = "\u{10039E}"
    /// 🅯
    case ccBy = "\u{101013}"
    // TODO: Add more here
}

/// A wrapper for displaying either Neeva-specific or standard (SF Symbols) icons.
///
/// Usage note: If a `Symbol` will be used on its own to represent something (such as a button that conatins only an icon),
/// you **must** provide a `label` so screen reader users will be able to access the button. If you do not provide a label,
/// the symbol will be hidden from screen readers.
public struct Symbol: View {
    private enum Icon {
        case neeva(Nicon, NiconFont, Font.TextStyle)
        case system(SFSymbol, Font.Weight)
    }
    private let storage: Icon
    private let size: CGFloat
    private let label: String?

    public static let defaultSize: CGFloat = 16

    // since this comes first, Neeva custom icons take priority over SF Symbols with the same name
    public init(_ nicon: Nicon, size: CGFloat = Symbol.defaultSize, weight: NiconFont = .regular, relativeTo: Font.TextStyle = .body, label: String? = nil) {
        self.storage = .neeva(nicon, weight, relativeTo)
        self.size = size
        self.label = label
    }

    @_disfavoredOverload
    public init(_ symbol: SFSymbol, size: CGFloat = Symbol.defaultSize, weight: Font.Weight = .medium, label: String? = nil) {
        self.storage = .system(symbol, weight)
        self.size = size
        self.label = label
    }

    public var body: some View {
        let icon = Group {
            switch storage {
            case let .neeva(nicon, weight, relativeTo):
                Text(String(nicon.rawValue))
                    .font(Font.custom(weight.rawValue, size: size, relativeTo: relativeTo))
            case let .system(symbol, weight):
                Image(systemSymbol: symbol)
                    .renderingMode(.template)
                    .font(.system(size: size, weight: weight))
            }
        }
        if let label = label {
            icon.accessibilityLabel(label)
        } else {
            icon.accessibilityHidden(true)
        }
    }
}
