// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Defaults
import MobileCoreServices
import Shared
import SwiftUI

struct ShowPhrasesView: View {
    @State var copyButtonText: String = "Copy"
    @Binding var viewState: ViewState

    var body: some View {
        VStack {
            VStack(alignment: .leading, spacing: 22) {
                Text("Congrats! Your wallet is created")
                    .font(.roobert(size: 18))
                Text("Secret Recovery Phrase")
                    .font(.roobert(size: 32))
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)
                Text(
                    "Your Secret Recovery Phrase makes it easy to back up and restore your account. Store this phrase in a safe place. Never disclose your Secrete Recovery Phrase to anyone."
                )
                .font(.system(size: 14))
                .multilineTextAlignment(.leading)
                .foregroundColor(.secondary)
            }
            .padding(.bottom, 20)

            if !Defaults[.cryptoPhrases].isEmpty {
                VStack {
                    Text("\(Defaults[.cryptoPhrases])")
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                        .font(.system(size: 26))
                        .foregroundColor(Color.ui.gray20)
                    HStack {
                        Spacer()
                        Button(action: {
                            copyButtonText = "Copied!"
                            UIPasteboard.general.setValue(
                                Defaults[.cryptoPhrases],
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
                }
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 10).stroke(Color.ui.gray91, lineWidth: 0.5)
                )
                .background(Color.white.opacity(0.8))
                .cornerRadius(10)
            } else {
                Text("Something went wrong, please try again")
            }

            HStack {
                Spacer()
                Button(action: {
                    viewState = .dashboard
                }) {
                    Text("Next")
                        .font(.roobert(.semibold, size: 18))
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.neeva(.primary))
            }
            .padding(.top, 10)
        }
        .padding(.horizontal, 16)
    }
}
