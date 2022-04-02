// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Defaults
import Foundation
import Shared
import SwiftUI
import WalletConnectSwift
import WalletCore
import web3swift

extension Defaults.Keys {
    static func dAppsSession(_ sessionID: String) -> Defaults.Key<Data?> {
        Defaults.Key("DataForSession" + sessionID)
    }
}

protocol WalletConnectPresenter: ModalPresenter {
    @discardableResult func connectWallet(to wcURL: WCURL) -> Bool
}

extension BrowserViewController: ServerDelegate, WalletConnectPresenter {
    @discardableResult func connectWallet(to wcURL: WCURL) -> Bool {
        guard FeatureFlag[.enableCryptoWallet], let _ = web3Model.wallet?.ethereumAddress
        else {
            return false
        }

        web3Model.startSequence()
        DispatchQueue.global(qos: .userInitiated).async {
            try? self.server?.connect(to: wcURL)
        }
        return true
    }

    func configureWalletServer() {
        self.server = Server(delegate: self)
        server!.register(handler: PersonalSignHandler(relay: self.web3Model))
        server!.register(handler: SendTransactionHandler(relay: self.web3Model))
        server!.register(handler: SignTypedDataHandler(relay: self.web3Model))
        web3Model.updateCurrentSession()
    }

    func server(_ server: Server, didFailToConnect url: WCURL) {
        LogService.shared.log("WC: Did fail to connect")
    }

    func server(
        _ server: Server, shouldStart session: Session,
        completion: @escaping (Session.WalletInfo) -> Void
    ) {
        guard let wallet = self.web3Model.wallet else {
            let walletInfo = Session.WalletInfo(
                approved: false,
                accounts: [],
                chainId: session.dAppInfo.chainId ?? 1,
                peerId: UUID().uuidString,
                peerMeta: Session.ClientMeta(name: "", description: "", icons: [], url: .aboutBlank)
            )
            completion(walletInfo)
            return
        }

        LogService.shared.log(
            "WC: Should Start from \(String(describing: session.dAppInfo.peerMeta.url.baseDomain))")
        DispatchQueue.main.async {
            self.web3Model.currentSequence = SequenceInfo(
                type: .sessionRequest,
                thumbnailURL: session.dAppInfo.peerMeta.icons.first ?? .aboutBlank,
                dAppMeta: session.dAppInfo.peerMeta,
                chain: EthNode.from(chainID: session.dAppInfo.chainId),
                message: session.dAppInfo.peerMeta.description ?? "",
                onAccept: { chainID in
                    DispatchQueue.global(qos: .userInitiated).async {
                        let walletInfo = Session.WalletInfo(
                            approved: true,
                            accounts: [wallet.publicAddress],
                            chainId: chainID,
                            peerId: UUID().uuidString,
                            peerMeta: wallet.walletMeta)
                        completion(walletInfo)
                    }
                    ClientLogger.shared.logCounter(
                        .ConnectedSite,
                        attributes: [
                            ClientLogCounterAttribute(
                                key: LogConfig.Web3Attribute.walletAddress,
                                value: Defaults[.cryptoPublicKey]),
                            ClientLogCounterAttribute(
                                key: LogConfig.Web3Attribute.connectedSite,
                                value: session.dAppInfo.peerMeta.url.absoluteString),
                        ])
                },
                onReject: {
                    DispatchQueue.global(qos: .userInitiated).async {
                        let walletInfo = Session.WalletInfo(
                            approved: false,
                            accounts: [wallet.publicAddress],
                            chainId: session.dAppInfo.chainId ?? 1,
                            peerId: UUID().uuidString,
                            peerMeta: wallet.walletMeta)
                        completion(walletInfo)
                    }
                })
        }
    }

    func server(_ server: Server, didConnect session: Session) {
        LogService.shared.log(
            "WC: Did connect session to \(String(describing: session.dAppInfo.peerMeta.url.baseDomain))"
        )

        // Add session to cached sessions if it is not there
        guard !Defaults[.sessionsPeerIDs].contains(session.dAppInfo.peerId) else { return }
        Defaults[.dAppsSession(session.dAppInfo.peerId)] = try! JSONEncoder().encode(session)
        Defaults[.sessionsPeerIDs].insert(session.dAppInfo.peerId)
        self.web3Model.updateCurrentSession()
    }

    func server(_ server: Server, didDisconnect session: Session) {
        LogService.shared.log(
            "WC: Did disconnect session to \(String(describing: session.dAppInfo.peerMeta.url.baseDomain))"
        )
        self.web3Model.updateCurrentSession()
        Defaults[.dAppsSession(session.dAppInfo.peerId)] = nil
        Defaults[.sessionsPeerIDs].remove(session.dAppInfo.peerId)
        DispatchQueue.main.async {
            if let toastManager = self.getSceneDelegate()?.toastViewManager {
                toastManager.makeToast(
                    text:
                        "Disconnected from \(session.dAppInfo.peerMeta.name)"
                )
                .enqueue(manager: toastManager)
            }
        }
    }

    func server(_ server: Server, didUpdate session: Session) {
        LogService.shared.log(
            "WC: Did update session to \(String(describing: session.dAppInfo.peerMeta.url.baseDomain))"
        )
        guard session.walletInfo!.approved else { return }

        Defaults[.dAppsSession(session.dAppInfo.peerId)] = try! JSONEncoder().encode(session)
        Defaults[.sessionsPeerIDs].insert(session.dAppInfo.peerId)
    }
}
