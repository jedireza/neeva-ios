// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import BigInt
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
    @State var userSelectedChain: EthNode? = nil

    var chainToUse: EthNode {
        userSelectedChain ?? model.currentSequence?.chain ?? .Ethereum
    }

    var showingCommunitySubmissions: Bool {
        guard let type = model.currentSequence?.type,
            case .sessionRequest = type,
            case .notTrusted = model.trustSignal,
            model.alternateTrustedDomain == nil,
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
            return "Transaction Fee"
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
                            Text(chainToUse.rawValue)
                                .withFont(.labelMedium)
                                .lineLimit(1)
                                .foregroundColor(.label)
                                .frame(maxWidth: 150, alignment: .trailing)
                            Symbol(decorative: .arrowtriangleDownFill)
                                .foregroundColor(.label)
                        }
                    })

            default:
                Text(
                    "\(model.balanceFor(chainToUse.currency) ?? " ") \(chainToUse.currency.currency.rawValue)"
                )
                .withFont(.labelMedium)
                .lineLimit(1)
                .foregroundColor(.label)
                .frame(maxWidth: 150, alignment: .trailing)
            }
        }
    }

    @ViewBuilder var bottomLeftInfo: some View {
        if let sequence = model.currentSequence {
            switch sequence.type {
            case .sendTransaction:
                TransactionFeeView(
                    wallet: model.wallet,
                    chain: sequence.chain,
                    transaction: sequence.transaction!,
                    options: sequence.options!
                )
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

    @ViewBuilder var descriptionText: some View {
        if model.currentSequence?.type == .personalSign {
            VStack {
                Text(
                    "This will not make any transactions with your wallet. But Neeva will be using your private key to sign this message."
                )
                .withFont(.bodySmall)
                .foregroundColor(.label)
                .fixedSize(horizontal: false, vertical: true)
                ScrollView(.vertical, showsIndicators: true) {
                    Text(model.currentSequence?.message ?? "")
                        .withFont(.bodyLarge)
                        .foregroundColor(.secondaryLabel)
                        .padding()
                }.frame(height: 150)
                    .background(Color.TrayBackground)
                    .cornerRadius(16)
            }
        } else {
            Text(model.currentSequence?.message ?? "")
                .withFont(.bodyLarge)
                .foregroundColor(.secondaryLabel)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    var body: some View {
        VStack {
            if let trustedDomain = model.alternateTrustedDomain {
                VStack(spacing: 8) {
                    (Text("This page's address is very close to ") + Text(trustedDomain).bold()
                        + Text(" which is a verified site."))
                    Text(
                        "Using a popular top level domain and a different extension is a pattern commonly used by malicious websites."
                    )
                    Text("We will avoid connecting your wallet to protect its contents.")
                }
                .font(.roobert(size: 16))
                .foregroundColor(Color(light: .brand.variant.red, dark: .brand.red))
                .fixedSize(horizontal: false, vertical: true)
                .multilineTextAlignment(.center)
                Button(
                    action: {
                        model.selectedTab?.loadRequest(
                            URLRequest(url: URL(string: "https://\(trustedDomain)")!))
                        DispatchQueue.main.async {
                            hideOverlaySheet()
                        }
                    },
                    label: {
                        Text("Navigate to \(trustedDomain)")
                            .frame(maxWidth: .infinity)
                    }
                ).buttonStyle(.wallet(.primary))
                    .padding(.top, 16)
                Button(
                    action: {
                        hideOverlaySheet()
                    },
                    label: {
                        Text("Close")
                            .frame(maxWidth: .infinity)
                    }
                ).buttonStyle(.wallet(.secondary))
                    .padding(.bottom, 16)
            } else if case .malicious = model.trustSignal {
                VStack(spacing: 8) {
                    Text("This page is a known malicious website.")
                    Text("We will avoid connecting to protect your wallet contents.")
                }
                .font(.roobert(size: 16))
                .foregroundColor(.red)
                .fixedSize(horizontal: false, vertical: true)
                .multilineTextAlignment(.center)
                Button(
                    action: {
                        hideOverlaySheet()
                    },
                    label: {
                        Text("Close")
                            .frame(maxWidth: .infinity)
                    }
                ).buttonStyle(.wallet(.primary))
                    .padding(.bottom, 16)
            } else if let sequence = model.currentSequence {
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
                    if case .trusted = model.trustSignal {
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
                        .foregroundColor(model.trustSignal == .trusted ? .ui.adaptive.blue : .label)
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
                    } else if let _ = sequence.message, model.alternateTrustedDomain == nil {
                        descriptionText
                    }
                } else if let _ = sequence.message {
                    descriptionText
                }
                VStack(spacing: 8) {
                    if let value = sequence.options?.value,
                        let amount = Web3.Utils.formatToEthereumUnits(
                            value, toUnits: .eth, decimals: 4),
                        let double = Double(amount)
                    {
                        Text("$" + chainToUse.currency.toUSD(amount))
                            .withFont(.headingXLarge)
                            .foregroundColor(.label)
                        Label {
                            Text(String(double))
                                .withFont(.bodyLarge)
                                .foregroundColor(.secondaryLabel)
                        } icon: {
                            switch chainToUse {
                            case .Polygon:
                                Currency.MATIC.logo
                            default:
                                Currency.ETH.logo
                            }
                        }
                    }
                }.padding(.vertical, 12)
                if sequence.type != .sessionRequest || model.trustSignal == .trusted
                    || communityTrusted
                {
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
                        ).buttonStyle(.wallet(.secondary))
                            .disabled(model.currentSequence == nil)
                        Button(
                            action: {
                                switch sequence.type {
                                case .sessionRequest:
                                    sequence.onAccept(chainToUse.id)
                                default:
                                    let context = LAContext()
                                    let reason =
                                        "Signing in and transactions require authentication"
                                    let onAuth: (Bool, Error?) -> Void = {
                                        success, authenticationError in
                                        if success {
                                            sequence.onAccept(chainToUse.id)
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
                                    Text("Connect")
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
                        ).buttonStyle(.wallet(.primary))
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
    }
}
