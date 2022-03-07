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
import WalletCore
import web3swift

struct WalletDashboard: View {
    @Default(.sessionsPeerIDs) var savedSessions
    @Environment(\.hideOverlay) var hideOverlay
    @EnvironmentObject var model: Web3Model

    @Binding var viewState: ViewState

    @State var showBalances: Bool = true
    @State var showSessions: Bool = true
    @State var showSendForm: Bool = false
    @State var showOverflowSheet: Bool = false
    @State var showConfirmDisconnectAlert = false
    @State var showConfirmRemoveWalletAlert = false
    @State var sessionToDisconnect: Session? = nil
    @State var showQRScanner: Bool = false
    @State var qrCodeStr: String = ""

    var addressText: String {
        "\(String(Defaults[.cryptoPublicKey].prefix(3)))...\(String(Defaults[.cryptoPublicKey].suffix(3)))"
    }

    @ViewBuilder func sheetHeader(_ title: String) -> some View {
        HStack {
            Text(title)
                .withFont(.headingMedium)
                .foregroundColor(.label)
            Spacer()
            Button(
                action: {
                    showOverflowSheet = false
                    showSendForm = false
                },
                label: {
                    Symbol(decorative: .xmark, style: .headingMedium)
                        .foregroundColor(.label)
                })
        }.padding(.vertical, 8)
        HStack(spacing: 10) {
            Circle()
                .fill(WalletTheme.gradient)
                .frame(width: 34, height: 34)
                .padding(4)
            VStack(alignment: .leading, spacing: 0) {
                Text(addressText)
                    .withFont(.bodyMedium)
                    .foregroundColor(.label)
                    .lineLimit(1)
                if let balance = model.balanceFor(.ether) {
                    Text("\(balance) ETH")
                        .withFont(.bodySmall)
                        .foregroundColor(.secondaryLabel)
                }
            }
            Spacer()
        }.padding(.vertical, 16)
    }

    @ViewBuilder var overflowMenu: some View {
        Button(
            action: { showOverflowSheet = true },
            label: {
                Symbol(decorative: .chevronDown, style: .headingXLarge)
                    .foregroundColor(.label)
            }
        ).sheet(
            isPresented: $showOverflowSheet, onDismiss: {},
            content: {
                VStack {
                    sheetHeader("Wallets")
                    Button(
                        action: onExportWallet,
                        label: {
                            Text("View Secret Recovery Phrase")
                                .frame(maxWidth: .infinity)
                        }
                    ).buttonStyle(.wallet(.secondary))
                    Button(
                        action: {
                            showConfirmRemoveWalletAlert = true
                        }
                    ) {
                        Text("Remove Wallet")
                            .frame(maxWidth: .infinity)
                    }.buttonStyle(.wallet(.secondary))
                    Spacer()
                }
                .padding(.horizontal, 16)
                .actionSheet(isPresented: $showConfirmRemoveWalletAlert) {
                    confirmRemoveWalletSheet
                }
            })
    }

    func onExportWallet() {
        let context = LAContext()
        let reason =
            "Exporting wallet secret phrase requires authentication"
        let onAuth: (Bool, Error?) -> Void = {
            success, authenticationError in
            if success {
                showOverflowSheet = false
                viewState = .showPhrases
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
    }

    var accountInfo: some View {
        VStack(spacing: 0) {
            Circle()
                .fill(WalletTheme.gradient)
                .frame(width: 48, height: 48)
                .padding(8)
            HStack(spacing: 0) {
                Text(addressText)
                    .withFont(.headingXLarge)
                    .lineLimit(1)
                overflowMenu
            }

            HStack(spacing: 12) {
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
                    HStack(spacing: 4) {
                        Symbol(decorative: .docOnDoc, style: .bodyMedium)
                        Text("Copy address")
                    }
                }.buttonStyle(WalletDashboardButtonStyle())
                Button(action: { showQRScanner = true }) {
                    HStack(spacing: 4) {
                        Symbol(decorative: .qrcodeViewfinder, style: .bodyMedium)
                        Text("Scan")
                    }
                }.sheet(isPresented: $showQRScanner) {
                    ScannerView(
                        showQRScanner: $showQRScanner, returnAddress: $qrCodeStr,
                        onComplete: onScanComplete)
                }.buttonStyle(WalletDashboardButtonStyle())
                Button(action: { showSendForm = true }) {
                    HStack(spacing: 4) {
                        Symbol(decorative: .paperplane, style: .bodyMedium)
                        Text("Send")
                    }
                }
                .buttonStyle(WalletDashboardButtonStyle())
                .sheet(isPresented: $showSendForm, onDismiss: {}) {
                    VStack {
                        sheetHeader("Send")
                        SendForm(showSendForm: $showSendForm)
                        Spacer()
                    }
                    .padding(.horizontal, 16)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
        }
        .padding(.top, 24)
        .modifier(WalletListSeparatorModifier())
    }

    var balancesSection: some View {
        Section(
            content: {
                if showBalances {
                    ForEach(
                        TokenType.allCases.filter {
                            $0 == .ether || Double(model.balanceFor($0) ?? "0") != 0
                        }, id: \.rawValue
                    ) {
                        token in
                        HStack {
                            token.thumbnail.padding(.leading, 4)
                            VStack(alignment: .leading, spacing: 0) {
                                Text(token.currency.name)
                                    .withFont(.bodyMedium)
                                    .fixedSize(horizontal: false, vertical: true)
                                    .foregroundColor(.label)
                                Text(token.network.rawValue)
                                    .withFont(.bodySmall)
                                    .foregroundColor(.secondaryLabel)
                            }
                            Spacer()
                            VStack(alignment: .trailing, spacing: 0) {
                                Text(
                                    "$\(token.toUSD(model.balanceFor(token) ?? "0"))"
                                )
                                .foregroundColor(.label)
                                .withFont(.bodyMedium)
                                .frame(alignment: .center)
                                Text("\(model.balanceFor(token) ?? "") \(token.currency.rawValue)")
                                    .withFont(.bodySmall)
                                    .foregroundColor(.secondaryLabel)
                            }

                        }.modifier(WalletListSeparatorModifier())
                    }
                }
            },
            header: {
                HStack {
                    Text("Balances")
                        .withFont(.headingMedium)
                        .foregroundColor(.label)
                    Spacer()
                    Button(action: {
                        showBalances.toggle()
                    }) {
                        Symbol(
                            decorative: showBalances ? .chevronUp : .chevronDown,
                            style: .headingMedium
                        )
                        .foregroundColor(.label)
                    }
                }.padding(.vertical, 10)
            })
    }

    var openSessionsSection: some View {
        Section(
            content: {
                ForEach(
                    model.allSavedSessions.sorted(by: { $0.dAppInfo.peerId > $1.dAppInfo.peerId }),
                    id: \.url
                ) { session in
                    if showSessions, let domain = session.dAppInfo.peerMeta.url.baseDomain,
                        savedSessions.contains(session.dAppInfo.peerId)
                    {
                        HStack {
                            WebImage(url: session.dAppInfo.peerMeta.icons.first)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 34, height: 34)
                            VStack(alignment: .leading, spacing: 0) {
                                Text(session.dAppInfo.peerMeta.name)
                                    .withFont(.bodyMedium)
                                    .lineLimit(1)
                                    .foregroundColor(.label)
                                Text(domain)
                                    .withFont(.bodySmall)
                                    .foregroundColor(.secondaryLabel)
                            }
                            Spacer()
                            let chain = EthNode.from(
                                chainID: session.walletInfo?.chainId)
                            switch chain {
                            case .Polygon:
                                TokenType.matic.polygonLogo
                            default:
                                TokenType.ether.ethLogo
                            }
                        }
                        .padding(16)
                        .modifier(
                            SessionActionsModifier(
                                session: session,
                                showConfirmDisconnectAlert: $showConfirmDisconnectAlert,
                                sessionToDisconnect: $sessionToDisconnect)
                        )
                        .modifier(WalletListSeparatorModifier())
                    }
                }
            },
            header: {
                if !model.allSavedSessions.isEmpty {
                    HStack {
                        Text("Connected Sites")
                            .withFont(.headingMedium)
                            .foregroundColor(.label)
                        Spacer()
                        Button(action: {
                            showSessions.toggle()
                        }) {
                            Symbol(
                                decorative: showSessions ? .chevronUp : .chevronDown,
                                style: .headingMedium
                            )
                            .foregroundColor(.label)
                        }
                    }.padding(.vertical, 10)
                }
            })
    }

    var confirmRemoveWalletSheet: ActionSheet {
        ActionSheet(
            title: Text(
                "Are you sure you want to remove all keys for your wallet from this device? "
            ),
            buttons: [
                .destructive(
                    Text("Remove Wallet from device"),
                    action: {
                        showOverflowSheet = false
                        showConfirmRemoveWalletAlert = false
                        viewState = .starter
                        hideOverlay()
                        Defaults[.cryptoPhrases] = ""
                        Defaults[.cryptoPublicKey] = ""
                        Defaults[.cryptoPrivateKey] = ""
                        Defaults[.sessionsPeerIDs].forEach {
                            Defaults[.dAppsSession($0)] = nil
                        }
                        Defaults[.sessionsPeerIDs] = Set<String>()
                        model.wallet = WalletAccessor()
                    }),
                .cancel(),
            ])
    }

    var confirmDisconnectSheet: ActionSheet {
        ActionSheet(
            title: Text(
                "Are you sure you want to disconnect from \(sessionToDisconnect?.dAppInfo.peerMeta.url.baseDomain ?? "")?"
            ),
            buttons: [
                .destructive(
                    Text("Disconnect"),
                    action: {
                        let session = sessionToDisconnect!
                        DispatchQueue.global(qos: .userInitiated).async {
                            try? model.server?.disconnect(from: session)
                        }
                        Defaults[.sessionsPeerIDs].remove(session.dAppInfo.peerId)
                        sessionToDisconnect = nil
                    }),
                .cancel(),
            ])
    }

    var body: some View {
        NavigationView {
            List {
                accountInfo
                balancesSection
                openSessionsSection
                    .actionSheet(isPresented: $showConfirmDisconnectAlert) {
                        confirmDisconnectSheet
                    }
            }
            .modifier(WalletListStyleModifier())
            .padding(.horizontal, 16)
            .background(Color.DefaultBackground)
            .navigationBarHidden(true)
        }
        .navigationViewStyle(.automatic)
    }

    func onScanComplete() {
        hideOverlay()

        let wcStr = "wc:\(qrCodeStr)"
        if let wcURL = WCURL(wcStr.removingPercentEncoding ?? "") {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                model.presenter.connectWallet(to: wcURL)
            }
        }
    }
}

struct WalletListStyleModifier: ViewModifier {
    @EnvironmentObject var model: Web3Model

    func body(content: Content) -> some View {
        if #available(iOS 15.0, *) {
            content
                .listStyle(.plain)
                .refreshable {
                    model.updateBalances()
                }
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

struct SessionActionsModifier: ViewModifier {
    @EnvironmentObject var model: Web3Model

    let session: Session

    @Binding var showConfirmDisconnectAlert: Bool
    @Binding var sessionToDisconnect: Session?

    var switchToNode: EthNode {
        let node = EthNode.from(chainID: session.walletInfo?.chainId)
        return node == .Ethereum ? .Polygon : .Ethereum
    }

    func switchChain() {
        model.toggle(session: session, to: switchToNode)
    }

    func delete() {
        sessionToDisconnect = session
        showConfirmDisconnectAlert = true
    }

    func body(content: Content) -> some View {
        if #available(iOS 15.0, *) {
            content
                .swipeActions(edge: .trailing) {
                    Button(role: .destructive) {
                        delete()
                    } label: {
                        Label("Disconnect", systemImage: "")
                    }

                    Button {
                        switchChain()
                    } label: {
                        Label("Switch Chain", systemImage: "")
                            .foregroundColor(.white)
                    }.tint(.blue)
                }
        } else {
            content
                .contextMenu(
                    ContextMenu(menuItems: {
                        Button(
                            action: {
                                switchChain()
                            },
                            label: {
                                Label(
                                    title: { Text("Switch") },
                                    icon: {
                                        switch switchToNode {
                                        case .Polygon:
                                            TokenType.ether.polygonLogo
                                        default:
                                            TokenType.ether.ethLogo
                                        }
                                    })
                            })
                    })
                )
        }
    }
}

public struct WalletDashboardButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled

    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .withFont(unkerned: .bodyMedium)
            .foregroundColor(.label)
            .padding(12)
            .frame(height: 40)
            .background(configuration.isPressed ? Color.tertiarySystemFill : Color.clear)
            .roundedOuterBorder(cornerRadius: 20, color: .secondarySystemFill, lineWidth: 1)
            .clipShape(Capsule())
    }
}
