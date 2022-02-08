// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Defaults
import Shared
import SwiftUI
import web3swift

struct WelcomeStarterView: View {
    @Default(.cryptoPublicKey) var publicKey
    @EnvironmentObject var web3Model: Web3Model
    @State var isCreatingWallet: Bool = false
    @Binding var viewState: ViewState

    var body: some View {
        VStack {
            CreateWalletIllustration(isCreatingWallet: $isCreatingWallet)
            if publicKey.isEmpty {
                Button(action: {
                    isCreatingWallet = true
                }) {
                    Text(isCreatingWallet ? "Creating your wallet... " : "Create a new wallet")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.wallet(.primary))
                .padding(.vertical, 8)
                Button(action: { viewState = .importWallet }) {
                    Text("I already have one")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.wallet(.secondary))
                .padding(.vertical, 8)
            } else {
                Button(action: { viewState = .showPhrases }) {
                    Text("View Secret Recovery Phrase")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.wallet(.secondary))
                .padding(.vertical, 8)
                Button(action: { viewState = .dashboard }) {
                    Text("Done")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.wallet(.primary))
                .padding(.vertical, 8)
                Text("You can access your Secret Recovery Phrase from your wallet anytime.")
                    .withFont(.bodyLarge)
                    .foregroundColor(.secondaryLabel)
            }
        }.padding(.horizontal, 16)
    }
}

struct CreateWalletIllustration: View {
    @Default(.cryptoPublicKey) var publicKey
    @EnvironmentObject var web3Model: Web3Model
    @Binding var isCreatingWallet: Bool

    @State var confettiCounter = 0
    @State var timer: Timer? = nil
    @State var finalAnimationShown = false

    var body: some View {
        ZStack {
            if !finalAnimationShown {
                Image("wallet-illustration")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 64)
                    .scaleEffect(isCreatingWallet ? 1.15 : 1)
                    .animation(isCreatingWallet ? .easeOut(duration: 1).repeatForever() : nil)
            } else {
                Text("Congratulations! Your wallet is created")
                    .withFont(.displayLarge)
                    .foregroundColor(.label)
                    .multilineTextAlignment(.center)
            }

            ConfettiCannon(
                counter: $confettiCounter, num: 50, openingAngle: Angle(degrees: 0),
                closingAngle: Angle(degrees: 360), radius: 200)
            if !publicKey.isEmpty {
                ConfettiCannon(
                    counter: $confettiCounter, num: 50, radius: 300, repetitions: 3,
                    repetitionInterval: 0.3)
            }
        }.frame(height: 384)
            .onChange(of: isCreatingWallet) { value in
                guard value else { return }
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.3) {
                    timer = Timer.scheduledTimer(withTimeInterval: 2, repeats: true) { _ in
                        if publicKey.isEmpty {
                            confettiCounter += 1
                        } else if !finalAnimationShown {
                            confettiCounter += 1
                            finalAnimationShown = true
                        }
                    }
                    confettiCounter = 1
                    web3Model.createWallet {
                        isCreatingWallet = false
                    }
                }
            }
    }
}
