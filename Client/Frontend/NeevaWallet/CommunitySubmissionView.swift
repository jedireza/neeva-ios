// Copyright Neeva. All rights reserved.

import Combine
import Foundation
import Shared
import SwiftUI
import WalletCore

public struct CommunitySubmissionView: View {
    @Environment(\.hideOverlay) private var hideOverlaySheet
    @EnvironmentObject var model: Web3Model

    let iconURL: URL
    let domain: String
    let url: URL
    @Binding var trust: Bool
    @State private var request: TrustSignalRequest? = nil

    public init(iconURL: URL, domain: String, url: URL, trust: Binding<Bool>) {
        self.iconURL = iconURL
        self.domain = domain
        self.url = url
        self._trust = trust
    }

    public var body: some View {
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
            Text(
                "If you have knowledge of this site, please help the community and verify it as authentic or report as scam."
            )
            .withFont(.bodyXLarge)
            .foregroundColor(.label)
            .multilineTextAlignment(.center)
            .fixedSize(horizontal: false, vertical: true)
            VStack(spacing: 16) {
                NeevaWalletLongPressButton(
                    action: {
                        trust = true
                        if let balance = Double(model.balanceFor(.ether) ?? "0"), balance > 0 {
                            request = TrustSignalRequest(url: url, trusted: true)
                        }
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
                        if let balance = Double(model.balanceFor(.ether) ?? "0"), balance > 0 {
                            request = TrustSignalRequest(url: url, trusted: false)
                        }
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
