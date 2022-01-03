// Copyright Neeva. All rights reserved.

import CryptoSwift
import Defaults
import Foundation
import WalletConnectSwift
import secp256k1
import web3swift

struct WalletAccessor {
    let keystore: EthereumKeystoreV3
    let password: String
    let web3: web3

    init() {
        self.web3 = try! Web3.new(URL(string: CryptoConfig.shared.getNodeURL())!)
        self.password = CryptoConfig.shared.getPassword()
        let key = Defaults[.cryptoPrivateKey]
        let formattedKey = key.trimmingCharacters(in: .whitespacesAndNewlines)
        let dataKey = Data.fromHex(formattedKey)!
        self.keystore = try! EthereumKeystoreV3(privateKey: dataKey, password: password)!
        self.web3.addKeystoreManager(KeystoreManager([keystore]))
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
        return keystore.addresses!.first!.address
    }

    func sign(message: String, using publicAddress: String) throws -> String {
        return try "0x"
            + web3.wallet.signPersonalMessage(
                message, account: EthereumAddress(publicAddress)!, password: password
            ).toHexString()
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
