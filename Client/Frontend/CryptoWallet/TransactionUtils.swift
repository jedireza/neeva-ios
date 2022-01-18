// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import CryptoSwift
import Defaults
import Foundation
import PromiseKit
import WalletConnectSwift
import secp256k1
import web3swift

struct WalletAccessor {
    let keystore: EthereumKeystoreV3?
    let password: String
    let web3: web3

    init() {
        self.web3 = try! Web3.new(CryptoConfig.shared.nodeURL)
        self.password = CryptoConfig.shared.getPassword()
        let key = Defaults[.cryptoPrivateKey]
        let formattedKey = key.trimmingCharacters(in: .whitespacesAndNewlines)
        let dataKey = Data.fromHex(formattedKey)!
        self.keystore = try? EthereumKeystoreV3(privateKey: dataKey, password: password)
        if let keystore = keystore {
            self.web3.addKeystoreManager(KeystoreManager([keystore]))
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
        DispatchQueue.global(qos: .userInitiated).async {
            web3.eth.getBalancePromise(address: publicAddress).done(on: DispatchQueue.main) {
                balance in
                completion(Web3.Utils.formatToEthereumUnits(balance, toUnits: .eth))
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
