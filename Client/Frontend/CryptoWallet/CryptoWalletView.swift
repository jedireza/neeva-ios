// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Defaults
import Shared
import SwiftUI
import web3swift

struct Wallet {
    let address: String
    let data: Data
    let name: String
    let isHD: Bool
}

enum ViewState {
    case starter
    case dashboard
    case showPhrases
    case importWallet
}

struct CryptoWalletView: View {
    @State var viewState: ViewState = Defaults[.cryptoPhrases].isEmpty ? .starter : .dashboard
    @Environment(\.hideOverlay) var onDismiss

    var body: some View {
        VStack {
            HStack {
                Spacer()
                Button(action: onDismiss) {
                    Symbol(decorative: .xmark)
                        .foregroundColor(.label)
                        .tapTargetFrame()
                }
            }
            .padding(.trailing, 20)

            ZStack {
                VStack {
                    Circle()
                        .strokeBorder(Color.brand.pistachio, lineWidth: 2)
                        .background(Circle().foregroundColor(Color.brand.pistachio))
                        .frame(width: 280, height: 280)
                        .offset(x: 200, y: 140)

                    Circle()
                        .strokeBorder(Color(hex: 0xD4F0F5), lineWidth: 2)
                        .background(Circle().foregroundColor(Color(hex: 0xD4F0F5)))
                        .frame(width: 300, height: 300)
                        .offset(x: -140, y: 140)
                }
                .frame(maxWidth: .infinity, maxHeight: 400)

                switch viewState {
                case .starter:
                    WelcomeStarterView(viewState: $viewState)
                case .dashboard:
                    WalletDashboard()
                case .showPhrases:
                    ShowPhrasesView(viewState: $viewState)
                case .importWallet:
                    ImportWalletView(viewState: $viewState)
                }
            }
            Spacer()
        }
        .frame(height: UIScreen.main.bounds.height)
    }
}
