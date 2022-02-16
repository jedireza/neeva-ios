// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Defaults
import Foundation
import SDWebImageSwiftUI
import Shared
import SwiftUI
import WalletConnectSwift

struct SessionInfoView: View {
    @EnvironmentObject var web3Model: Web3Model

    let dAppSession: Session
    @Binding var showdAppSessionControls: Bool

    var body: some View {
        VStack {
            if let matchingCollection = web3Model.matchingCollection {
                CollectionView(collection: matchingCollection)
            } else {
                VStack {
                    HStack(alignment: .center, spacing: 8) {
                        WebImage(url: dAppSession.dAppInfo.peerMeta.icons.first)
                            .resizable()
                            .placeholder {
                                Color.secondarySystemFill
                            }
                            .transition(.opacity)
                            .scaledToFit()
                            .frame(width: 36, height: 36)
                            .cornerRadius(8)
                        Text(
                            dAppSession.dAppInfo.peerMeta.url.baseDomain ?? ""
                        )
                        .withFont(.labelLarge)
                        .foregroundColor(.ui.adaptive.blue)
                    }
                    if let description = dAppSession.dAppInfo.peerMeta.description {
                        Text(description)
                            .withFont(.bodyLarge)
                            .foregroundColor(.secondaryLabel)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
                .padding(16)
                .frame(minHeight: 300)
            }
            VStack(spacing: 8) {
                HStack(spacing: 12) {
                    Button(action: {
                        DispatchQueue.global(qos: .userInitiated).async {
                            try? web3Model.server?.disconnect(from: dAppSession)
                        }
                        Defaults[.dAppsSession(dAppSession.dAppInfo.peerId)] = nil
                        Defaults[.sessionsPeerIDs].remove(dAppSession.dAppInfo.peerId)
                        showdAppSessionControls = false
                        web3Model.currentSession = nil
                    }) {
                        HStack(spacing: 4) {
                            Symbol(decorative: .wifiSlash, style: .bodyMedium)
                            Text("Disconnect")
                        }
                    }.buttonStyle(WalletDashBoardButtonStyle())
                    let nodeToSwitchTo =
                        EthNode.from(chainID: dAppSession.walletInfo?.chainId)
                            == .Ethereum ? EthNode.Polygon : EthNode.Ethereum
                    Button(action: {
                        web3Model.toggle(session: dAppSession, to: nodeToSwitchTo)
                        showdAppSessionControls = false
                    }) {
                        HStack(spacing: 4) {
                            switch nodeToSwitchTo {
                            case .Ethereum:
                                TokenType.ether.ethLogo
                            default:
                                TokenType.matic.polygonLogo
                            }
                            Text("Switch to \(nodeToSwitchTo.rawValue)")
                        }
                    }.buttonStyle(WalletDashBoardButtonStyle())
                }
                Button(action: {
                    web3Model.showWalletPanel()
                    showdAppSessionControls = false
                }) {
                    HStack(spacing: 2) {
                        Symbol(decorative: .gear, style: .bodyMedium)
                        Text("Wallet Settings")
                    }
                }.buttonStyle(WalletDashBoardButtonStyle())
            }
        }.padding(.vertical, 16)
    }
}

struct SessionInfoButton: View {
    @EnvironmentObject var web3Model: Web3Model

    let dAppSession: Session
    @State var showdAppSessionControls: Bool = false
    @State var rotationAngle: Double = 0

    var logo: String {
        switch EthNode.from(chainID: dAppSession.walletInfo?.chainId) {
        case .Polygon:
            return "polygon-badge"
        default:
            return "eth"
        }
    }

    var body: some View {
        Button(
            action: {
                showdAppSessionControls = true
            },
            label: {
                Image(logo)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 16, height: 16)
                    .padding(2)
                    .background(Circle().fill(Color.white))
                    .padding(2)
                    .animation(nil)
                    .background(
                        Circle()
                            .fill(WalletTheme.gradient)
                            .rotationEffect(.degrees(rotationAngle))
                            .animation(nil)
                            .onAppear {
                                withAnimation(.easeInOut(duration: 3).repeatForever()) {
                                    rotationAngle = 360
                                }
                            }
                    )
            }
        ).presentAsPopover(
            isPresented: $showdAppSessionControls,
            dismissOnTransition: true
        ) {
            SessionInfoView(
                dAppSession: dAppSession,
                showdAppSessionControls: $showdAppSessionControls
            ).environmentObject(web3Model)
        }
    }
}
