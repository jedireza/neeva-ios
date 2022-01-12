// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Shared
import SwiftUI

struct SignUpOneButtonPromptViewOverlayContent: View {
    var query: String
    var skippable: Bool

    var body: some View {
        SignUpOneButtonPromptView(query: query, skippable: skippable)
            .overlayIsFixedHeight(isFixedHeight: true)
            .background(Color(.systemBackground))
    }
}

struct SignUpOneButtonPromptView: View {
    var query: String
    var skippable: Bool
    @Environment(\.hideOverlay) private var hideOverlay
    @Environment(\.onSigninOrJoinNeeva) var onSigninOrJoinNeeva
    @Environment(\.verticalSizeClass) var verticalSizeClass
    @Environment(\.horizontalSizeClass) var horizontalSizeClass

    var body: some View {
        VStack(alignment: .center) {
            Text("Thank you for trying Neeva!")
                .font(.roobert(size: 24))
                .padding(.bottom, 6)
                .padding(.top, 32)

            VStack(spacing: 2) {
                Text("Create your account for continued")
                Text("access and to see results for")
                Text("“\(query)“")
                    .withFont(.labelLarge, weight: .medium)
                    .foregroundColor(Color(light: Color(hex: 0x636366), dark: Color(hex: 0xAEAEB2)))
                    .lineLimit(1)
            }
            .withFont(unkerned: .bodyLarge)
            .foregroundColor(.secondaryLabel)

            // hide the image on small iPhones in landscape
            if horizontalSizeClass == .regular || verticalSizeClass == .regular {
                Image("signup-illustration", bundle: .main)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 253, height: 221)
                    .padding(.vertical, 30)
            } else {
                Spacer().repeated(2)
            }
            Button(action: {
                hideOverlay()
                onSigninOrJoinNeeva()
            }) {
                HStack {
                    Image("neeva-logo", bundle: .main)
                        .renderingMode(.template)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: 19)
                        .padding(.trailing, 3)
                    Spacer()
                    Text("Create Neeva account")
                        .fontWeight(.medium)
                    Spacer()
                }
                .padding(.horizontal, 40)
            }
            .buttonStyle(NeevaButtonStyle(.primary))
            .padding(.horizontal, 20)

            if skippable {
                Spacer().repeated(3)
            } else {
                Button(action: hideOverlay) {
                    Text("Skip for now")
                        .withFont(.labelLarge)
                        .foregroundColor(.secondaryLabel)
                }
                .padding(.top, 20)
                .padding(.bottom, 30)
            }
        }
    }
}

struct SignUpOneButtonPromptView_Previews: PreviewProvider {
    static var previews: some View {
        SignUpOneButtonPromptView(query: "react hook", skippable: true)
    }
}
