// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import BigInt
import CryptoSwift
import Defaults
import Foundation
import PromiseKit
import SwiftUI
import WalletConnectSwift
import secp256k1
import web3swift

struct WalletAccessor {
    let keystore: EthereumKeystoreV3?
    let password: String
    let web3: web3
    let polygonWeb3: web3

    func web3(on chain: EthNode) -> web3 {
        switch chain {
        case .Polygon:
            return polygonWeb3
        default:
            return web3
        }
    }

    init() {
        self.web3 = try! Web3.new(CryptoConfig.shared.nodeURL)
        self.polygonWeb3 = try! Web3.new(EthNode.Polygon.url)
        self.password = CryptoConfig.shared.password
        let key = Defaults[.cryptoPrivateKey]
        let formattedKey = key.trimmingCharacters(in: .whitespacesAndNewlines)
        let dataKey = Data.fromHex(formattedKey)!
        self.keystore = try? EthereumKeystoreV3(privateKey: dataKey, password: password)
        if let keystore = keystore {
            self.web3.addKeystoreManager(KeystoreManager([keystore]))
            self.polygonWeb3.addKeystoreManager(KeystoreManager([keystore]))
        }
    }

    var privateKey: [UInt8] {
        let key = Defaults[.cryptoPrivateKey]
        let formattedKey = key.trimmingCharacters(in: .whitespacesAndNewlines)
        return formattedKey.bytes
    }

    var walletMeta: Session.ClientMeta {
        return Session.ClientMeta(
            name: "Neeva Wallet",
            description: "Neeva is the world's first ad-free private search engine",
            icons: [URL(string: "https://neeva.com/apple-touch-icon-180.png")!],
            url: URL(string: "https://neeva.com")!)
    }

    var publicAddress: String {
        return keystore?.addresses?.first?.address ?? ""
    }

    func sign(message: String, using publicAddress: String) throws -> String {
        return try "0x"
            + web3.wallet.signPersonalMessage(
                message, account: EthereumAddress(publicAddress)!, password: password
            ).toHexString()
    }

    func ethBalance(completion: @escaping (String?) -> Void) {
        balance(on: .Ethereum, completion: completion)
    }

    func balance(on chain: EthNode, completion: @escaping (String?) -> Void) {
        guard let _ = EthereumAddress(publicAddress) else {
            return
        }

        DispatchQueue.global(qos: .userInitiated).async {
            web3(on: chain).eth.getBalancePromise(address: publicAddress).done(
                on: DispatchQueue.main
            ) {
                balance in
                completion(Web3.Utils.formatToEthereumUnits(balance, toUnits: .eth))
            }.cauterize()
        }
    }

    func tokenBalance(token: TokenType, completion: @escaping (String?) -> Void) {
        guard let walletAddress = EthereumAddress(publicAddress), !token.contractAddress.isEmpty
        else {
            balance(on: token.network, completion: completion)
            return
        }

        DispatchQueue.global(qos: .userInitiated).async {
            let erc20ContractAddress = EthereumAddress(token.contractAddress)!
            let contract = web3(on: token.network).contract(
                Web3.Utils.erc20ABI, at: erc20ContractAddress, abiVersion: 2)!
            var options = TransactionOptions.defaultOptions
            options.from = walletAddress
            options.gasPrice = .automatic
            options.gasLimit = .automatic
            let method = "balanceOf"
            let tx = contract.read(
                method,
                parameters: [walletAddress] as [AnyObject],
                extraData: Data(),
                transactionOptions: options)!
            tx.callPromise().done { tokenBalance in
                let balanceBigUInt = tokenBalance["0"] as! BigUInt
                completion(
                    Web3.Utils.formatToEthereumUnits(balanceBigUInt, toUnits: .eth, decimals: 6))
            }.cauterize()
        }
    }

    func gasPrice(completion: @escaping (String?) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            web3.eth.getGasPricePromise().done(on: DispatchQueue.main) { estimate in
                completion(Web3.Utils.formatToEthereumUnits(estimate, toUnits: .Gwei))
            }.cauterize()
        }
    }

    func send(
        eth value: String, from fromAddress: EthereumAddress, to toAddress: EthereumAddress,
        for gas: String?, using data: String?
    ) throws -> String {
        let contract = web3.contract(
            Web3.Utils.coldWalletABI, at: toAddress, abiVersion: 2)!

        var options = TransactionOptions.defaultOptions
        options.value = Web3.Utils.hexToBigUInt(value)
        options.from = fromAddress
        options.gasPrice = .automatic
        options.gasLimit = gas != nil ? .manual(Web3.Utils.hexToBigUInt(gas!)!) : .automatic
        let tx = contract.write(
            "fallback",
            parameters: [AnyObject](),
            extraData: data != nil ? Web3.Utils.hexToData(data!) ?? Data() : Data(),
            transactionOptions: options)!

        return try tx.send(password: password).transaction.txhash ?? ""
    }
}

public enum TokenType: String, CaseIterable {
    case ether = "Ether"
    case wrappedEther = "Wrapped Ether"
    case wrappedEtherOnPolygon = "Wrapped Ether on Polygon"
    case maticOnPolygon = "Matic on Polygon"

    var network: EthNode {
        switch self {
        case .ether:
            return .Ethereum
        case .wrappedEther:
            return .Ethereum
        case .wrappedEtherOnPolygon:
            return .Polygon
        case .maticOnPolygon:
            return .Polygon
        }
    }

    // TODO Internationalize this
    var conversionRateToUSD: Double {
        return 3164.09
    }

    var contractAddress: String {
        switch self {
        case .ether:
            return ""
        case .wrappedEther:
            return "0xc02aaa39b223fe8d0a0e5c4f27ead9083c756cc2"
        case .wrappedEtherOnPolygon:
            return "0x7ceb23fd6bc0add59e62ac25578270cff1b9f619"
        case .maticOnPolygon:
            return ""
        }
    }

    var currency: String {
        switch self {
        case .ether:
            return "ETH"
        case .wrappedEther:
            return "WETH"
        case .wrappedEtherOnPolygon:
            return "WETH"
        case .maticOnPolygon:
            return "MATIC"
        }
    }

    var ethLogo: some View {
        Image("ethLogo")
            .resizable()
            .scaledToFit()
            .frame(width: 24, height: 24)
            .padding(4)
    }

    var maticLogo: some View {
        Image("polygon-badge")
            .resizable()
            .scaledToFit()
            .frame(width: 24, height: 24)
            .padding(4)
    }

    // TODO make this only an image resource
    @ViewBuilder var thumbnail: some View {
        switch self {
        case .ether:
            ethLogo
        case .wrappedEther:
            ethLogo
                .background(Circle().stroke(Color.ui.gray80))
        case .wrappedEtherOnPolygon:
            if #available(iOS 15.0, *) {
                ethLogo
                    .background(Circle().stroke(Color.ui.gray80))
                    .overlay {
                        Image("polygon-badge")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 14, height: 14)
                            .offset(x: -12, y: 12)
                    }
            } else {
                ethLogo
                    .background(Circle().stroke(Color.ui.gray80))
            }
        case .maticOnPolygon:
            maticLogo
        }
    }
}
