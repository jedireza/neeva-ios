// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Combine
import Defaults
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
    let chain: EthNode
    let message: String
    let onAccept: (Int) -> Void
    let onReject: () -> Void
    var ethAmount: String? = nil
}

class Web3Model: ObservableObject, ResponseRelay {
    @Published var currentSequence: SequenceInfo? = nil {
        didSet {
            guard let _ = currentSequence, let wallet = wallet else { return }
            tryMatchCurrentPageToCollection()

            wallet.gasPrice { estimate in
                self.gasEstimate = estimate
            }

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
    @Published var gasEstimate: String? = nil

    let server: Server?
    let presenter: WalletConnectPresenter
    var selectedTab: Tab?
    var wallet: WalletAccessor?

    var balances: [TokenType: String?] = [
        .ether: nil, .wrappedEther: nil, .wrappedEtherOnPolygon: nil, .maticOnPolygon: nil,
    ]

    var ethBalance: String? {
        balances[.ether]!
    }

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

        DispatchQueue.main.async {
            self.currentSession =
                self.server?.openSessions().first(where: {
                    $0.dAppInfo.peerMeta.url.baseDomain == url?.baseDomain
                })
        }
    }

    func reset() {
        currentSequence = nil
        gasEstimate = nil
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
                chain: EthNode.from(chainID: dappInfo.chainId),
                message:
                    "This will transfer this amount from your wallet to a wallet provided by \(dappInfo.peerMeta.name).",
                onAccept: { _ in
                    DispatchQueue.global(qos: .userInitiated).async {
                        self.server?.send(.transaction(transact(), for: request))
                    }
                },
                onReject: {
                    DispatchQueue.global(qos: .userInitiated).async {
                        self.server?.send(.reject(request))
                    }
                },
                ethAmount: Web3.Utils.formatToEthereumUnits(
                    Web3.Utils.hexToBigUInt(value) ?? .zero, decimals: 4)
            )
            self.startSequence()
        }
    }

    func askToSign(request: Request, message: String, sign: @escaping () -> String) {
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
                chain: EthNode.from(chainID: dappInfo.chainId),
                message:
                    message,
                onAccept: { _ in
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
            } catch {
                print("🔥 Unexpected error: \(error).")
            }
        }
    }
}
