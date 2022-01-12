// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Combine
import Foundation
import LocalAuthentication
import SDWebImageSwiftUI
import Shared
import SwiftUI
import WalletConnectSwift
import web3swift

struct WalletSequenceContent: View {
    @Environment(\.hideOverlay) private var hideOverlaySheet
    @ObservedObject var model: Web3Model

    var header: String {
        guard let sequence = model.currentSequence else {
            return ""
        }

        switch sequence.type {
        case .sessionRequest:
            return " wants to connect to your wallet"
        case .personalSign:
            return
                " wants to personal sign a message using your wallet."
        case .sendTransaction:
            return " wants to send a transaction"
        }
    }

    var body: some View {
        VStack {
            if let sequence = model.currentSequence {
                WebImage(url: sequence.thumbnailURL)
                    .resizable()
                    .placeholder {
                        Color.secondarySystemFill
                    }
                    .transition(.opacity)
                    .scaledToFit()
                    .frame(width: 48, height: 48)
                    .cornerRadius(12)
                (Text(sequence.dAppMeta.name).bold()
                    + Text(header))
                    .withFont(.headingLarge)
                    .lineLimit(2)
                    .foregroundColor(.label)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity, alignment: .center)
                Text(
                    sequence.dAppMeta.url.baseDomain
                        ?? sequence.dAppMeta.url.domainURL.absoluteString
                )
                .withFont(.labelLarge)
                .foregroundColor(.ui.adaptive.blue)
                if case .sessionRequest = sequence.type, let collection = model.matchingCollection,
                    let stats = collection.stats
                {
                    CollectionStatsView(
                        stats: stats,
                        verified: collection.safelistRequestStatus == .verified)
                } else if let description = sequence.message {
                    Text(description)
                        .withFont(.bodyLarge)
                        .foregroundColor(.secondaryLabel)
                }
                if let ethAmount = sequence.ethAmount {
                    Label {
                        Text(ethAmount).withFont(.headingLarge).foregroundColor(.label)
                    } icon: {
                        Image("ethLogo")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 40, height: 40)
                            .padding(4)
                            .background(
                                Circle().stroke(Color.ui.gray80)
                            )
                    }
                }
                Spacer()
                HStack {
                    Button(
                        action: {
                            sequence.onReject()
                            hideOverlaySheet()
                        },
                        label: {
                            Text("Reject")
                                .frame(maxWidth: .infinity)
                        }
                    ).buttonStyle(.neeva(.secondary))
                        .disabled(model.currentSequence == nil)
                    Button(
                        action: {
                            switch sequence.type {
                            case .sessionRequest:
                                sequence.onAccept()
                            default:
                                let context = LAContext()
                                let reason = "Signing in and transactions require authentication"
                                let onAuth: (Bool, Error?) -> Void = {
                                    success, authenticationError in
                                    if success {
                                        sequence.onAccept()
                                    } else {
                                        sequence.onReject()
                                    }
                                }

                                var error: NSError?
                                if context.canEvaluatePolicy(
                                    .deviceOwnerAuthenticationWithBiometrics, error: &error)
                                {
                                    context.evaluatePolicy(
                                        .deviceOwnerAuthenticationWithBiometrics,
                                        localizedReason: reason,
                                        reply: onAuth)
                                } else if context.canEvaluatePolicy(
                                    .deviceOwnerAuthentication, error: &error)
                                {
                                    context.evaluatePolicy(
                                        .deviceOwnerAuthentication, localizedReason: reason,
                                        reply: onAuth)
                                } else {
                                    sequence.onReject()
                                }
                            }

                            hideOverlaySheet()
                        },
                        label: {
                            if case .sessionRequest = sequence.type {
                                Text("Accept")
                                    .frame(maxWidth: .infinity)
                            } else {
                                Label(
                                    title: {
                                        Text("Accept")
                                    },
                                    icon: {
                                        Symbol(decorative: .faceid)
                                    }
                                )
                                .frame(maxWidth: .infinity)

                            }
                        }
                    ).buttonStyle(.neeva(.primary))
                        .disabled(model.currentSequence == nil)
                }
            } else if let wcURL = model.wcURL {
                ConnectWalletPanel()
                    .environmentObject(model)
            } else {
                Spacer(minLength: 150)
                ProgressView()
                    .scaleEffect(x: 2, y: 2, anchor: .center)
                    .frame(maxWidth: .infinity, alignment: .center)
                Spacer(minLength: 150)
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 12)
        .padding(.bottom, 36)
    }
}
