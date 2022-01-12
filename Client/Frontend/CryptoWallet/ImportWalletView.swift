// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Defaults
import Shared
import SwiftUI
import web3swift

struct ImportWalletView: View {
    @State var inputPhrase: String = ""
    @Binding var viewState: ViewState
    @State var isImporting: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Import Your Wallet")
                .font(.roobert(size: 28))

            Text("Enter your secret recovery phrase below then click Import")
                .font(.system(size: 16))
                .multilineTextAlignment(.leading)
                .foregroundColor(.secondary)

            TextEditor(text: $inputPhrase)
                .foregroundColor(Color.ui.gray20)
                .font(.system(size: 26))
                .border(Color.brand.charcoal, width: 1)

            HStack {
                Spacer()
                Button(action: { viewState = .starter }) {
                    Text("Back")
                        .font(.roobert(.semibold, size: 18))
                        .frame(maxWidth: 120)
                }
                .buttonStyle(.neeva(.secondary))
                .padding(.top, 8)

                Button(action: importWallet) {
                    Text(isImporting ? "Importing... " : "Import")
                        .font(.roobert(.semibold, size: 18))
                        .frame(width: 200)
                }
                .buttonStyle(.neeva(.primary))
                .padding(.top, 8)
                .disabled(inputPhrase.isEmpty)
            }
        }
        .padding(25)
    }

    func importWallet() {
        do {
            isImporting = true
            let password = CryptoConfig.shared.getPassword()
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
            isImporting = false
            viewState = .dashboard
        } catch {
            print("🔥 Unexpected error: \(error).")
        }
    }
}
