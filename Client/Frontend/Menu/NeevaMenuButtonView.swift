//
//  NeevaMenuButtonView.swift
//  
//
//  Created by Stuart Allen on 13/03/21.
//  Copyright © 2021 Neeva. All rights reserved.
//

import NeevaSupport
import SFSafeSymbols
import SwiftUI

public struct NeevaMenuButtonView: View {
    let label: String
    let nicon: Nicon?
    let symbol: SFSymbol?
    let isDisabled: Bool
    
    /// - Parameters:
    ///   - label: The text displayed on the button
    ///   - nicon: The Nicon to use
    ///   - isDisabled: Whether to apply gray out disabled style
    public init(label: String, nicon: Nicon, isDisabled: Bool = false) {
        self.label = label
        self.nicon = nicon
        self.symbol = nil
        self.isDisabled = isDisabled
    }

    /// - Parameters:
    ///   - label: The text displayed on the button
    ///   - symbol: The SFSymbol to use
    ///   - isDisabled: Whether to apply gray out disabled style
    public init(label: String, symbol: SFSymbol, isDisabled: Bool = false) {
        self.label = label
        self.nicon = nil
        self.symbol = symbol
        self.isDisabled = isDisabled
    }
    
    public var body: some View {
        HStack(spacing: 0) {
            Spacer()

            VStack(spacing: 0) {
                Group {
                    if let nicon = self.nicon {
                        Symbol(nicon, size: 20)
                    } else if let symbol = self.symbol {
                        Symbol(symbol, size: 20)
                    }
                }
                .foregroundColor(self.isDisabled ? Color(UIColor.theme.popupMenu.disabledButtonColor): Color(UIColor.theme.popupMenu.buttonColor))

                Spacer()

                Text(label)
                    .foregroundColor(self.isDisabled ? Color(UIColor.theme.popupMenu.disabledButtonColor): Color(UIColor.theme.popupMenu.textColor))
                    .font(.system(size: 16))
            }
            .frame(height: 46)
            .padding([.top, .bottom], NeevaUIConstants.buttonInnerPadding)

            Spacer()
        }
        .background(Color(UIColor.theme.popupMenu.foreground))
        .cornerRadius(NeevaUIConstants.menuCornerDefault)
        .disabled(self.isDisabled)
    }
}

struct NeevaMenuButtonView_Previews: PreviewProvider {
    static var previews: some View {
        NeevaMenuButtonView(label: "Test", nicon: .house)
    }
}
