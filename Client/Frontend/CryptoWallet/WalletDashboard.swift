// Copyright Neeva. All rights reserved.

import Defaults
import SwiftUI
import web3swift

struct WalletDashboard: View {
    @State var accountBalance: String = ""

    var body: some View {
        VStack(spacing: 8) {
            Text("Welcome to Neeva Crypto Wallet")
            Text("Your current balance")
            Text("\(accountBalance)")
        }
        .padding(.top, 10)
    }

    func getData() {
        print("🍎 page loaded")
        // enter your own nodeURL
        //let nodeURL = "https://mainnet.infura.io/v3/83f94ab9ec72404096d4fa53182c7e80"

        // testing network
        let nodeURL = "https://ropsten.infura.io/v3/83f94ab9ec72404096d4fa53182c7e80"
        
        if let url = URL(string: nodeURL) {
            do {
                print("🍎 connecting")
                let web3 = try Web3.new(url)

                let password = "NeevaCrypto"
                let bitsOfEntropy: Int = 128
                let mnemonics = try! BIP39.generateMnemonics(bitsOfEntropy: bitsOfEntropy)!
                Defaults[.cryptoPhrases] = mnemonics
                print("🍎 mnemonics: \(mnemonics)")

                let keystore = try! BIP32Keystore(
                    mnemonics: mnemonics,
                    password: password,
                    mnemonicsPassword: "",
                    language: .english)!
                let name = "My Neeva Crypto Wallet"
                let keyData = try! JSONEncoder().encode(keystore.keystoreParams)
                let address = keystore.addresses!.first!.address
                print("🍎 first wallet: \(address)")
                let wallet = Wallet(address: address, data: keyData, name: name, isHD: true)

                Defaults[.cryptoPublicKey] = wallet.address

                print("🍎 wallet.address: \(wallet.address)")
                print("🍎 wallet.name: \(wallet.name)")


                let testAccountAddress = EthereumAddress("0xBE0eB53F46cd790Cd13851d5EFf43D12404d33E8")!
                let balance = try web3.eth.getBalancePromise(address: testAccountAddress).wait()

                print("🍎 balance(wei): \(balance)")

                if let convertedBalance = Web3.Utils.formatToEthereumUnits(balance, decimals: 3) {
                    accountBalance = convertedBalance
                    print("🍎 converted balance(ether): \(convertedBalance)")
                }
            } catch {
                print("Unexpected error: \(error).")
            }
        }
    }
}

struct WalletDashboard_Previews: PreviewProvider {
    static var previews: some View {
        WalletDashboard()
    }
}
