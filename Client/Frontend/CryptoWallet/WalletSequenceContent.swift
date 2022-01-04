// Copyright Neeva. All rights reserved.

import Combine
import Foundation
import SDWebImageSwiftUI
import Shared
import SwiftUI
import WalletConnectSwift
import web3swift

struct WalletSequenceContent: View {
    @Environment(\.hideOverlay) private var hideOverlaySheet
    @ObservedObject var model: Web3Model

    var header: String {
        guard let sequence = model.currentSequence else {
            return ""
        }

        switch sequence.type {
        case .sessionRequest:
            return " wants to connect to your wallet"
        case .personalSign:
            return
                " wants to personal sign a message using your wallet."
        case .sendTransaction:
            return " wants to send a transaction"
        }
    }

    var body: some View {
        VStack {
            if let sequence = model.currentSequence {
                WebImage(url: sequence.thumbnailURL)
                    .resizable()
                    .placeholder {
                        Color.secondarySystemFill
                    }
                    .transition(.opacity)
                    .scaledToFit()
                    .frame(width: 48, height: 48)
                    .cornerRadius(12)
                (Text(sequence.dAppMeta.name).bold()
                    + Text(header))
                    .withFont(.headingLarge)
                    .lineLimit(2)
                    .foregroundColor(.label)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity, alignment: .center)
                Text(
                    sequence.dAppMeta.url.baseDomain
                        ?? sequence.dAppMeta.url.domainURL.absoluteString
                )
                .withFont(.labelLarge)
                .foregroundColor(.ui.adaptive.blue)
                if let description = sequence.message {
                    Text(description)
                        .withFont(.bodyLarge)
                        .foregroundColor(.secondaryLabel)
                }
                if let ethAmount = sequence.ethAmount {
                    Label {
                        Text(ethAmount).withFont(.headingLarge).foregroundColor(.label)
                    } icon: {
                        Image("ethLogo")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 40, height: 40)
                            .padding(4)
                            .background(
                                Circle().stroke(Color.ui.gray80)
                            )
                    }
                }
                Spacer()
                HStack {
                    Button(
                        action: {
                            sequence.onReject()
                            hideOverlaySheet()
                        },
                        label: {
                            Text("Reject")
                                .frame(maxWidth: .infinity)
                        }
                    ).buttonStyle(NeevaButtonStyle(.secondary))
                        .disabled(model.currentSequence == nil)
                    Button(
                        action: {
                            sequence.onAccept()
                            hideOverlaySheet()
                        },
                        label: {
                            Text("Accept")
                                .frame(maxWidth: .infinity)
                        }
                    ).buttonStyle(NeevaButtonStyle(.primary))
                        .disabled(model.currentSequence == nil)
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
