// Copyright Neeva. All rights reserved.

import Defaults
import SwiftUI
import web3swift

struct SendForm: View {
    @State var sendToAccountAddress = ""
    @State var amount: String = ""
    @Binding var showSendForm: Bool

    var body: some View {
        VStack(alignment: .leading) {
            Text("Send To")
                .font(.roobert(size: 14))
            TextField("Recipient Address", text: $sendToAccountAddress)
                .padding()
                .overlay(
                    RoundedRectangle(cornerRadius: 12.0)
                        .stroke(Color(UIColor.systemGray5), style: StrokeStyle(lineWidth: 1.0))
                )
                .disableAutocorrection(true)
                .autocapitalization(.none)
                .fixedSize(horizontal: false, vertical: true)
                .background(Color.brand.white.opacity(0.8))
                .cornerRadius(12)

            if !sendToAccountAddress.isEmpty {
                Text("Send to address: \(sendToAccountAddress)")
                    .fixedSize(horizontal: false, vertical: true)
                    .multilineTextAlignment(.leading)
                    .font(.system(size: 13))
                    .foregroundColor(.secondary)
            }

            TextField("Amount (ETH)", text: $amount)
                .padding()
                .overlay(
                    RoundedRectangle(cornerRadius: 12.0)
                        .stroke(Color(UIColor.systemGray5), style: StrokeStyle(lineWidth: 1.0))
                )
                .disableAutocorrection(true)
                .autocapitalization(.none)
                .fixedSize(horizontal: false, vertical: true)
                .background(Color.brand.white.opacity(0.8))
                .cornerRadius(12)
                .keyboardType(.decimalPad)

            if !amount.isEmpty {
                Text("= \(CryptoConfig.shared.etherToUSD(ether: amount)) USD")
            }

            HStack {
                Spacer()
                Button(action: { showSendForm = false }) {
                    Text("Cancel")
                        .font(.roobert(.semibold, size: 18))
                }
                .frame(maxWidth: 120, minHeight: 40)
                .foregroundColor(Color.brand.blue)
                .background(Color.ui.gray91)
                .cornerRadius(10)
                .padding(.top, 8)

                Button(action: sendEth) {
                    Text("Send")
                        .font(.roobert(.semibold, size: 18))
                }
                .frame(maxWidth: 120, minHeight: 40)
                .foregroundColor(Color.brand.white)
                .background(Color.brand.blue)
                .cornerRadius(10)
                .padding(.top, 8)
                .disabled(amount.isEmpty && sendToAccountAddress.isEmpty)
            }
        }
    }

    func sendEth() {
        if let url = URL(string: CryptoConfig.shared.getNodeURL()) {
            do {
                let web3 = try Web3.new(url)
                let password = CryptoConfig.shared.getPassword()
                let key = Defaults[.cryptoPrivateKey]
                let formattedKey = key.trimmingCharacters(in: .whitespacesAndNewlines)
                let dataKey = Data.fromHex(formattedKey)!
                let keystore = try! EthereumKeystoreV3(privateKey: dataKey, password: password)!
                let name = CryptoConfig.shared.getWalletName()
                let keyData = try! JSONEncoder().encode(keystore.keystoreParams)
                let address = keystore.addresses!.first!.address
                let wallet = Wallet(address: address, data: keyData, name: name, isHD: false)

                let data = wallet.data
                let keystoreManager: KeystoreManager
                if wallet.isHD {
                    let keystore = BIP32Keystore(data)!
                    keystoreManager = KeystoreManager([keystore])
                } else {
                    let keystore = EthereumKeystoreV3(data)!
                    keystoreManager = KeystoreManager([keystore])
                }

                web3.addKeystoreManager(keystoreManager)

                let value: String = amount
                let walletAddress = EthereumAddress(wallet.address)!

                let toAddress = EthereumAddress(sendToAccountAddress)!
                let contract = web3.contract(Web3.Utils.coldWalletABI, at: toAddress, abiVersion: 2)!
                let convertedAmount = Web3.Utils.parseToBigUInt(value, units: .eth)

                var options = TransactionOptions.defaultOptions
                options.value = convertedAmount
                options.from = walletAddress
                options.gasPrice = .automatic
                options.gasLimit = .automatic
                let tx = contract.write(
                    "fallback",
                    parameters: [AnyObject](),
                    extraData: Data(),
                    transactionOptions: options)!

                let sendResult = try tx.send(password: password)
                if let transactionHash = sendResult.transaction.txhash {
                    Defaults[.cryptoTransactionHashStore].insert(transactionHash)
                }
                showSendForm = false
            } catch {
                print("🔥 Unexpected error: \(error).")
            }
        }
    }
}
