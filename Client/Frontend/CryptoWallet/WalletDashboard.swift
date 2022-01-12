// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Defaults
import MobileCoreServices
import Shared
import SwiftUI
import web3swift

public enum TransactionAction: String {
    case Receive
    case Send
}

struct TransactionDetail: Hashable {
    let transactionAction: TransactionAction
    let amountInEther: String
    let oppositeAddress: String
}

struct WalletDashboard: View {
    @State var copyButtonText: String = "Copy"
    @State var accountBalance: String = ""
    @State var showSendForm: Bool = false

    @State var transactionHistory: [TransactionDetail] = []

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

            VStack(alignment: .leading) {
                Text("Account")
                    .font(.roobert(size: 14))
                HStack {
                    ScrollView(.horizontal) {
                        Text("\(Defaults[.cryptoPublicKey])")
                    }
                    Button(action: {
                        copyButtonText = "Copied!"
                        UIPasteboard.general.setValue(
                            Defaults[.cryptoPublicKey],
                            forPasteboardType: kUTTypePlainText as String)
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
                .cornerRadius(10)
            }

            if showSendForm {
                SendForm(showSendForm: $showSendForm)
            } else {
                Button(action: { showSendForm = true }) {
                    Text("Send ETH")
                        .font(.roobert(.semibold, size: 18))
                        .frame(minWidth: 300)
                }
                .buttonStyle(NeevaButtonStyle(.primary))
                .padding(.top, 8)

                TransactionHistoryView(transactionHistory: $transactionHistory)
            }
        }
        .padding(.horizontal, 25)
        .onAppear(perform: getData)
    }

    func getData() {
        let accountInfo = CryptoConfig.shared.getData()
        accountBalance = accountInfo.balance
        transactionHistory = accountInfo.transactions
    }
}

struct WalletDashboard_Previews: PreviewProvider {
    static var previews: some View {
        WalletDashboard()
    }
}
