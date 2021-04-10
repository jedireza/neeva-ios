// Copyright Neeva. All rights reserved.

import SwiftUI

// This file provides conveniences for using the Apple provided SF Symbol icons.

public enum SFSymbol: String {
    case squareAndArrowDown = "square.and.arrow.down"
    case clock = "clock"
    // TODO: Add more here
}

public struct SFSymbolView: View {
    let symbol: SFSymbol
    let size: CGFloat
    let weight: Font.Weight

    public init(_ symbol: SFSymbol, size: CGFloat = 16, weight: Font.Weight = .regular) {
        self.symbol = symbol
        self.size = size
        self.weight = weight
    }

    public var body: some View {
        Image(systemName: symbol.rawValue)
            .renderingMode(.template)
            .font(.system(size: size, weight: weight))
    }
}
