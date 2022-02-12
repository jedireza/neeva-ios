// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import BigInt
import Combine
import Defaults
import Foundation
import Shared
import SwiftUI
import WalletConnectSwift
import XCGLogger
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
    let chain: EthNode
    let message: String
    let onAccept: (Int) -> Void
    let onReject: () -> Void
    var transaction: EthereumTransaction? = nil
    var options: TransactionOptions? = nil
}

class Web3Model: ObservableObject, ResponseRelay {
    var publicAddress: String {
        wallet?.publicAddress ?? ""
    }

    func send(
        on chain: EthNode, transactionData: TransactionData
    ) throws -> String {
        try wallet?.send(
            on: chain, transactionData: transactionData) ?? ""
    }

    func sign(on chain: EthNode, message: String, using publicAddress: String) throws -> String {
        try wallet?.sign(on: chain, message: message, using: publicAddress) ?? ""
    }

    @Published var currentSequence: SequenceInfo? = nil {
        didSet {
            guard let sequence = currentSequence, let wallet = wallet else { return }
            tryMatchCurrentPageToCollection()

            updateBalances()
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
    @Published var showingMaliciousSiteWarning = false

    let server: Server?
    let presenter: WalletConnectPresenter
    var selectedTab: Tab?
    var wallet: WalletAccessor?
    var communityBasedTrustSignals = [String: TrustSignal]()

    var trustSignal: TrustSignal {
        if let matchingCollection = matchingCollection,
            matchingCollection.safelistRequestStatus >= .approved
        {
            return .trusted
        }

        guard let baseDomain = selectedTab?.url?.baseDomain else { return .notTrusted }

        if let signal = communityBasedTrustSignals[baseDomain] {
            return signal
        }

        return .notTrusted
    }

    var alternateTrustedDomain: String? {
        guard
            let url =
                InternalURL(selectedTab?.url)?.isSessionRestore == true
                ? InternalURL(selectedTab?.url)?.extractedUrlParam : selectedTab?.url,
            let baseDomain = url.baseDomain,
            case .notTrusted = trustSignal,
            let index = baseDomain.lastIndex(of: ".")
        else {
            return nil
        }

        let alternateDomain = web3Extensions.map({ String(baseDomain.prefix(upTo: index)) + $0 })
            .filter({ communityBasedTrustSignals[$0] == .trusted }).first

        return alternateDomain != baseDomain ? alternateDomain : nil
    }

    var balances: [TokenType: String?] = [
        .ether: nil, .wrappedEther: nil, .matic: nil, .usdc: nil, .usdt: nil, .shib: nil,
        .wrappedEtherOnPolygon: nil, .maticOnPolygon: nil, .usdcOnPolygon: nil, .usdtOnPolygon: nil,
    ]

    func balanceFor(_ token: TokenType) -> String? {
        balances[token]!
    }

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
        self.wallet = FeatureFlag[.enableCryptoWallet] ? WalletAccessor() : nil

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

    func updateBalances() {
        CurrencyStore.shared.refresh()
        balances.keys.forEach { token in
            wallet?.tokenBalance(token: token) { balance in
                self.balances[token] = balance
                self.objectWillChange.send()
            }
        }
    }

    func updateCurrentSession() {
        let url =
            InternalURL(selectedTab?.url)?.isSessionRestore == true
            ? InternalURL(selectedTab?.url)?.extractedUrlParam : selectedTab?.url

        if let domain = url?.baseDomain, wallet?.publicAddress.isEmpty == false {
            if self.communityBasedTrustSignals[domain] == nil {
                TrustSignalController.getTrustSignals(domain: domain) { result in
                    switch result {
                    case .failure(let error):
                        Logger.browser.info("Trust signal query failed with \(error)")
                    case .success(let signals):
                        signals.forEach({
                            guard let domain = $0.domain, let signal = $0.signal else { return }
                            self.communityBasedTrustSignals[domain] = signal
                        })

                        self.checkForMaliciousContent()
                    }
                }
            } else {
                checkForMaliciousContent()
            }
        }

        DispatchQueue.main.async {
            self.currentSession =
                self.server?.openSessions().first(where: {
                    $0.dAppInfo.peerMeta.url.baseDomain == url?.baseDomain
                })
        }
    }

    func checkForMaliciousContent() {
        if !showingMaliciousSiteWarning, alternateTrustedDomain != nil || trustSignal == .malicious
        {
            showingMaliciousSiteWarning = true
            startSequence()
        }
    }

    func reset() {
        currentSequence = nil
        showingMaliciousSiteWarning = false
    }

    func tryWalletConnect() {
        if let wallet = wallet, wallet.publicAddress.isEmpty, !Defaults[.cryptoPublicKey].isEmpty {
            // This would only happen if we created/imported a wallet within this session
            self.wallet = WalletAccessor()
        }
        selectedTab?.webView?
            .evaluateJavascriptInDefaultContentWorld(
                WalletConnectDetector.scrapeWalletConnectURI
            ) {
                object, error in
                guard let walletConnectUriString = object as? String,
                    let wcURL = WCURL(walletConnectUriString.removingPercentEncoding ?? "")
                else { return }
                self.presenter.connectWallet(to: wcURL)
                DispatchQueue.main.async {
                    self.tryMatchCurrentPageToCollection()
                }
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
                            DispatchQueue.main.async {
                                self.matchingCollection = collection
                            }
                        }
                    }
                }
            }
    }

    func startSequence() {
        presenter.showModal(
            style: .spaces,
            headerButton: nil,
            content: {
                WalletSequenceContent(model: self)
                    .overlayIsFixedHeight(isFixedHeight: true)
            }, onDismiss: { self.reset() })
    }

    func showWalletPanel() {
        updateBalances()
        presenter.showModal(
            style: .spaces,
            headerButton: nil,
            content: {
                CryptoWalletView()
                    .environmentObject(self)
                    .overlayIsFixedHeight(isFixedHeight: true)

            }, onDismiss: { self.reset() })
    }

    func toggle(session: Session, to chain: EthNode) {
        guard let walletInfo = session.walletInfo else {
            return
        }
        let info = Session.WalletInfo(
            approved: walletInfo.approved,
            accounts: walletInfo.accounts,
            chainId: chain.id, peerId: walletInfo.peerId,
            peerMeta: walletInfo.peerMeta)
        try? server?.updateSession(session, with: info)
        var updatedSession = session
        updatedSession.walletInfo = info
        Defaults[.dAppsSession(updatedSession.dAppInfo.peerId)] =
            try! JSONEncoder().encode(updatedSession)
        Defaults[.sessionsPeerIDs].insert(updatedSession.dAppInfo.peerId)
    }

    func send(_ response: Response) {
        server?.send(response)
    }

    func askToTransact(
        request: Request,
        options: TransactionOptions,
        transaction: EthereumTransaction,
        transact: @escaping (EthNode) -> String
    ) {
        guard
            let session = server?.openSessions().first(where: {
                $0.dAppInfo.peerMeta.url.baseDomain
                    == currentSession?.dAppInfo.peerMeta.url.baseDomain
            }), let walletInfo = session.walletInfo
        else {
            send(.reject(request))
            return
        }
        let dappInfo = session.dAppInfo

        DispatchQueue.main.async {
            self.currentSequence = SequenceInfo(
                type: .sendTransaction,
                thumbnailURL: dappInfo.peerMeta.icons.first ?? .aboutBlank,
                dAppMeta: dappInfo.peerMeta,
                chain: EthNode.from(chainID: walletInfo.chainId),
                message:
                    "This will transfer this amount from your wallet to a wallet provided by \(dappInfo.peerMeta.name).",
                onAccept: { chainId in
                    DispatchQueue.global(qos: .userInitiated).async {
                        self.server?.send(
                            .transaction(transact(EthNode.from(chainID: chainId)), for: request)
                        )
                    }
                },
                onReject: {
                    DispatchQueue.global(qos: .userInitiated).async {
                        self.server?.send(.reject(request))
                    }
                },
                transaction: transaction,
                options: options
            )
            self.startSequence()
        }
    }

    func askToSign(request: Request, message: String, sign: @escaping (EthNode) -> String) {
        guard
            let session = server?.openSessions().first(where: {
                $0.dAppInfo.peerMeta.url.baseDomain
                    == currentSession?.dAppInfo.peerMeta.url.baseDomain
            }), let walletInfo = session.walletInfo
        else {
            send(.reject(request))
            return
        }
        let dappInfo = session.dAppInfo

        DispatchQueue.main.async {
            self.currentSequence = SequenceInfo(
                type: .personalSign,
                thumbnailURL: dappInfo.peerMeta.icons.first ?? .aboutBlank,
                dAppMeta: dappInfo.peerMeta,
                chain: EthNode.from(chainID: walletInfo.chainId),
                message:
                    message,
                onAccept: { chainId in
                    DispatchQueue.global(qos: .userInitiated).async {
                        let signature = sign(EthNode.from(chainID: chainId))
                        self.server?.send(.signature(signature, for: request))
                    }
                },
                onReject: {
                    DispatchQueue.global(qos: .userInitiated).async {
                        self.server?.send(.reject(request))
                    }
                })
            self.startSequence()
        }
    }

    public func createWallet(completion: @escaping () -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                let password = CryptoConfig.shared.password
                let bitsOfEntropy: Int = 128
                let mnemonics = try! BIP39.generateMnemonics(bitsOfEntropy: bitsOfEntropy)!

                Defaults[.cryptoPhrases] = mnemonics

                let keystore = try! BIP32Keystore(
                    mnemonics: mnemonics,
                    password: password,
                    mnemonicsPassword: "",
                    language: .english)!
                let name = CryptoConfig.shared.walletName
                let keyData = try! JSONEncoder().encode(keystore.keystoreParams)

                let address = keystore.addresses!.first!.address
                let wallet = Wallet(address: address, data: keyData, name: name, isHD: true)

                let privateKey = try keystore.UNSAFE_getPrivateKeyData(
                    password: password, account: EthereumAddress(address)!
                ).toHexString()
                Defaults[.cryptoPrivateKey] = privateKey

                Defaults[.cryptoPublicKey] = wallet.address
                completion()
                self.wallet = WalletAccessor()
                self.updateBalances()
            } catch {
                Logger.browser.error("Unexpected create wallet error: \(error).")
            }
        }
    }

    public func importWallet(inputPhrase: String, completion: @escaping () -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                let password = CryptoConfig.shared.password
                let mnemonics = inputPhrase
                let keystore = try! BIP32Keystore(
                    mnemonics: mnemonics,
                    password: password,
                    mnemonicsPassword: "",
                    language: .english)!
                let address = keystore.addresses!.first!.address
                Defaults[.cryptoPhrases] = mnemonics
                Defaults[.cryptoPublicKey] = address
                let privateKey = try keystore.UNSAFE_getPrivateKeyData(
                    password: password, account: EthereumAddress(address)!
                ).toHexString()
                Defaults[.cryptoPrivateKey] = privateKey
                completion()
                self.wallet = WalletAccessor()
                self.updateBalances()
            } catch {
                print("🔥 Unexpected error: \(error).")
            }
        }
    }
}
