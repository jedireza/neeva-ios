// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Combine
import Foundation
import Shared
import SwiftUI
import WalletConnectSwift
import web3swift

enum SequenceType: String {
    case sessionRequest
    case personalSign
    case sendTransaction
}

struct SequenceInfo {
    let type: SequenceType
    let thumbnailURL: URL
    let dAppMeta: Session.ClientMeta
    let message: String
    let onAccept: () -> Void
    let onReject: () -> Void
    var ethAmount: String? = nil
}

class Web3Model: ObservableObject, ResponseRelay {
    @Published var currentSequence: SequenceInfo? = nil {
        didSet {
            guard currentSequence != nil else { return }
            tryMatchCurrentPageToCollection()
        }
    }
    @Published var currentSession: Session? {
        didSet {
            guard currentSession != nil else { return }
            tryMatchCurrentPageToCollection()
        }
    }
    @Published var showingWalletDetails = false
    @Published var matchingCollection: Collection?
    @Published var wcURL: WCURL? = nil

    let server: Server?
    let presenter: WalletConnectPresenter
    var selectedTab: Tab?

    private var selectedTabSubscription: AnyCancellable? = nil
    private var urlSubscription: AnyCancellable? = nil
    private var walletConnectSubscription: AnyCancellable? = nil

    init(server: Server?, presenter: WalletConnectPresenter, tabManager: TabManager) {
        self.server = server
        self.presenter = presenter
        self.currentSession =
            server?.openSessions().first(where: {
                $0.dAppInfo.peerMeta.url.baseDomain
                    == tabManager.selectedTab?.url?.baseDomain
            })
        self.selectedTab = tabManager.selectedTab

        self.selectedTabSubscription = tabManager.selectedTabPublisher.sink { tab in
            guard let tab = tab else { return }

            self.selectedTab = tab
            self.updateCurrentSession()
            self.urlSubscription = tab.$url.sink { _ in
                self.updateCurrentSession()
            }
        }

        self.walletConnectSubscription = WalletConnectDetector.shared.$walletConnectURL.sink {
            url in
            if let baseDomain = url?.baseDomain, baseDomain == self.selectedTab?.url?.baseDomain {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self.tryWalletConnect()
                }
            }
        }
    }

    func updateCurrentSession() {
        let url =
            InternalURL(selectedTab?.url)?.isSessionRestore == true
            ? InternalURL(selectedTab?.url)?.extractedUrlParam : selectedTab?.url

        DispatchQueue.main.async {
            self.currentSession =
                self.server?.openSessions().first(where: {
                    $0.dAppInfo.peerMeta.url.baseDomain == url?.baseDomain
                })
        }
    }

    func reset() {
        currentSequence = nil
        wcURL = nil
    }

    func tryWalletConnect() {
        selectedTab?.webView?
            .evaluateJavascriptInDefaultContentWorld(
                WalletConnectDetector.scrapeWalletConnectURI
            ) {
                object, error in
                guard let walletConnectUriString = object as? String,
                    let wcURL = WCURL(walletConnectUriString.removingPercentEncoding ?? "")
                else { return }

                self.wcURL = wcURL
                self.presenter.showModal(
                    style: .withTitle,
                    headerButton: nil,
                    content: {
                        WalletSequenceContent(model: self)
                    }, onDismiss: { self.reset() })
                self.tryMatchCurrentPageToCollection()
            }
    }

    func tryMatchCurrentPageToCollection() {
        matchingCollection = AssetStore.shared.collections.first(
            where: {
                $0.externalURL?.baseDomain
                    == self.selectedTab?.url?.baseDomain
            })

        guard matchingCollection?.stats == nil else { return }

        selectedTab?.webView?
            .evaluateJavascriptInDefaultContentWorld(
                Collection.scrapeForOpenSeaLink
            ) {
                object, error in
                guard let openSeaSlugs = object as? [String],
                    !openSeaSlugs.isEmpty
                else { return }

                DispatchQueue.global(qos: .userInitiated).async {
                    AssetStore.shared.fetch(collection: openSeaSlugs[0]) { collection in
                        if self.selectedTab?.url?.baseDomain
                            == collection.externalURL?.baseDomain
                        {
                            print(
                                "WC: collection \(collection.name) checks out!"
                            )
                            self.matchingCollection = collection
                        }
                    }
                }
            }
    }

    func send(_ response: Response) {
        server?.send(response)
    }

    func askToTransact(request: Request, value: String, transact: @escaping () -> String) {
        guard
            let dappInfo = server?.openSessions().first(where: {
                $0.dAppInfo.peerMeta.url.baseDomain
                    == currentSession?.dAppInfo.peerMeta.url.baseDomain
            })?.dAppInfo
        else {
            send(.reject(request))
            return
        }

        DispatchQueue.main.async {
            self.currentSequence = SequenceInfo(
                type: .sendTransaction,
                thumbnailURL: dappInfo.peerMeta.icons.first ?? .aboutBlank,
                dAppMeta: dappInfo.peerMeta,
                message:
                    "This will transfer this amount from your wallet to a wallet provided by \(dappInfo.peerMeta.name).",
                onAccept: {
                    DispatchQueue.global(qos: .userInitiated).async {
                        self.server?.send(.transaction(transact(), for: request))
                    }
                },
                onReject: {
                    DispatchQueue.global(qos: .userInitiated).async {
                        self.server?.send(.reject(request))
                    }
                },
                ethAmount: Web3.Utils.formatToEthereumUnits(Web3.Utils.hexToBigUInt(value) ?? .zero)
            )
            self.presenter.showModal(
                style: .spaces,
                headerButton: nil,
                content: {
                    WalletSequenceContent(model: self)
                },
                onDismiss: {
                    self.currentSequence = nil
                })
        }
    }

    func askToSign(request: Request, sign: @escaping () -> String) {
        guard
            let dappInfo = server?.openSessions().first(where: {
                $0.dAppInfo.peerMeta.url.baseDomain
                    == currentSession?.dAppInfo.peerMeta.url.baseDomain
            })?.dAppInfo
        else {
            send(.reject(request))
            return
        }

        DispatchQueue.main.async {
            self.currentSequence = SequenceInfo(
                type: .personalSign,
                thumbnailURL: dappInfo.peerMeta.icons.first ?? .aboutBlank,
                dAppMeta: dappInfo.peerMeta,
                message:
                    "This will not make any transactions with your wallet. But Neeva will be using your private key to sign the message.",
                onAccept: {
                    DispatchQueue.global(qos: .userInitiated).async {
                        let signature = sign()
                        self.server?.send(.signature(signature, for: request))
                    }
                },
                onReject: {
                    DispatchQueue.global(qos: .userInitiated).async {
                        self.server?.send(.reject(request))
                    }
                })
            self.presenter.showModal(
                style: .spaces,
                headerButton: nil,
                content: {
                    WalletSequenceContent(model: self)
                },
                onDismiss: {
                    self.currentSequence = nil
                })
        }
    }
}
