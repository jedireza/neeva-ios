// Copyright Neeva. All rights reserved.

import Defaults
import Shared
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
                .buttonStyle(NeevaButtonStyle(.secondary))
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
        CryptoConfig.shared.sendEth(amount: amount, sendToAccountAddress: sendToAccountAddress) {
            showSendForm = false
        }
    }
}
