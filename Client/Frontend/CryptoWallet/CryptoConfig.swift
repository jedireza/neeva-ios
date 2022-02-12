// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Defaults
import Foundation
import Shared
import web3swift

private let log = Logger.browser

public struct HDKey {
    let name: String?
    let address: String
}

public enum EthNode: String, CaseIterable, Identifiable {
    // real eth network
    case Ethereum
    // testing network
    case Ropsten
    // polygon network
    case Polygon

    public var id: Int {
        switch self {
        case .Ethereum:
            return 1
        case .Ropsten:
            return 3
        case .Polygon:
            return 137
        }
    }

    static func from(chainID: Int?) -> EthNode {
        return allCases.first(where: { $0.id == chainID }) ?? .Ethereum
    }

    var url: URL {
        switch self {
        case .Ethereum:
            return "https://mainnet.infura.io/v3/25b0f8c5b9004da38236104927e630b5"
        case .Ropsten:
            return "https://ropsten.infura.io/v3/25b0f8c5b9004da38236104927e630b5"
        case .Polygon:
            return "https://polygon-mainnet.infura.io/v3/25b0f8c5b9004da38236104927e630b5"
        }
    }

    var currency: TokenType {
        switch self {
        case .Ethereum:
            return .ether
        case .Ropsten:
            return .ether
        case .Polygon:
            return .maticOnPolygon
        }
    }
}

public class CryptoConfig {
    public let currentNode: EthNode

    public static let shared = CryptoConfig()

    public init() {
        // modify currentNode to switch between
        // real and testing eth network
        self.currentNode = .Ethereum
    }

    public var nodeURL: URL {
        self.currentNode.url
    }

    public var isOnTestingNetwork: Bool {
        self.currentNode == .Ropsten
    }

    public var password: String {
        return "NeevaCrypto"
    }

    public var walletName: String {
        return "My Neeva Crypto Wallet"
    }

    public func sendEth(amount: String, sendToAccountAddress: String, completion: () -> Void) {
        do {
            let web3 = try Web3.new(nodeURL)
            let password = CryptoConfig.shared.password
            let key = Defaults[.cryptoPrivateKey]
            let formattedKey = key.trimmingCharacters(in: .whitespacesAndNewlines)
            let dataKey = Data.fromHex(formattedKey)!
            let keystore = try! EthereumKeystoreV3(privateKey: dataKey, password: password)!
            let name = CryptoConfig.shared.walletName
            let keyData = try! JSONEncoder().encode(keystore.keystoreParams)
            let address = keystore.addresses!.first!.address
            let wallet = Wallet(address: address, data: keyData, name: name, isHD: false)

            let data = wallet.data
            let keystoreManager: KeystoreManager
            if wallet.isHD {
                let keystore = BIP32Keystore(data)!
                keystoreManager = KeystoreManager([keystore])
            } else {
                let keystore = EthereumKeystoreV3(data)!
                keystoreManager = KeystoreManager([keystore])
            }

            web3.addKeystoreManager(keystoreManager)

            let value: String = amount
            let walletAddress = EthereumAddress(wallet.address)!

            let toAddress = EthereumAddress(sendToAccountAddress)!
            let contract = web3.contract(
                Web3.Utils.coldWalletABI, at: toAddress, abiVersion: 2)!
            let convertedAmount = Web3.Utils.parseToBigUInt(value, units: .eth)

            var options = TransactionOptions.defaultOptions
            options.value = convertedAmount
            options.from = walletAddress
            options.gasPrice = .automatic
            options.gasLimit = .automatic
            let tx = contract.write(
                "fallback",
                parameters: [AnyObject](),
                extraData: Data(),
                transactionOptions: options)!

            let sendResult = try tx.send(password: password)
            if let transactionHash = sendResult.transaction.txhash {
                Defaults[.cryptoTransactionHashStore].insert(transactionHash)
            }
            completion()
        } catch {
            log.error("Unexpected send eth error: \(error).")
        }
    }

    public struct AccountInfo {
        let balance: String
        let transactions: [TransactionDetail]
    }

    public func getData() -> AccountInfo {
        var transactionHistory: [TransactionDetail] = []
        var accountBalance = "0"
        do {
            let web3 = try Web3.new(nodeURL)
            let myAccountAddress = EthereumAddress("\(Defaults[.cryptoPublicKey])")!
            let balance = try web3.eth.getBalancePromise(address: myAccountAddress).wait()

            if let convertedBalance = Web3.Utils.formatToEthereumUnits(balance, decimals: 3) {
                accountBalance = convertedBalance
            }

            // print transaction history if available
            if Defaults[.cryptoTransactionHashStore].count > 0 {
                for hashStr in Defaults[.cryptoTransactionHashStore] {
                    let details = try web3.eth.getTransactionDetailsPromise(hashStr).wait()
                    let transactionValue = details.transaction.value
                    if let transactionInEther = Web3.Utils.formatToEthereumUnits(
                        transactionValue!, decimals: 3)
                    {
                        let toAddress = details.transaction.to.address
                        if toAddress == Defaults[.cryptoPublicKey] {
                            transactionHistory.append(
                                TransactionDetail(
                                    transactionAction: .Receive,
                                    amountInEther: transactionInEther,
                                    oppositeAddress: details.transaction.sender?.address ?? ""))
                        } else if let senderAddress = details.transaction.sender?.address {
                            if senderAddress == Defaults[.cryptoPublicKey] {
                                transactionHistory.append(
                                    TransactionDetail(
                                        transactionAction: .Send,
                                        amountInEther: transactionInEther,
                                        oppositeAddress: toAddress))
                            }
                        }

                    }
                }
            }
        } catch {
            log.error("Unexpected get wallet data error: \(error).")
        }
        return AccountInfo(balance: accountBalance, transactions: transactionHistory)
    }
}
