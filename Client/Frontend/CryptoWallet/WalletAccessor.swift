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

    func sign(on chain: EthNode, message: String, using publicAddress: String) throws -> String {
        return try "0x"
            + web3(on: chain).wallet.signPersonalMessage(
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
                    Web3.Utils.formatToEthereumUnits(
                        balanceBigUInt,
                        toUnits: token.currency == .USDC ? .Mwei : .eth,
                        decimals: 6
                    )
                )
            }.cauterize()
        }
    }

    func gasPrice(on chain: EthNode, completion: @escaping (BigUInt?) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            web3(on: chain).eth.getGasPricePromise().done(on: DispatchQueue.main) { estimate in
                completion(estimate)
            }.cauterize()
        }
    }

    func estimateGasForTransaction(
        on chain: EthNode,
        options: TransactionOptions,
        transaction: EthereumTransaction,
        completion: @escaping (BigUInt, BigUInt?) -> Void
    ) {
        DispatchQueue.global(qos: .userInitiated).async {
            let gasPrice: BigUInt =
                (try? web3(on: chain).eth.getGasPrice()) ?? transaction.gasPrice
            var tx = transaction
            tx.gasPrice = gasPrice
            var opts = options
            opts.gasPrice = .manual(gasPrice)

            web3(on: chain).eth.estimateGasPromise(tx, transactionOptions: opts)
                .done(on: DispatchQueue.main) { estimate in
                    completion(gasPrice, estimate)
                }.cauterize()
        }
    }

    func send(on chain: EthNode, transactionData: TransactionData) throws -> String {
        let contract = web3(on: chain).contract(
            Web3.Utils.coldWalletABI, at: transactionData.toAddress, abiVersion: 2)!

        let tx = contract.write(
            "fallback",
            parameters: [AnyObject](),
            extraData: transactionData.convertedData,
            transactionOptions: transactionData.transactionOptions)!

        return try tx.send(password: password).transaction.txhash ?? ""
    }
}
