// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Defaults
import MobileCoreServices
import Shared
import SwiftUI

public struct ShowPhrasesView: View {
    let dismiss: () -> Void
    @State var copyButtonText = "Copy"
    @State var showPhrases = false
    @Binding public var viewState: ViewState
    var secretPhrases: String {
        NeevaConstants.cryptoKeychain[string: NeevaConstants.cryptoSecretPhrase] ?? ""
    }

    public init(dismiss: @escaping () -> Void, viewState: Binding<ViewState>) {
        self._viewState = viewState
        self.dismiss = dismiss
    }

    public var body: some View {
        VStack(spacing: 16) {
            Text("Secret Recovery Phrase")
                .withFont(.headingXLarge)
                .foregroundColor(.label)
                .padding(.top, 60)
            Text(
                "You will need your Secret Recovery Phrase to recover your wallet and funds. Please write it down and save it in a safe place."
            )
            .withFont(.bodyLarge)
            .foregroundColor(.secondaryLabel)
            .multilineTextAlignment(.center)
            .padding(.bottom, 24)
            ZStack {
                let labelColor = Color(light: Color.white, dark: Color.black)
                HStack {
                    VStack(alignment: .leading) {
                        ForEach(0...5, id: \.self) { index in
                            let phrase = secretPhrases.split(separator: " ").map { String($0) }[
                                index]
                            Text("\(index + 1). \(phrase)")
                                .withFont(.bodyLarge)
                                .foregroundColor(.label)
                        }
                    }.frame(maxWidth: .infinity)
                    VStack(alignment: .leading) {
                        ForEach(6...11, id: \.self) { index in
                            let phrase = secretPhrases.split(separator: " ").map { String($0) }[
                                index]
                            Text("\(index + 1). \(phrase)")
                                .withFont(.bodyLarge)
                                .foregroundColor(.label)
                        }
                    }.frame(maxWidth: .infinity)
                }.padding(24)
                    .opacity(showPhrases ? 1 : 0)
                    .animation(.easeInOut)
                VStack(spacing: 16) {
                    Text(
                        "Anyone who has this Secret Recovery Phrase can access your wallet and funds! Make sure no one else can see your screen."
                    )
                    .withFont(.bodyLarge)
                    .foregroundColor(labelColor)
                    .multilineTextAlignment(.center)
                    Button(
                        action: { showPhrases = true },
                        label: {
                            Text("View")
                                .withFont(.bodyLarge)
                                .foregroundColor(labelColor)
                                .padding(.vertical, 12)
                                .padding(.horizontal, 40)
                                .roundedOuterBorder(
                                    cornerRadius: 24, color: labelColor, lineWidth: 1)
                        })
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 28)
                .opacity(showPhrases ? 0 : 1)
                .animation(.easeInOut)
            }
            .roundedOuterBorder(cornerRadius: 12, color: .quaternarySystemFill, lineWidth: 1)
            .background(showPhrases ? Color.clear : Color.label.opacity(0.6))
            .background(
                showPhrases
                    ? Color.clear
                    : Color(
                        light: Color(UIColor.tertiarySystemFill.swappedForStyle),
                        dark: Color(UIColor.quaternarySystemFill.swappedForStyle))
            )
            .cornerRadius(12)
            .padding(.top, 48)

            Button(action: {
                copyButtonText = "Copied!"
                UIPasteboard.general.setValue(
                    secretPhrases,
                    forPasteboardType: kUTTypePlainText as String)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                    copyButtonText = "Copy"
                }
            }) {
                Text("Copy to clipboard")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.wallet(.secondary))
            Button(action: {
                dismiss()
            }) {
                Text("Done")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.wallet(.primary))
            .padding(.top, 50)
        }
        .padding(.horizontal, 16)
    }
}
