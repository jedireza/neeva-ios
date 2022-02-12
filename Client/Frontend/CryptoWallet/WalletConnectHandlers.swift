// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import BigInt
import CryptoSwift
import Defaults
import Foundation
import SDWebImageSwiftUI
import Shared
import SwiftUI
import WalletConnectSwift
import web3swift

protocol ResponseRelay {
    var publicAddress: String { get }
    func send(_ response: Response)
    func askToSign(request: Request, message: String, sign: @escaping (EthNode) -> String)
    func askToTransact(
        request: Request,
        options: TransactionOptions,
        transaction: EthereumTransaction,
        transact: @escaping (EthNode) -> String
    )
    func send(
        on chain: EthNode,
        transactionData: TransactionData
    ) throws -> String
    func sign(on chain: EthNode, message: String, using publicAddress: String) throws -> String
}

extension Response {
    static func signature(_ signature: String, for request: Request) -> Response {
        return try! Response(url: request.url, value: signature, id: request.id!)
    }

    static func transaction(_ transaction: String, for request: Request) -> Response {
        return try! Response(url: request.url, value: transaction, id: request.id!)
    }
}

class PersonalSignHandler: RequestHandler {
    let relay: ResponseRelay

    init(relay: ResponseRelay) {
        self.relay = relay
    }

    func canHandle(request: Request) -> Bool {
        return request.method == "personal_sign"
    }

    func handle(request: Request) {
        do {
            let messageBytes = try request.parameter(of: String.self, at: 0)
            let address = try request.parameter(of: String.self, at: 1)

            // Match only the address not the checksum (OpenSea sends them always lowercased :( )
            guard address.lowercased() == relay.publicAddress.lowercased() else {
                relay.send(.reject(request))
                return
            }

            let message = String(data: Data.fromHex(messageBytes) ?? Data(), encoding: .utf8) ?? ""

            relay.askToSign(request: request, message: message) { ethNode in
                return
                    (try? self.relay.sign(
                        on: ethNode, message: messageBytes, using: self.relay.publicAddress))
                    ?? ""
            }
        } catch {
            relay.send(.invalid(request))
            return
        }
    }
}

class SendTransactionHandler: RequestHandler {
    let relay: ResponseRelay

    init(relay: ResponseRelay) {
        self.relay = relay
    }

    func canHandle(request: Request) -> Bool {
        return request.method == "eth_sendTransaction"
    }

    func handle(request: Request) {
        guard let requestData = request.jsonString.data(using: .utf8),
            let transactionRequest = try? JSONDecoder().decode(
                TransactionRequest.self, from: requestData),
            let transactionData = transactionRequest.params.first,
            let transaction = transactionData.ethereumTransaction,
            let _ = EthereumAddress(transactionData.from)
        else {
            relay.send(.invalid(request))
            return
        }

        relay.askToTransact(
            request: request,
            options: transactionData.transactionOptions,
            transaction: transaction
        ) { ethNode in
            return
                (try? self.relay.send(
                    on: ethNode,
                    transactionData: transactionData
                )) ?? ""
        }
    }
}

public struct TransactionRequest: Codable {
    let params: [TransactionData]
}

public struct TransactionData: Codable {
    let from: String
    let to: String
    let value: String?
    let data: String?
    let gas: String?

    var ethereumTransaction: EthereumTransaction? {
        guard let toAddress = EthereumAddress(to) else { return nil }
        return EthereumTransaction(
            gasPrice: .zero,
            gasLimit: convertedGasPrice,
            to: toAddress,
            value: convertedValue,
            data: convertedData
        )
    }

    var convertedData: Data {
        data != nil ? Web3.Utils.hexToData(data!) ?? Data() : Data()
    }

    var convertedValue: BigUInt {
        Web3.Utils.hexToBigUInt(value ?? "0x0") ?? .zero
    }

    var convertedGasPrice: BigUInt {
        gas != nil ? Web3.Utils.hexToBigUInt(gas!) ?? .zero : .zero
    }

    var fromAddress: EthereumAddress {
        EthereumAddress(from)!
    }

    var toAddress: EthereumAddress {
        EthereumAddress(to)!
    }

    var transactionOptions: TransactionOptions {
        var options = TransactionOptions.defaultOptions
        options.value = convertedValue
        options.from = fromAddress
        options.gasPrice = .automatic
        options.gasLimit = gas != nil ? .manual(convertedGasPrice) : .automatic
        return options
    }

}
