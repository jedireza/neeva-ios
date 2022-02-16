// Copyright Neeva. All rights reserved.

import Combine
import Foundation
import Shared
import SwiftUI

struct CommunitySubmissionView: View {
    @Environment(\.hideOverlay) private var hideOverlaySheet

    let iconURL: URL
    let domain: String
    let url: URL
    @Binding var trust: Bool
    @State private var request: TrustSignalRequest? = nil

    var body: some View {
        VStack(spacing: 24) {
            VStack(spacing: 8) {
                WalletSequenceSiteHeader(iconURL: iconURL, domain: domain, trusted: false)
                Text("We were not able to confirm the validity of this site.")
                    .withFont(.bodyLarge)
                    .foregroundColor(Color(light: .brand.variant.blue, dark: .brand.blue))
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: .infinity, alignment: .center)
            }
            .padding(12)
            .background(Color.quaternarySystemFill)
            .cornerRadius(12)
            Text("You can help the community by verifying sites you know about or reporting scams.")
                .withFont(.bodyXLarge)
                .foregroundColor(.label)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
            VStack(spacing: 16) {
                NeevaWalletLongPressButton(
                    action: {
                        trust = true
                        request = TrustSignalRequest(url: url, trusted: true)
                    },
                    label: {
                        Text("Hold to verify")
                            .frame(maxWidth: .infinity)

                    }
                )
                Button(
                    action: {
                        trust = false
                        hideOverlaySheet()
                        request = TrustSignalRequest(url: url, trusted: false)
                    },
                    label: {
                        Text("Report as scam")
                            .frame(maxWidth: .infinity)
                    }
                ).buttonStyle(.wallet(.secondary))
            }
        }
        .padding(12)
        .padding(.bottom, 24)
    }
}
