// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Defaults
import Shared
import SwiftUI
import web3swift

public struct WelcomeStarterView: View {
    let dismiss: () -> Void
    @Default(.cryptoPublicKey) var publicKey
    @State var isCreatingWallet: Bool = false
    @Binding var viewState: ViewState
    let completion: () -> Void

    public init(
        dismiss: @escaping () -> Void, viewState: Binding<ViewState>,
        completion: @escaping () -> Void
    ) {
        self._viewState = viewState
        self.dismiss = dismiss
        self.completion = completion
    }

    public var body: some View {
        VStack {
            CreateWalletIllustration(isCreatingWallet: $isCreatingWallet, completion: completion)
            if publicKey.isEmpty {
                Button(action: { viewState = .importWallet }) {
                    Text("Import My Wallet")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.wallet(.primary))
                .padding(.vertical, 8)
                Text(
                    "Already have one? **Whether you created it on Metamask or elsewhere**, you can access your wallet here."
                )
                .withFont(.bodyMedium)
                .foregroundColor(.secondaryLabel)
                .multilineTextAlignment(.center)
                Button(action: {
                    isCreatingWallet = true
                }) {
                    Text(isCreatingWallet ? "Creating your wallet... " : "Create a new wallet")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.wallet(.secondary))
                .padding(.vertical, 8)
                Text(
                    "Remember, this wallet is yours. You own its contents, and **can access it through any wallet app**."
                )
                .withFont(.bodyMedium)
                .foregroundColor(.secondaryLabel)
                .multilineTextAlignment(.center)
            } else {
                Button(action: { viewState = .showPhrases }) {
                    Text("View Secret Recovery Phrase")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.wallet(.secondary))
                .padding(.vertical, 8)
                Button(action: { dismiss() }) {
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
    let model = OnboardingModel()
    @Binding var isCreatingWallet: Bool

    @State var confettiCounter = 0
    @State var timer: Timer? = nil
    @State var finalAnimationShown = false

    let completion: () -> Void

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
        }.frame(height: 300)
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
                    model.createWallet {
                        isCreatingWallet = false
                        completion()
                    }
                }
            }
    }
}
