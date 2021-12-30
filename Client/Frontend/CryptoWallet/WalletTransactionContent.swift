// Copyright Neeva. All rights reserved.

import Foundation
import SDWebImageSwiftUI
import Shared
import SwiftUI
import WalletConnectSwift

enum TransactionType: String {
    case sessionRequest
    case personalSign
}

struct TransactionInfo {
    let type: TransactionType
    let thumbnailURL: URL
    let dAppMeta: Session.ClientMeta
    let message: String
    let onAccept: () -> Void
    let onReject: () -> Void
}

class Web3SessionModel: ObservableObject {
    @Published var transaction: TransactionInfo? = nil

    func reset() {
        transaction = nil
    }
}

struct WalletTransactionContent: View {
    @Environment(\.hideOverlay) private var hideOverlaySheet
    @ObservedObject var model: Web3SessionModel

    var header: String {
        guard let transaction = model.transaction else {
            return ""
        }

        switch transaction.type {
        case .sessionRequest:
            return " wants to connect to your wallet"
        case .personalSign:
            return
                " wants to personal sign a message using your wallet."
        }
    }

    var body: some View {
        VStack {
            if let transaction = model.transaction {
                WebImage(url: transaction.thumbnailURL)
                    .resizable()
                    .placeholder {
                        Color.secondarySystemFill
                    }
                    .transition(.opacity)
                    .scaledToFit()
                    .frame(width: 48, height: 48)
                    .cornerRadius(12)
                (Text(transaction.dAppMeta.name).bold()
                    + Text(header))
                    .withFont(.headingLarge)
                    .lineLimit(2)
                    .foregroundColor(.label)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity, alignment: .center)
                Text(
                    transaction.dAppMeta.url.baseDomain
                        ?? transaction.dAppMeta.url.domainURL.absoluteString
                )
                .withFont(.labelLarge)
                .foregroundColor(.ui.adaptive.blue)
                if let description = transaction.message {
                    Text(description)
                        .withFont(.bodyLarge)
                        .foregroundColor(.secondaryLabel)
                }
                Spacer()
                HStack {
                    Button(
                        action: {
                            transaction.onReject()
                            hideOverlaySheet()
                        },
                        label: {
                            Text("Reject")
                                .frame(maxWidth: .infinity)
                        }
                    ).buttonStyle(NeevaButtonStyle(.secondary))
                        .disabled(model.transaction == nil)
                    Button(
                        action: {
                            transaction.onAccept()
                            hideOverlaySheet()
                        },
                        label: {
                            Text("Accept")
                                .frame(maxWidth: .infinity)
                        }
                    ).buttonStyle(NeevaButtonStyle(.primary))
                        .disabled(model.transaction == nil)
                }
            } else {
                Spacer()
                ProgressView()
                    .scaleEffect(x: 2, y: 2, anchor: .center)
                Spacer()
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
}
