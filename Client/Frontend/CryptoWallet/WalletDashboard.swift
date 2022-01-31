// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Defaults
import LocalAuthentication
import MobileCoreServices
import SDWebImageSwiftUI
import Shared
import SwiftUI
import WalletConnectSwift
import web3swift

public enum TransactionAction: String {
    case Receive
    case Send
}

struct TransactionDetail: Hashable {
    let transactionAction: TransactionAction
    let amountInEther: String
    let oppositeAddress: String
}

struct WalletDashboard: View {
    @Environment(\.hideOverlay) var hideOverlay
    @EnvironmentObject var model: Web3Model

    @State var showSendForm: Bool = false
    @State var showConfirmDisconnectAlert = false
    @State var showConfirmRemoveWalletAlert = false
    @State var sessionToDisconnect: Session? = nil

    var body: some View {
        List {
            Section(
                content: {
                    HStack(spacing: 8) {
                        Text("\(Defaults[.cryptoPublicKey])")
                            .font(.roobert(size: 16))
                            .foregroundColor(.white)
                            .lineLimit(1)
                            .padding(8)
                            .background(Color.ui.adaptive.blue)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                        Button(action: {
                            UIPasteboard.general.setValue(
                                Defaults[.cryptoPublicKey],
                                forPasteboardType: kUTTypePlainText as String)
                            if let toastManager = model.selectedTab?.browserViewController?
                                .getSceneDelegate()?.toastViewManager
                            {
                                hideOverlay()
                                toastManager.makeToast(text: "Address copied to clipboard")
                                    .enqueue(manager: toastManager)
                            }
                        }) {
                            Symbol(decorative: .docOnDoc)
                                .foregroundColor(.label)
                                .tapTargetFrame()
                        }
                        Menu(
                            content: {
                                Button(
                                    action: {
                                        let context = LAContext()
                                        let reason =
                                            "Exporting wallet secret phrase requires authentication"
                                        let onAuth: (Bool, Error?) -> Void = {
                                            success, authenticationError in
                                            if success {
                                                UIPasteboard.general.setValue(
                                                    Defaults[.cryptoPhrases],
                                                    forPasteboardType: kUTTypePlainText as String)
                                                if let toastManager = model.selectedTab?
                                                    .browserViewController?
                                                    .getSceneDelegate()?.toastViewManager
                                                {
                                                    hideOverlay()
                                                    toastManager.makeToast(
                                                        text: "Secret phrase copied to clipboard"
                                                    )
                                                    .enqueue(manager: toastManager)
                                                }
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
                                        }
                                    },
                                    label: {
                                        Label(
                                            title: {
                                                Text("Export Wallet")
                                                    .withFont(.labelMedium)
                                                    .foregroundColor(Color.label)
                                            },
                                            icon: {
                                                Symbol(decorative: .arrowshapeTurnUpRightFill)
                                                    .foregroundColor(.label)
                                            }
                                        )
                                    })
                                if #available(iOS 15.0, *) {
                                    Button(
                                        role: .destructive,
                                        action: { showConfirmRemoveWalletAlert = true }
                                    ) {
                                        Label("Remove Wallet", systemSymbol: .trash)
                                    }
                                } else {
                                    Button(action: { showConfirmRemoveWalletAlert = true }) {
                                        Label("Remove Wallet", systemSymbol: .trash)
                                    }
                                }
                            },
                            label: {
                                Symbol(decorative: .ellipsisCircle)
                                    .foregroundColor(.label)
                                    .tapTargetFrame()
                            })
                    }.modifier(WalletListSeparatorModifier())
                },
                header: {
                    Text("Account info")
                        .withFont(.headingMedium)
                        .foregroundColor(.label)
                })

            Section(
                content: {
                    ForEach(
                        TokenType.allCases.filter {
                            $0 == .ether || Double(model.balanceFor($0) ?? "0") != 0
                        }, id: \.rawValue
                    ) {
                        token in
                        HStack {
                            token.thumbnail
                            VStack(alignment: .leading, spacing: 8) {
                                Text(token.name)
                                    .withFont(.labelSmall)
                                    .fixedSize(horizontal: false, vertical: true)
                                    .foregroundColor(.label)
                                Text(token.network.rawValue)
                                    .font(.roobert(size: 16))
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                            VStack(alignment: .trailing, spacing: 8) {
                                Text(
                                    "$\(CryptoConfig.shared.toUSD(from: token, amount: model.balanceFor(token) ?? "0"))"
                                )
                                .foregroundColor(.label)
                                .font(.roobert(size: 20))
                                .frame(alignment: .center)
                                Text("\(model.balanceFor(token) ?? "") \(token.currency)")
                                    .font(.roobert(size: 12))
                                    .foregroundColor(.secondary)
                            }

                        }
                    }
                },
                header: {
                    Text("Balances")
                        .withFont(.headingMedium)
                        .foregroundColor(.label)
                })

            Section(
                content: {
                    ForEach(model.server?.openSessions() ?? [], id: \.url) { session in
                        if let domain = session.dAppInfo.peerMeta.url.baseDomain {
                            HStack {
                                Text(domain)
                                    .withFont(.labelSmall)
                                    .foregroundColor(.label)
                                Spacer()
                                Menu(
                                    content: {
                                        ForEach([EthNode.Ethereum, EthNode.Polygon]) { node in
                                            Button(
                                                action: {
                                                    model.toggle(session: session, to: node)
                                                },
                                                label: {
                                                    Text(node.rawValue)
                                                        .withFont(.labelSmall)
                                                        .foregroundColor(.label)
                                                })
                                        }
                                    },
                                    label: {
                                        let chain = EthNode.from(
                                            chainID: session.walletInfo?.chainId)
                                        switch chain {
                                        case .Polygon:
                                            TokenType.matic.polygonLogo
                                        default:
                                            TokenType.ether.ethLogo
                                        }
                                    })
                                Button(action: {
                                    sessionToDisconnect = session
                                    showConfirmDisconnectAlert = true
                                }) {
                                    Symbol(decorative: .xmarkCircleFill)
                                        .foregroundColor(.label)
                                }
                                .tapTargetFrame()
                            }
                        }
                    }
                },
                header: {
                    if !(model.server?.openSessions() ?? []).isEmpty {
                        Text("Open Sessions")
                            .withFont(.headingMedium)
                            .foregroundColor(.label)
                    }
                })

            if showSendForm {
                SendForm(showSendForm: $showSendForm)
                    .modifier(WalletListSeparatorModifier())
            } else {
                Button(action: { showSendForm = true }) {
                    Text("Send ETH")
                        .font(.roobert(.semibold, size: 18))
                        .frame(maxWidth: .infinity, alignment: .center)
                }
                .buttonStyle(.neeva(.primary))
                .padding(.top, 8)
                .modifier(WalletListSeparatorModifier())
            }
        }
        .modifier(WalletListStyleModifier())
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .padding(.horizontal, 25)
        .padding(.bottom, 72)
        .actionSheet(isPresented: $showConfirmDisconnectAlert) {
            ActionSheet(
                title: Text(
                    "Are you sure you want to disconnect from \(sessionToDisconnect?.dAppInfo.peerMeta.url.baseDomain ?? "")?"
                ),
                buttons: [
                    .destructive(
                        Text("Disconnect (May take a few secs)"),
                        action: {
                            let session = sessionToDisconnect!
                            DispatchQueue.global(qos: .userInitiated).async {
                                try? model.server?.disconnect(from: session)
                            }
                            sessionToDisconnect = nil
                        })
                ])
        }.actionSheet(isPresented: $showConfirmRemoveWalletAlert) {
            ActionSheet(
                title: Text(
                    "Are you sure you want to remove all keys for your wallet from this device? "
                ),
                buttons: [
                    .destructive(
                        Text("Remove Wallet from device"),
                        action: {
                            hideOverlay()
                            Defaults[.cryptoPhrases] = ""
                            Defaults[.cryptoPublicKey] = ""
                            Defaults[.cryptoPrivateKey] = ""
                            model.wallet = WalletAccessor()
                        })
                ])
        }
    }
}

struct WalletListStyleModifier: ViewModifier {
    @EnvironmentObject var model: Web3Model

    func body(content: Content) -> some View {
        if #available(iOS 15.0, *) {
            content
                .listStyle(.insetGrouped)
                .refreshable {
                    model.updateBalances()
                }
        } else {
            content
        }
    }
}

struct WalletListSeparatorModifier: ViewModifier {
    func body(content: Content) -> some View {
        if #available(iOS 15.0, *) {
            content
                .listRowInsets(
                    EdgeInsets.init(
                        top: 0,
                        leading: 0,
                        bottom: 0,
                        trailing: 0)
                )
                .listSectionSeparator(Visibility.hidden)
                .listRowSeparator(Visibility.hidden)
                .listSectionSeparatorTint(Color.clear)
                .listRowBackground(Color.clear)
        } else {
            content
                .listRowInsets(
                    EdgeInsets.init(
                        top: 0,
                        leading: 0,
                        bottom: 0,
                        trailing: 0)
                )
        }
    }
}

struct WalletDashboard_Previews: PreviewProvider {
    static var previews: some View {
        WalletDashboard()
    }
}
