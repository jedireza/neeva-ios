// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

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
    func askToTransact(request: Request, value: String, transact: @escaping (EthNode) -> String)
    func send(
        on chain: EthNode,
        eth value: String, from fromAddress: EthereumAddress, to toAddress: EthereumAddress,
        for gas: String?, using data: String?
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
            let requestDict = try? JSONSerialization.jsonObject(with: requestData, options: [])
                as? [String: Any],
            let params = (requestDict["params"] as? [[String: String]])?[0],
            let from = params["from"],
            from.lowercased() == relay.publicAddress.lowercased(),
            let fromAddress = EthereumAddress(from),
            let to = params["to"],
            let toAddress = EthereumAddress(to)
        else {
            relay.send(.invalid(request))
            return
        }
        let value = params["value"] ?? "0x0"
        let data = params["data"]
        let gas = params["gas"]

        relay.askToTransact(request: request, value: value) { ethNode in
            return
                (try? self.relay.send(
                    on: ethNode,
                    eth: value, from: fromAddress, to: toAddress, for: gas, using: data)) ?? ""
        }
    }
}
