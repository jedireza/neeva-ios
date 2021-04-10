// Copyright Neeva. All rights reserved.

import SwiftUI

// This file provides conveniences for using Neeva Icons (aka Nicons).

public enum NiconFont: String {
    case regular = "nicons-400"
    case medium = "nicons-500"
    case semibold = "nicons-600"
}

public enum Nicon: Character {
    case bookmark = "\u{10025E}"
    case bubbleLeft = "\u{10032A}"
    case gear = "\u{10035F}"
    case house = "\u{10039E}"
    // TODO: Add more here
}

public struct NiconView: View {
    let nicon: Nicon
    let size: CGFloat
    let font: NiconFont

    public init(_ nicon: Nicon, size: CGFloat = 16, font: NiconFont = .regular) {
        self.nicon = nicon
        self.size = size
        self.font = font
    }

    public var body: some View {
        Text(String(nicon.rawValue))
            .font(Font.custom(font.rawValue, size: size))
    }
}
