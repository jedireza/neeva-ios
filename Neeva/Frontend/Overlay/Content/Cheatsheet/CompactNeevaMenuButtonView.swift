// Copyright Neeva. All rights reserved.

import SFSafeSymbols
import Shared
import SwiftUI

public struct CompactNeevaMenuButtonView: View {
    let label: String
    let nicon: Nicon?
    let symbol: SFSymbol?
    let action: () -> Void

    @Environment(\.isEnabled) private var isEnabled

    /// - Parameters:
    ///   - label: The text displayed on the button
    ///   - nicon: The Nicon to use
    ///   - isDisabled: Whether to apply gray out disabled style
    public init(label: String, nicon: Nicon, action: @escaping () -> Void) {
        self.label = label
        self.nicon = nicon
        self.symbol = nil
        self.action = action
    }

    /// - Parameters:
    ///   - label: The text displayed on the button
    ///   - symbol: The SFSymbol to use
    ///   - isDisabled: Whether to apply gray out disabled style
    public init(label: String, symbol: SFSymbol, action: @escaping () -> Void) {
        self.label = label
        self.nicon = nil
        self.symbol = symbol
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            HStack {
                if let nicon = self.nicon {
                    Symbol(decorative: nicon, size: 14)
                } else if let symbol = self.symbol {
                    Symbol(decorative: symbol, size: 14)
                }

                Text(label).withFont(.bodyMedium)
            }
            .frame(height: 14)
        }
        .accentColor(isEnabled ? .label : .quaternaryLabel)
        .padding()
        .background(Color.DefaultBackground)
        .roundedOuterBorder(cornerRadius: 12, color: Color.DefaultBackground, lineWidth: 1)
    }
}

struct CompactNeevaMenuButtonView_Previews: PreviewProvider {
    static var previews: some View {
        CompactNeevaMenuButtonView(label: "Test", nicon: .gear) {}
            .previewLayout(.sizeThatFits)
    }
}
