// Copyright Neeva. All rights reserved.

import Defaults
import Foundation
import Shared
import SwiftUI
import WalletConnectSwift
import web3swift

extension BrowserViewController: ServerDelegate, ResponseRelay {
    func key(for sessionID: String) -> String {
        "DataForSession" + sessionID
    }

    @discardableResult func connectWallet(to wcURL: WCURL) -> Bool {
        guard FeatureFlag[.enableCryptoWallet] else {
            return false
        }

        do {
            try server?.connect(to: wcURL)
            showModal(
                style: .spaces,
                content: {
                    WalletTransactionContent(model: self.web3SessionModel)
                }, onDismiss: { self.web3SessionModel.reset() })
            return true
        } catch {
            return false
        }
    }

    func configureWalletServer() {
        self.server = Server(delegate: self)
        server!.register(handler: PersonalSignHandler(relay: self))
        for session in Defaults[.sessionsPeerIDs] {
            if let oldSessionObject = UserDefaults.standard.object(forKey: key(for: session))
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
            self.web3SessionModel.transaction = TransactionInfo(
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
        UserDefaults.standard.set(sessionData, forKey: key(for: session.dAppInfo.peerId))
        Defaults[.sessionsPeerIDs].insert(session.dAppInfo.peerId)
    }

    func server(_ server: Server, didDisconnect session: Session) {
        LogService.shared.log(
            "WC: Did connect session to \(String(describing: session.dAppInfo.peerMeta.url.baseDomain))"
        )
    }

    func server(_ server: Server, didUpdate session: Session) {
        LogService.shared.log(
            "WC: Did update session to \(String(describing: session.dAppInfo.peerMeta.url.baseDomain))"
        )

        if session.walletInfo!.approved {
            let sessionData = try! JSONEncoder().encode(session)
            UserDefaults.standard.set(sessionData, forKey: key(for: session.dAppInfo.peerId))
            Defaults[.sessionsPeerIDs].insert(session.dAppInfo.peerId)
        } else {
            UserDefaults.standard.set(nil, forKey: key(for: session.dAppInfo.peerId))
            Defaults[.sessionsPeerIDs].remove(session.dAppInfo.peerId)
        }
    }

    func send(_ response: Response) {
        server?.send(response)
    }

    func askToSign(request: Request, message: String, sign: @escaping () -> String) {
        guard let server = server,
            let dappInfo = server.openSessions().first(where: {
                $0.dAppInfo.peerMeta.url.baseDomain == tabManager.selectedTab?.url?.baseDomain
            })?.dAppInfo
        else {
            return
        }

        DispatchQueue.main.async {
            self.web3SessionModel.transaction = TransactionInfo(
                type: .personalSign,
                thumbnailURL: dappInfo.peerMeta.icons.first ?? .aboutBlank,
                dAppMeta: dappInfo.peerMeta,
                message:
                    "This will not make any transactions with your wallet. But Neeva will be using your private key to sign the message.",
                onAccept: {
                    DispatchQueue.global(qos: .userInitiated).async {
                        let signature = sign()
                        server.send(.signature(signature, for: request))
                    }
                },
                onReject: {
                    DispatchQueue.global(qos: .userInitiated).async {
                        server.send(.reject(request))
                    }
                })
            self.showModal(
                style: .spaces,
                content: {
                    WalletTransactionContent(model: self.web3SessionModel)
                },
                onDismiss: {
                    self.web3SessionModel.transaction = nil
                })
        }
    }
}
