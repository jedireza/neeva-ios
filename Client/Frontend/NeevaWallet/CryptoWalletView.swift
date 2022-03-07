// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Defaults
import Shared
import SwiftUI
import WalletCore
import web3swift

struct CryptoWalletView: View {
    @EnvironmentObject var model: Web3Model
    @State var viewState: ViewState = Defaults[.cryptoPhrases].isEmpty ? .starter : .dashboard
    let dismiss: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            Image("wallet-wordmark")
                .resizable()
                .scaledToFit()
                .frame(height: viewState == .starter ? 32 : 20)
                .padding(.top, viewState == .starter ? 40 : 16)
                .animation(
                    viewState == .showPhrases || viewState == .importWallet ? .easeInOut : nil
                )
                .padding(.bottom, 16)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.horizontal, 16)
                .padding(.top, 44)

            if viewState != .starter {
                Color.ui.adaptive.separator.frame(height: 1)
            }

            ZStack {
                switch viewState {
                case .starter:
                    WelcomeStarterView(viewState: $viewState)
                case .dashboard:
                    WalletDashboard(viewState: $viewState)
                case .showPhrases:
                    ShowPhrasesView(viewState: $viewState)
                case .importWallet:
                    ImportWalletView(viewState: $viewState)
                }
            }
        }
        .ignoresSafeArea()
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .overlay(
            Button(action: dismiss) {
                Text("Done")
                    .withFont(.labelLarge)
                    .foregroundColor(.ui.adaptive.blue)
                    .frame(height: 48)
            }
            .padding(.top, 44)
            .padding(.horizontal, 16)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
        ).onChange(of: viewState) { value in
            if case .dashboard = viewState, model.wallet?.publicAddress.isEmpty ?? true {
                DispatchQueue.main.async {
                    model.wallet = WalletAccessor()
                    model.updateBalances()
                }
            }
        }
    }
}
