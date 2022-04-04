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

protocol ToastDelegate: AnyObject {
    func shouldShowToast(for message: LocalizedStringKey)
}

protocol WalletServerManagerDelegate: ToastDelegate {
    func getWeb3Model() -> Web3Model
}

class WalletServerManager {
    weak var delegate: WalletServerManagerDelegate?
    var server: Server!

    init(delegate: WalletServerManagerDelegate?) {
        self.delegate = delegate
        self.server = Server(delegate: self)
        registerToHandlers()
    }

    func registerToHandlers() {
        guard let web3Model = delegate?.getWeb3Model() else { return }
        server.register(handler: PersonalSignHandler(relay: web3Model))
        server.register(handler: SendTransactionHandler(relay: web3Model))
        server.register(handler: SignTypedDataHandler(relay: web3Model))
    }

}

extension WalletServerManager: ServerDelegate {
    func server(_ server: Server, didFailToConnect url: WCURL) {
        LogService.shared.log("WC: Did fail to connect")
    }

    func server(
        _ server: Server, shouldStart session: Session,
        completion: @escaping (Session.WalletInfo) -> Void
    ) {
        guard let wallet = delegate?.getWeb3Model().wallet else {
            let walletInfo = Session.WalletInfo(
                approved: false,
                accounts: [],
                chainId: session.dAppInfo.chainId ?? 1,
                peerId: UUID().uuidString,
                peerMeta: Session.ClientMeta(
                    name: "", description: "", icons: [], url: .aboutBlank)
            )
            completion(walletInfo)
            return
        }

        LogService.shared.log(
            "WC: Should Start from \(String(describing: session.dAppInfo.peerMeta.url.baseDomain))"
        )
        DispatchQueue.main.async {
            self.delegate?.getWeb3Model().currentSequence = SequenceInfo(
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
        self.delegate?.getWeb3Model().updateCurrentSession()
    }

    func server(_ server: Server, didDisconnect session: Session) {
        LogService.shared.log(
            "WC: Did disconnect session to \(String(describing: session.dAppInfo.peerMeta.url.baseDomain))"
        )
        self.delegate?.getWeb3Model().updateCurrentSession()
        Defaults[.dAppsSession(session.dAppInfo.peerId)] = nil
        Defaults[.sessionsPeerIDs].remove(session.dAppInfo.peerId)
        DispatchQueue.main.async {
            self.delegate?.shouldShowToast(
                for: "Disconnected from \(session.dAppInfo.peerMeta.name)")
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
