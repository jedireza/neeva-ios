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
    @State var communityTrusted: Bool = false
    @State var userSelectedChain: EthNode = .Ethereum

    var showingCommunitySubmissions: Bool {
        guard let type = model.currentSequence?.type,
            case .sessionRequest = type,
            model.matchingCollection == nil,
            let url = model.selectedTab?.url,
            !TEMP_WEB3_ALLOW_LIST.contains(where: { $0 == url.host }),
            !communityTrusted
        else {
            return false
        }
        return true
    }

    var header: String {
        guard let sequence = model.currentSequence else {
            return ""
        }

        switch sequence.type {
        case .sessionRequest:
            return " wants to connect to your wallet"
        case .personalSign:
            return
                " wants to sign a message using your wallet."
        case .sendTransaction:
            return " wants to send a transaction"
        }
    }

    var bottomLeftHeader: String {
        guard let type = model.currentSequence?.type else { return "" }

        switch type {
        case .sendTransaction:
            return "Gas Estimate"
        default:
            return "Wallet"
        }
    }

    @ViewBuilder var bottomRightInfo: some View {
        if let type = model.currentSequence?.type {
            switch type {
            case .sessionRequest:
                Menu(
                    content: {
                        ForEach(EthNode.allCases) { node in
                            Button(
                                action: {
                                    userSelectedChain = node
                                },
                                label: {
                                    Text(node.rawValue)
                                        .withFont(.labelMedium)
                                        .lineLimit(1)
                                        .foregroundColor(.label)
                                        .frame(maxWidth: 150, alignment: .trailing)
                                })
                        }
                    },
                    label: {
                        HStack(spacing: 6) {
                            Text(userSelectedChain.rawValue)
                                .withFont(.labelMedium)
                                .lineLimit(1)
                                .foregroundColor(.label)
                                .frame(maxWidth: 150, alignment: .trailing)
                            Symbol(decorative: .arrowtriangleDownFill)
                                .foregroundColor(.label)
                        }
                    })

            default:
                Text(model.ethBalance == nil ? "Fetching..." : "\(model.ethBalance!) ETH")
                    .withFont(.labelMedium)
                    .lineLimit(1)
                    .foregroundColor(.label)
                    .frame(maxWidth: 150, alignment: .trailing)
            }
        }
    }

    @ViewBuilder var bottomLeftInfo: some View {
        if let type = model.currentSequence?.type {
            switch type {
            case .sendTransaction:
                if let gasEstimate = model.gasEstimate {
                    Label {
                        Text("\(gasEstimate) Gwei")
                            .withFont(.bodyLarge)
                            .foregroundColor(.label)
                    } icon: {
                        Symbol(decorative: .flameFill, style: .bodyLarge)
                    }
                }
            default:
                Text(model.wallet?.publicAddress ?? "")
                    .withFont(.labelMedium)
                    .lineLimit(1)
                    .foregroundColor(.label)
                    .frame(maxWidth: 150, alignment: .leading)
            }
        }
    }

    var bottomRightHeader: String {
        guard let type = model.currentSequence?.type else { return "" }

        switch type {
        case .sessionRequest:
            return "Network"
        default:
            return "Balance"
        }
    }

    var descriptionText: some View {
        Text(model.currentSequence?.message ?? "")
            .withFont(.bodyLarge)
            .foregroundColor(.secondaryLabel)
            .fixedSize(horizontal: false, vertical: true)
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
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: .infinity, alignment: .center)
                HStack {
                    if !showingCommunitySubmissions {
                        Image("twitter-verified-large")
                            .renderingMode(.template)
                            .resizable()
                            .scaledToFit()
                            .foregroundColor(.ui.adaptive.blue)
                            .frame(width: 16, height: 16)
                    }
                    Text(
                        sequence.dAppMeta.url.baseDomain
                            ?? sequence.dAppMeta.url.domainURL.absoluteString
                    ).withFont(.headingMedium)
                        .foregroundColor(showingCommunitySubmissions ? .label : .ui.adaptive.blue)
                }
                if case .sessionRequest = sequence.type {
                    if let collection = model.matchingCollection,
                        collection.safelistRequestStatus >= .approved,
                        let stats = collection.stats
                    {
                        CollectionStatsView(stats: stats)
                            .padding(.vertical, 12)
                    } else if showingCommunitySubmissions,
                        let url = model.selectedTab?.url
                    {
                        CommunitySubmissionView(url: url, trust: $communityTrusted)
                    } else if let _ = sequence.message {
                        descriptionText
                    }
                } else if let _ = sequence.message {
                    descriptionText
                }
                VStack(spacing: 8) {
                    if let ethAmount = sequence.ethAmount, let double = Double(ethAmount) {
                        Text("$" + CryptoConfig.shared.etherToUSD(ether: String(double)))
                            .withFont(.headingXLarge)
                            .foregroundColor(.label)
                        Label {
                            Text(String(double))
                                .withFont(.bodyLarge)
                                .foregroundColor(.secondaryLabel)
                        } icon: {
                            Image("ethLogo")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 16, height: 16)
                                .padding(4)
                        }
                    }
                }.padding(.vertical, 12)
                if !showingCommunitySubmissions {
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
                                    sequence.onAccept(userSelectedChain.id)
                                default:
                                    let context = LAContext()
                                    let reason =
                                        "Signing in and transactions require authentication"
                                    let onAuth: (Bool, Error?) -> Void = {
                                        success, authenticationError in
                                        if success {
                                            sequence.onAccept(userSelectedChain.id)
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
                            .padding(.vertical, 16)
                            .disabled(model.currentSequence == nil)
                    }
                }
                HStack {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(bottomLeftHeader)
                            .withFont(.labelSmall)
                            .foregroundColor(.secondaryLabel)
                        bottomLeftInfo
                    }
                    Spacer()
                    VStack(alignment: .trailing, spacing: 8) {
                        Text(bottomRightHeader)
                            .withFont(.labelSmall)
                            .foregroundColor(.secondaryLabel)
                        bottomRightInfo
                    }
                }
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
        .onChange(of: model.currentSequence?.chain) { chain in
            userSelectedChain = chain ?? .Ethereum
        }
    }
}
