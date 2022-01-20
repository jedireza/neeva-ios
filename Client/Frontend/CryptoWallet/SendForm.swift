// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Defaults
import Shared
import SwiftUI
import web3swift

struct SendForm: View {
    @State var sendToAccountAddress = ""
    @State var amount: String = ""
    @Binding var showSendForm: Bool
    @State var showQRScanner: Bool = false

    var body: some View {
        VStack(alignment: .leading) {
            Text("Send To")
                .font(.roobert(size: 14))
            HStack {
                TextField("Recipient Address", text: $sendToAccountAddress)
                Spacer()
                Button(action: { showQRScanner = true }) {
                    Symbol(decorative: .qrcodeViewfinder, style: .labelMedium)
                        .foregroundColor(.secondaryLabel)
                }
            }
            .padding()
            .overlay(
                RoundedRectangle(cornerRadius: 12.0)
                    .stroke(Color(UIColor.systemGray5), lineWidth: 1)
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
                        .stroke(Color(UIColor.systemGray5), lineWidth: 1.0)
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
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.neeva(.secondary))
                .padding(.top, 8)

                Button(action: sendEth) {
                    Text("Send")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.neeva(.primary))
                .padding(.top, 8)
                .disabled(amount.isEmpty && sendToAccountAddress.isEmpty)
            }
        }
        .sheet(isPresented: $showQRScanner) {
            ScannerView(showQRScanner: $showQRScanner, returnAddress: $sendToAccountAddress)
        }
    }

    func sendEth() {
        CryptoConfig.shared.sendEth(amount: amount, sendToAccountAddress: sendToAccountAddress) {
            showSendForm = false
        }
    }
}
