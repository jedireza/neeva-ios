// Copyright Neeva. All rights reserved.

import SwiftUI

struct TransactionHistoryView: View {
    @Binding var transactionHistory: [TransactionDetail]

    var body: some View {
        ScrollView(.vertical) {
            VStack(alignment: .leading) {
                if transactionHistory.count > 0 {
                Text("Transactions")
                    .font(.roobert(size: 14))
                    .padding(.top, 20)
                }
                ForEach(transactionHistory, id: \.self) { history in
                    HStack {
                        Image(systemSymbol: history.transactionAction == .Send ? .arrowUpRightCircle : .arrowDownCircle)
                            .renderingMode(.template)
                            .foregroundColor(Color.brand.peach)
                            .font(.system(size: 32))
                        VStack(alignment: .leading) {
                            HStack {
                                Text(history.transactionAction.rawValue)
                                    .font(.roobert(size: 24))
                                Spacer()
                                Text("\(history.amountInEther) ETH")
                                    .font(.roobert(size: 24))
                            }
                            ScrollView(.horizontal) {
                                Text(history.oppositeAddress)
                                    .multilineTextAlignment(.leading)
                                    .font(.system(size: 13))
                                    .foregroundColor(.secondary)
                            }
                            .padding(.top, -8)
                        }
                    }
                    .padding(10)
                    .background(
                        RoundedRectangle(cornerRadius: 8).stroke(Color.ui.gray91, lineWidth: 0.5)
                    )
                    .background(Color.white.opacity(0.8))
                    .cornerRadius(8)
                }
            }
        }
    }
}
