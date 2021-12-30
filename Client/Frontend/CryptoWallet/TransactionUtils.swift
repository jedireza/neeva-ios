// Copyright Neeva. All rights reserved.

import CryptoSwift
import Defaults
import Foundation
import WalletConnectSwift
import secp256k1
import web3swift

struct WalletAccessor: AddressAccessor {
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
        let password = CryptoConfig.shared.getPassword()
        let key = Defaults[.cryptoPrivateKey]
        let formattedKey = key.trimmingCharacters(in: .whitespacesAndNewlines)
        let dataKey = Data.fromHex(formattedKey)!
        let keystore = try! EthereumKeystoreV3(privateKey: dataKey, password: password)!
        return keystore.addresses!.first!.address
    }
}

protocol AddressAccessor {
    var privateKey: [UInt8] { get }
    var publicAddress: String { get }
}

enum WalletError: Error {
    case internalError
}

public func sign(message: String, using publicAddress: String) throws -> String {
    let web3 = try Web3.new(URL(string: CryptoConfig.shared.getNodeURL())!)
    let password = CryptoConfig.shared.getPassword()
    let key = Defaults[.cryptoPrivateKey]
    let formattedKey = key.trimmingCharacters(in: .whitespacesAndNewlines)
    let dataKey = Data.fromHex(formattedKey)!
    let keystore = try! EthereumKeystoreV3(privateKey: dataKey, password: password)!
    web3.addKeystoreManager(KeystoreManager([keystore]))
    return try "0x"
        + web3.wallet.signPersonalMessage(
            message, account: EthereumAddress(publicAddress)!, password: password
        ).toHexString()
}
