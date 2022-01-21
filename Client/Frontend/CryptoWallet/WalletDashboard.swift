// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Defaults
import MobileCoreServices
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
    @EnvironmentObject var model: Web3Model

    @State var showSendForm: Bool = false
    @State var showConfirmDisconnectAlert = false
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
                                toastManager.makeToast(text: "Address copied to clipboard")
                                    .enqueue(manager: toastManager)
                            }
                        }) {
                            Symbol(decorative: .docOnDoc)
                                .foregroundColor(.label)
                        }
                        .tapTargetFrame()
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
                                Text(token.rawValue)
                                    .withFont(.labelSmall)
                                    .lineLimit(2)
                                    .foregroundColor(.label)
                                Text("\(model.balanceFor(token) ?? "") \(token.currency)")
                                    .font(.roobert(size: 16))
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                            Text(
                                "$\(CryptoConfig.shared.etherToUSD(ether: model.balanceFor(token) ?? "0"))"
                            )
                            .foregroundColor(.label)
                            .font(.roobert(size: 24))
                            .frame(alignment: .center)
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
