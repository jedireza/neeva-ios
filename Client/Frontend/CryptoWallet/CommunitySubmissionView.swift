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
            Text(
                """
                We were not able to confirm the validity of this site. Please proceed with caution.
                """
            )
            .font(.roobert(size: 16))
            .foregroundColor(.label)
            .multilineTextAlignment(.center)
            .fixedSize(horizontal: false, vertical: true)
            .padding(.bottom, 8)
            Button(
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
                            .frame(width: 16, height: 16)
                        Text("Report as trusted")
                    }.frame(maxWidth: .infinity)

                }
            )
            .buttonStyle(.neeva(.primary))
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
            ).buttonStyle(.neeva(.secondary))
            Spacer()
        }
    }
}
