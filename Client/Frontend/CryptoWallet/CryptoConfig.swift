// Copyright Neeva. All rights reserved.

import Defaults
import Foundation
import Shared
import web3swift

enum EthNode: String {
    // real eth network
    case mainnet = "https://mainnet.infura.io/v3/83f94ab9ec72404096d4fa53182c7e80"

    // testing network
    case ropsten = "https://ropsten.infura.io/v3/83f94ab9ec72404096d4fa53182c7e80"
}

public class CryptoConfig {
    private let currentNode: EthNode

    public static let shared = CryptoConfig()

    public init() {
        // modify currentNode to switch between
        // real and testing eth network
        self.currentNode = .ropsten
    }

    public func getNodeURL() -> String {
        return self.currentNode.rawValue
    }

    public func isOnTestingNetwork() -> Bool {
        return self.currentNode == .ropsten
    }

    public func etherToUSD(ether: String) -> String {
        let conversionRate = 4062.97
        if let ethAmount = Double(ether) {
            return String(ethAmount * conversionRate)
        }
        return "N/A"
    }
}


