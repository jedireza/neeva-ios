// Copyright Neeva. All rights reserved.

import Defaults
import SwiftUI
import web3swift

struct WelcomeStarterView: View {
    @State var isCreatingWallet: Bool = false
    @Binding var viewState: ViewState

    var body: some View {
        VStack {
            VStack {
                Text("Welcome to Neeva")
                Text("Crypto Wallet")
            }
            .font(.roobert(size: 28))
            .padding(.top, 10)
            .padding(.bottom, 20)

            VStack {
                Text("Let's get set up!")
                    .font(.roobert(size: 22))
                    .frame(width: 300, height: 50, alignment: .leading)
                Button(action: {
                    isCreatingWallet = true
                    createWallet()
                }) {
                    Text(isCreatingWallet ? "Creating ... " : "Create a wallet")
                        .font(.roobert(.semibold, size: 18))
                }
                .frame(minWidth: 300, minHeight: 50)
                .foregroundColor(Color.brand.white)
                .background(Color.brand.blue)
                .cornerRadius(15)
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 10).stroke(Color.ui.gray91, lineWidth: 0.5)
            )
            .background(Color.white.opacity(0.8))
            .padding(.bottom, 15)

            VStack {
                VStack(alignment: .leading) {
                    Text("I already have a Secret")
                    Text("Recovery Phrase")
                }
                .font(.roobert(size: 22))
                .frame(width: 300, height: 60, alignment: .leading)

                Text("If you are not sure what is a Secret Recovery Phrase, click Create a wallet on the top")
                    .font(.system(size: 14))
                    .multilineTextAlignment(.leading)
                    .foregroundColor(.secondary)

                Button(action: { viewState = .importWallet }) {
                    Text("Import wallet")
                        .font(.roobert(.semibold, size: 18))
                }
                .frame(minWidth: 300, minHeight: 50)
                .foregroundColor(Color.brand.white)
                .background(Color.brand.blue)
                .cornerRadius(15)
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 10).stroke(Color.ui.gray91, lineWidth: 0.5)
            )
            .background(Color.white.opacity(0.8))
        }
    }

    func createWallet() {
        if let _ = URL(string: CryptoConfig.shared.getNodeURL()) {
            do {
                let password = CryptoConfig.shared.getPassword()
                let bitsOfEntropy: Int = 128
                let mnemonics = try! BIP39.generateMnemonics(bitsOfEntropy: bitsOfEntropy)!

                Defaults[.cryptoPhrases] = mnemonics

                let keystore = try! BIP32Keystore(
                    mnemonics: mnemonics,
                    password: password,
                    mnemonicsPassword: "",
                    language: .english)!
                let name = CryptoConfig.shared.getWalletName()
                let keyData = try! JSONEncoder().encode(keystore.keystoreParams)

                let address = keystore.addresses!.first!.address
                let wallet = Wallet(address: address, data: keyData, name: name, isHD: true)

                let privateKey = try keystore.UNSAFE_getPrivateKeyData(password: password, account: EthereumAddress(address)!).toHexString()
                Defaults[.cryptoPrivateKey] = privateKey

                Defaults[.cryptoPublicKey] = wallet.address
                isCreatingWallet = false
                viewState = .showPhrases
            } catch {
                print("🔥 Unexpected error: \(error).")
            }
        }
    }
}
