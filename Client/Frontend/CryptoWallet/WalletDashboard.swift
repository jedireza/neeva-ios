// Copyright Neeva. All rights reserved.

import Defaults
import MobileCoreServices
import SwiftUI
import web3swift

struct WalletDashboard: View {
    @State var copyButtonText: String = "Copy"
    @State var accountBalance: String = ""

    var body: some View {
        VStack(spacing: 8) {
            Image("ethLogo")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 40, height: 40)
                .padding(4)
                .background(
                    Circle().stroke(Color.ui.gray80)
                )
            Text("\(accountBalance) ETH")
                .font(.roobert(size: 32))

            Text("$\(CryptoConfig.shared.etherToUSD(ether: accountBalance)) USD")
                .font(.system(size: 18))
                .foregroundColor(.secondary)

            Button(action: getData) {
                Text("Refresh")
                    .font(.system(size: 14))
            }
            .frame(minWidth: 70, minHeight: 30, alignment: .center)
            .foregroundColor(Color.brand.white)
            .background(Color(hex: 0xA6C294))
            .cornerRadius(35)

            VStack {
                Text("Account")
                HStack {
                    ScrollView(.horizontal) {
                        Text("\(Defaults[.cryptoPublicKey])")
                    }
                    Button(action: {
                        copyButtonText = "Copied!"
                        UIPasteboard.general.setValue(Defaults[.cryptoPublicKey], forPasteboardType: kUTTypePlainText as String)
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                            copyButtonText = "Copy"
                        }
                    }) {
                        Text("\(copyButtonText)")
                    }
                    .padding(12)
                    .foregroundColor(Color.brand.white)
                    .background(Color.brand.charcoal)
                    .cornerRadius(10)
                }
                .padding(10)
                .background(
                    RoundedRectangle(cornerRadius: 10).stroke(Color.ui.gray91, lineWidth: 0.5)
                )
                .background(Color.white.opacity(0.8))
            }

        }
        .padding(.top, 10)
        .padding(.vertical, 25)
        .onAppear(perform: getData)
    }

    func getData() {
        if let url = URL(string: CryptoConfig.shared.getNodeURL()) {
            do {
                print("🍎 connecting")
                let web3 = try Web3.new(url)

                let testAccountAddress = EthereumAddress("\(Defaults[.cryptoPublicKey])")!
                print("🍎 public address: \(Defaults[.cryptoPublicKey])")
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
