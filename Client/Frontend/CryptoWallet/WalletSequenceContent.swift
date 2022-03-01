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

    var domain: String {
        model.currentSequence?.dAppMeta.url.baseDomain
            ?? model.currentSequence?.dAppMeta.url.domainURL.absoluteString ?? ""
    }

    var body: some View {
        if let sequence = model.currentSequence {
            if showingCommunitySubmissions, let url = model.selectedTab?.url {
                CommunitySubmissionView(
                    iconURL: sequence.thumbnailURL, domain: domain, url: url,
                    trust: $communityTrusted)
            } else {
                VStack(spacing: 24) {
                    VStack(spacing: 8) {
                        if case .sessionRequest = sequence.type,
                            let collection = model.matchingCollection,
                            collection.safelistRequestStatus >= .approved,
                            let stats = collection.stats
                        {
                            WalletSequenceSiteHeader(
                                iconURL: collection.imageURL,
                                domain: collection.name,
                                trusted: model.trustSignal == .trusted
                            )
                            CompactStatsView(stats: stats)
                                .frame(maxWidth: .infinity)
                        } else {
                            DefaultHeader(
                                sequence: sequence,
                                trusted: model.trustSignal == .trusted,
                                userSelectedChain: $userSelectedChain
                            ).frame(maxWidth: .infinity, alignment: .center)
                        }
                    }
                    .padding(12)
                    .background(WalletTheme.gradient.opacity(0.08))
                    .cornerRadius(12)
                    WalletSequenceMessage(type: sequence.type, dAppName: sequence.dAppMeta.name)
                    if sequence.type != .sessionRequest || model.trustSignal == .trusted
                        || communityTrusted
                    {
                        WalletSequenceMainButtons(
                            sequence: sequence,
                            userSelectedChain: $userSelectedChain
                        )
                    }
                    if let sequence = model.currentSequence,
                        let wallet = model.wallet
                    {
                        WalletSequenceBottomInfoPanel(
                            sequence: sequence,
                            wallet: wallet,
                            balance: model.balanceFor(chainToUse.currency),
                            userSelectedChain: $userSelectedChain
                        )
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 12)
                .padding(.bottom, 36)
            }
        } else {
            VStack {
                Spacer(minLength: 150)
                ProgressView()
                    .scaleEffect(x: 2, y: 2, anchor: .center)
                    .frame(maxWidth: .infinity, alignment: .center)
                Spacer(minLength: 150)
            }
        }
    }
}

struct DefaultHeader: View {
    let sequence: SequenceInfo
    let trusted: Bool
    @Binding var userSelectedChain: EthNode?

    var chainToUse: EthNode {
        userSelectedChain ?? sequence.chain
    }

    var domain: String {
        sequence.dAppMeta.url.baseDomain
            ?? sequence.dAppMeta.url.domainURL.absoluteString
    }

    var body: some View {
        WalletSequenceSiteHeader(
            iconURL: sequence.thumbnailURL,
            domain: domain,
            trusted: trusted
        )
        switch sequence.type {
        case .personalSign, .signTypedData:
            VStack {
                Text("Message:")
                    .withFont(.bodyLarge)
                    .foregroundColor(.label)
                    .fixedSize(horizontal: false, vertical: true)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity, alignment: .center)
                ScrollView(.vertical, showsIndicators: true) {
                    Text(sequence.message)
                        .withFont(.bodyLarge)
                        .foregroundColor(.label)
                        .padding()
                }.frame(height: 150)
            }
        case .sendTransaction:
            if let value = sequence.options?.value,
                let amount = Web3.Utils.formatToEthereumUnits(
                    value, toUnits: .eth, decimals: 4),
                let double = Double(amount)
            {
                Group {
                    Text("$" + chainToUse.currency.toUSD(amount))
                        .withFont(.displayMedium)
                        .foregroundColor(.label)
                    Label {
                        Text(String(double))
                            .withFont(.headingMedium)
                            .foregroundColor(.label)
                    } icon: {
                        switch chainToUse {
                        case .Polygon:
                            Currency.MATIC.logo
                        default:
                            Currency.ETH.logo
                        }
                    }
                }.frame(maxWidth: .infinity, alignment: .center)
            }
        default:
            Text(sequence.message)
                .withFont(.bodyLarge)
                .foregroundColor(.label)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

struct WalletSequenceMainButtons: View {
    @Environment(\.hideOverlay) private var hideOverlaySheet
    let sequence: SequenceInfo
    @Binding var userSelectedChain: EthNode?

    var chainToUse: EthNode {
        userSelectedChain ?? sequence.chain
    }

    var body: some View {
        HStack {
            Button(
                action: {
                    sequence.onReject()
                    hideOverlaySheet()
                },
                label: {
                    Text("Cancel")
                        .frame(maxWidth: .infinity)
                }
            ).buttonStyle(.wallet(.secondary))
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
                                Text("Confirm")
                            },
                            icon: {
                                Symbol(decorative: .faceid)
                            }
                        )
                        .frame(maxWidth: .infinity)

                    }
                }
            ).buttonStyle(.wallet(.primary))
        }
    }
}

struct MaliciousSiteView: View {
    @Environment(\.hideOverlay) private var hideOverlaySheet
    let domain: String
    let trustSignal: TrustSignal
    let alternativeDomain: String?

    let navigateToAlternateDomain: () -> Void
    let closeTab: () -> Void

    var body: some View {
        VStack(spacing: 24) {
            VStack(spacing: 8) {
                Image("malicious-warning")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 48, height: 48)
                    .background(Color.white)
                    .clipShape(Circle())
                Text(domain)
                    .withFont(.labelLarge)
                    .foregroundColor(.label)
                if let trustedDomain = alternativeDomain {
                    (Text("This site has a similar address to the verified site ")
                        + Text(trustedDomain).bold())
                    Text(
                        "A misleading address like this is commonly used by malicious sites to scam people."
                    )
                    Text(
                        "Reason: Wrong extension"
                    )
                } else if case .malicious = trustSignal {
                    Text("This site has been identified as malicious.")
                }
            }
            .withFont(unkerned: .bodyLarge)
            .foregroundColor(Color(light: .brand.variant.red, dark: .brand.red))
            .fixedSize(horizontal: false, vertical: true)
            .multilineTextAlignment(.center)
            .frame(maxWidth: .infinity)
            .padding(12)
            .background(Color.quaternarySystemFill)
            .cornerRadius(12)
            Text("To protect your wallet, we will not connect to this site.")
                .withFont(.bodyXLarge)
                .foregroundColor(.label)
                .fixedSize(horizontal: false, vertical: true)
                .multilineTextAlignment(.center)
            VStack(spacing: 16) {
                if let trustedDomain = alternativeDomain {
                    Button(
                        action: {
                            navigateToAlternateDomain()
                            DispatchQueue.main.async {
                                hideOverlaySheet()
                            }
                        },
                        label: {
                            Text("Navigate to \(trustedDomain)")
                                .frame(maxWidth: .infinity)
                        }
                    ).buttonStyle(.wallet(.primary))
                }
                Button(
                    action: {
                        closeTab()
                        hideOverlaySheet()
                    },
                    label: {
                        Text("Close Tab")
                            .frame(maxWidth: .infinity)
                    }
                ).buttonStyle(.wallet(.secondary))
            }.padding(.bottom, 16)
        }
        .padding(12)
        .padding(.bottom, 24)
    }
}

struct WalletSequenceSiteHeader: View {
    let iconURL: URL
    let domain: String
    let trusted: Bool

    var body: some View {
        WebImage(url: iconURL)
            .resizable()
            .placeholder {
                Color.secondarySystemFill
            }
            .transition(.opacity)
            .scaledToFit()
            .frame(width: 48, height: 48)
            .background(Color.white)
            .clipShape(Circle())
        HStack {
            if trusted {
                Image("twitter-verified-large")
                    .renderingMode(.template)
                    .resizable()
                    .scaledToFit()
                    .foregroundColor(.ui.adaptive.blue)
                    .frame(width: 16, height: 16)
            }
            Text(domain)
                .withFont(.labelLarge)
                .foregroundColor(trusted ? .ui.adaptive.blue : .label)
        }
    }
}

struct WalletSequenceBottomInfoPanel: View {
    let sequence: SequenceInfo
    let wallet: WalletAccessor
    let balance: String?

    @Binding var userSelectedChain: EthNode?

    var chainToUse: EthNode {
        userSelectedChain ?? sequence.chain
    }

    var bottomLeftHeader: String {
        switch sequence.type {
        case .sendTransaction:
            return "Transaction Fee"
        default:
            return "Wallet"
        }
    }

    @ViewBuilder var bottomRightInfo: some View {
        switch sequence.type {
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
                        switch chainToUse {
                        case .Polygon:
                            TokenType.matic.polygonLogo
                        default:
                            TokenType.matic.ethLogo
                        }
                        Text(chainToUse.rawValue)
                            .withFont(.labelLarge)
                            .lineLimit(1)
                            .foregroundColor(.label)
                        Symbol(decorative: .chevronDown)
                            .foregroundColor(.label)
                    }.frame(maxWidth: 150, alignment: .trailing)

                })

        default:
            Text(
                "\(balance ?? " ") \(chainToUse.currency.currency.rawValue)"
            )
            .withFont(.labelLarge)
            .lineLimit(1)
            .foregroundColor(.label)
            .frame(maxWidth: 150, alignment: .trailing)
        }
    }

    @ViewBuilder var bottomLeftInfo: some View {
        switch sequence.type {
        case .sendTransaction:
            TransactionFeeView(
                wallet: wallet,
                chain: sequence.chain,
                transaction: sequence.transaction!,
                options: sequence.options!
            )
        default:
            HStack(spacing: 8) {
                Circle().fill(WalletTheme.gradient).frame(width: 22, height: 22)
                Text(
                    "\(String(wallet.publicAddress.prefix(3)))...\(String(wallet.publicAddress.suffix(3)))"
                )
                .withFont(.labelLarge)
                .lineLimit(1)
                .foregroundColor(.label)
                .frame(maxWidth: 100, alignment: .leading)
            }
        }
    }

    var bottomRightHeader: String {
        switch sequence.type {
        case .sessionRequest:
            return "Network"
        default:
            return "Balance"
        }
    }

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 8) {
                Text(bottomLeftHeader)
                    .withFont(.headingSmall)
                    .foregroundColor(.secondaryLabel)
                bottomLeftInfo
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 8) {
                Text(bottomRightHeader)
                    .withFont(.headingSmall)
                    .foregroundColor(.secondaryLabel)
                bottomRightInfo
            }
        }
    }
}

struct WalletSequenceMessage: View {
    let type: SequenceType
    let dAppName: String

    var message: String {
        switch type {
        case .sessionRequest:
            return " wants to connect to your wallet"
        case .personalSign:
            return
                " wants to confirm your ownership of this wallet."
        case .signTypedData:
            return " wants to facilitate a transaction on your behalf."
        case .sendTransaction:
            return " wants to send a transaction from your wallet"
        }
    }

    var warning: String {
        switch type {
        case .personalSign:
            return
                " Signing this message does not give control over your assets."
        case .signTypedData:
            return " You will be granting this site control over your assets. Proceed with caution."
        default:
            return ""
        }
    }

    var body: some View {
        (Text(dAppName).bold() + Text(message)
            + Text(warning).foregroundColor(
                type == .personalSign ? .label : Color(light: .brand.red, dark: .brand.variant.red)))
            .withFont(.headingLarge)
            .foregroundColor(.label)
            .multilineTextAlignment(.center)
            .fixedSize(horizontal: false, vertical: true)
            .frame(maxWidth: .infinity, alignment: .center)
    }
}
