// Copyright Neeva. All rights reserved.

import SFSafeSymbols
import SwiftUI
import Shared

public struct NeevaMenuRowButtonView: View {
    let label: String
    let nicon: Nicon?
    let symbol: SFSymbol?
    let action: () -> ()
    let isPromo: Bool

    /// - Parameters:
    ///   - label: The text displayed on the button
    ///   - nicon: The Nicon to use
    public init(label: String, nicon: Nicon, action: @escaping () -> ()) {
        self.label = label
        self.nicon = nicon
        self.symbol = nil
        self.action = action
        self.isPromo = false
    }

    /// - Parameters:
    ///   - label: The text displayed on the button
    ///   - symbol: The SFSymbol to use
    public init(label: String, symbol: SFSymbol, action: @escaping () -> ()) {
        self.label = label
        self.nicon = nil
        self.symbol = symbol
        self.action = action
        self.isPromo = false
    }

    /// - Parameters:
    ///   - label: The text displayed on the button
    public init(label: String, isPromo: Bool, action: @escaping () -> ()) {
        self.label = label
        self.nicon = nil
        self.symbol = nil
        self.action = action
        self.isPromo = isPromo
    }

    public var body: some View {
        Button(action: action) {
            HStack(spacing: 0) {
                Text(label)
                    .withFont(isPromo ? .headingMedium : .bodyLarge)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.vertical, 10)
                Spacer()
                Group {
                    if let nicon = self.nicon {
                        Symbol(nicon, size: 18)
                    } else if let symbol = self.symbol {
                        Symbol(symbol, size: 18)
                    }
                }.frame(width: 24, height: 24)
            }
            .padding(.trailing, -6)
            .padding(.horizontal, GroupedCellUX.horizontalPadding)
            .frame(minHeight: GroupedCellUX.minCellHeight)
        }
        .buttonStyle(TableCellButtonStyle())
    }
}

struct NeevaMenuRowButtonView_Previews: PreviewProvider {
    static var previews: some View {
        NeevaMenuRowButtonView(label: "Test", nicon: .gear) {}
            .previewLayout(.sizeThatFits)
    }
}
