// Copyright Neeva. All rights reserved.

import SwiftUI
import web3swift

struct CryptoWalletView: View {
    @State var accountBalance: String = ""

    var onDismiss: () -> Void

    var body: some View {
        ScrollView(.vertical) {
            VStack {
                HStack {
                    Spacer()
                    Button(action: onDismiss) {
                        Text("Close")
                            .frame(minWidth: 50, minHeight: 30)
                    }
                    .background(Color.ui.gray91)
                    .cornerRadius(10)
                }

                VStack(spacing: 8) {
                    Text("Welcome to Neeva Crypto Wallet")
                    Text("Your current balance")
                    Text("\(accountBalance)")
                }
                .padding(.top, 10)
            }
        }
        .padding(50)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.brand.offwhite)
        .ignoresSafeArea(.all)
        .onAppear(perform: getData)
    }

    func getData() {
        print("🍎 page loaded")
        // enter your own nodeURL
        let nodeURL = "https://mainnet.infura.io/v3/83f94ab9ec72404096d4fa53182c7e80"
        if let url = URL(string: nodeURL) {
            do {
                print("🍎 connecting")
                let web3 = try Web3.new(url)
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
