// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Defaults
import Foundation
import web3swift

public struct OnboardingModel {

    public init() {}

    public func createWallet(completion: @escaping () -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                let password = CryptoConfig.shared.password
                let bitsOfEntropy: Int = 128
                let mnemonics = try! BIP39.generateMnemonics(bitsOfEntropy: bitsOfEntropy)!

                Defaults[.cryptoPhrases] = mnemonics

                let keystore = try! BIP32Keystore(
                    mnemonics: mnemonics,
                    password: password,
                    mnemonicsPassword: "",
                    language: .english)!
                let name = CryptoConfig.shared.walletName
                let keyData = try! JSONEncoder().encode(keystore.keystoreParams)

                let address = keystore.addresses!.first!.address
                let wallet = Wallet(address: address, data: keyData, name: name, isHD: true)

                let privateKey = try keystore.UNSAFE_getPrivateKeyData(
                    password: password, account: EthereumAddress(address)!
                ).toHexString()
                Defaults[.cryptoPrivateKey] = privateKey

                Defaults[.cryptoPublicKey] = wallet.address
                completion()
            } catch {
                print("🔥 Unexpected error: \(error).")
            }
        }
    }

    public func importWallet(inputPhrase: String, completion: @escaping () -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                let password = CryptoConfig.shared.password
                let mnemonics = inputPhrase
                let keystore = try! BIP32Keystore(
                    mnemonics: mnemonics,
                    password: password,
                    mnemonicsPassword: "",
                    language: .english)!
                let address = keystore.addresses!.first!.address
                Defaults[.cryptoPhrases] = mnemonics
                Defaults[.cryptoPublicKey] = address
                let privateKey = try keystore.UNSAFE_getPrivateKeyData(
                    password: password, account: EthereumAddress(address)!
                ).toHexString()
                Defaults[.cryptoPrivateKey] = privateKey
                completion()
            } catch {
                print("🔥 Unexpected error: \(error).")
            }
        }
    }
}
