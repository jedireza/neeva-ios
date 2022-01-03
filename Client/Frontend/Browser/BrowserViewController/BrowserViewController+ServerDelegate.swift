// Copyright Neeva. All rights reserved.

import Defaults
import Foundation
import Shared
import SwiftUI
import WalletConnectSwift
import web3swift

func DappsSessionKey(for sessionID: String) -> String {
    "DataForSession" + sessionID
}

extension BrowserViewController: ServerDelegate {

    @discardableResult func connectWallet(to wcURL: WCURL) -> Bool {
        guard FeatureFlag[.enableCryptoWallet] else {
            return false
        }

        do {
            try server?.connect(to: wcURL)
            showModal(
                style: .spaces,
                content: {
                    WalletSequenceContent(model: self.web3SessionModel)
                }, onDismiss: { self.web3SessionModel.reset() })
            return true
        } catch {
            return false
        }
    }

    func configureWalletServer() {
        self.server = Server(delegate: self)
        server!.register(handler: PersonalSignHandler(relay: self.web3SessionModel))
        server!.register(handler: SendTransactionHandler(relay: self.web3SessionModel))
        web3SessionModel.updateCurrentSession()
        for session in Defaults[.sessionsPeerIDs] {
            if let oldSessionObject = UserDefaults.standard.object(
                forKey: DappsSessionKey(for: session))
                as? Data,
                let session = try? JSONDecoder().decode(Session.self, from: oldSessionObject)
            {
                try? server!.reconnect(to: session)
            }
        }
    }

    func server(_ server: Server, didFailToConnect url: WCURL) {
        LogService.shared.log("WC: Did fail to connect")
    }

    func server(
        _ server: Server, shouldStart session: Session,
        completion: @escaping (Session.WalletInfo) -> Void
    ) {
        LogService.shared.log(
            "WC: Should Start from \(String(describing: session.dAppInfo.peerMeta.url.baseDomain))")
        DispatchQueue.main.async {
            let wallet = WalletAccessor()
            self.web3SessionModel.currentSequence = SequenceInfo(
                type: .sessionRequest,
                thumbnailURL: session.dAppInfo.peerMeta.icons.first ?? .aboutBlank,
                dAppMeta: session.dAppInfo.peerMeta,
                message: session.dAppInfo.peerMeta.description ?? "",
                onAccept: {
                    DispatchQueue.global(qos: .userInitiated).async {
                        let walletInfo = Session.WalletInfo(
                            approved: true,
                            accounts: [wallet.publicAddress],
                            chainId: session.dAppInfo.chainId ?? 1,
                            peerId: UUID().uuidString,
                            peerMeta: wallet.walletMeta)
                        completion(walletInfo)
                    }
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
        let sessionData = try! JSONEncoder().encode(session)
        UserDefaults.standard.set(
            sessionData, forKey: DappsSessionKey(for: session.dAppInfo.peerId))
        Defaults[.sessionsPeerIDs].insert(session.dAppInfo.peerId)
        self.web3SessionModel.updateCurrentSession()
    }

    func server(_ server: Server, didDisconnect session: Session) {
        LogService.shared.log(
            "WC: Did disconnect session to \(String(describing: session.dAppInfo.peerMeta.url.baseDomain))"
        )
        self.web3SessionModel.updateCurrentSession()
        UserDefaults.standard.set(nil, forKey: DappsSessionKey(for: session.dAppInfo.peerId))
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

        let sessionData = try! JSONEncoder().encode(session)
        UserDefaults.standard.set(
            sessionData, forKey: DappsSessionKey(for: session.dAppInfo.peerId))
        Defaults[.sessionsPeerIDs].insert(session.dAppInfo.peerId)
    }
}
