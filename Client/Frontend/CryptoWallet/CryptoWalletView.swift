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
        VStack(spacing: 0) {
            HStack {
                Spacer()
                Button(action: onDismiss) {
                    Symbol(decorative: .xmark)
                        .foregroundColor(.label)
                        .tapTargetFrame()
                }
            }
            .padding(.trailing, 20)

            Image("wallet-wordmark")
                .resizable()
                .scaledToFit()
                .frame(height: viewState == .starter ? 32 : 20)
                .padding(.top, viewState == .starter ? 40 : 0)
                .animation(
                    viewState == .showPhrases || viewState == .importWallet ? .easeInOut : nil
                )

            ZStack {
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
