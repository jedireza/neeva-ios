// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import BigInt
import Foundation
import web3swift

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
