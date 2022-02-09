// Copyright Neeva. All rights reserved.

import Combine
import Foundation
import Shared
import SwiftUI

struct CommunitySubmissionView: View {
    @Environment(\.hideOverlay) private var hideOverlaySheet

    let url: URL
    @Binding var trust: Bool
    @State private var request: TrustSignalRequest? = nil

    var body: some View {
        VStack(spacing: 12) {
            Spacer()
            VStack(spacing: 8) {
                Text(
                    "We were not able to confirm the validity of this site. Please proceed with caution."
                )
                Text(
                    "You can help the Neeva community by verifying sites you know about or by reporting scams."
                )
            }
            .font(.roobert(size: 16))
            .foregroundColor(.label)
            .multilineTextAlignment(.center)
            .fixedSize(horizontal: false, vertical: true)
            .padding(.bottom, 8)

            NeevaWalletLongPressButton(
                action: {
                    trust = true
                    request = TrustSignalRequest(url: url, trusted: true)
                },
                label: {
                    HStack(spacing: 6) {
                        Image("twitter-verified-large")
                            .renderingMode(.template)
                            .resizable()
                            .scaledToFit()
                            .foregroundColor(.white)
                            .frame(width: 12, height: 12)
                        Text("Press and hold to verify")
                    }.frame(maxWidth: .infinity)

                }
            )
            Button(
                action: {
                    trust = false
                    hideOverlaySheet()
                    request = TrustSignalRequest(url: url, trusted: false)
                },
                label: {
                    HStack(spacing: 6) {
                        Symbol(decorative: .xmarkOctagonFill)
                            .foregroundColor(.red)
                        Text("Report as scam")
                    }.frame(maxWidth: .infinity)
                }
            ).buttonStyle(.wallet(.secondary))
            Spacer()
        }
    }
}
