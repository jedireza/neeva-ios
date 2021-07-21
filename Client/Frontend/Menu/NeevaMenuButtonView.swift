// Copyright Neeva. All rights reserved.

import SFSafeSymbols
import SwiftUI
import Shared

public struct NeevaMenuButtonView: View {
    let label: String
    let nicon: Nicon?
    let symbol: SFSymbol?
    let action: () -> ()

    @Environment(\.isEnabled) private var isEnabled

    /// - Parameters:
    ///   - label: The text displayed on the button
    ///   - nicon: The Nicon to use
    ///   - isDisabled: Whether to apply gray out disabled style
    public init(label: String, nicon: Nicon, action: @escaping () -> ()) {
        self.label = label
        self.nicon = nicon
        self.symbol = nil
        self.action = action
    }

    /// - Parameters:
    ///   - label: The text displayed on the button
    ///   - symbol: The SFSymbol to use
    ///   - isDisabled: Whether to apply gray out disabled style
    public init(label: String, symbol: SFSymbol, action: @escaping () -> ()) {
        self.label = label
        self.nicon = nil
        self.symbol = symbol
        self.action = action
    }
    
    public var body: some View {
        GroupedCellButton(action: action) {
            VStack(spacing: 4) {
                if let nicon = self.nicon {
                    Symbol(nicon, size: 20)
                } else if let symbol = self.symbol {
                    Symbol(symbol, size: 20)
                }

                Text(label).withFont(.bodyLarge)
            }.frame(height: 83)
        }
        .accentColor(isEnabled ? .label : .quaternaryLabel)
    }
}

struct NeevaMenuButtonView_Previews: PreviewProvider {
    static var previews: some View {
        NeevaMenuButtonView(label: "Test", nicon: .house) {}
    }
}
