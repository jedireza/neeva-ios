// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Defaults
import Shared
import SwiftUI
import web3swift

public struct ImportWalletView: View {
    let model = OnboardingModel()
    @State var inputPhrase: String = ""
    @Binding var viewState: ViewState
    @State var isImporting: Bool = false

    public init(viewState: Binding<ViewState>) {
        self._viewState = viewState
    }

    public var body: some View {
        VStack(spacing: 16) {
            Text("Import Wallet")
                .withFont(.headingXLarge)
                .foregroundColor(.label)
                .padding(.top, 60)

            ZStack {
                TextEditor(text: $inputPhrase)
                    .withFont(unkerned: .bodyLarge)
                    .foregroundColor(.label)
                    .modifier(NoAutoCapitalize())
                    .frame(maxWidth: .infinity)
                if inputPhrase.isEmpty {
                    Text("Type or paste your Secret Recovery Phrase")
                        .withFont(.bodyLarge)
                        .foregroundColor(.secondary)
                }
            }
            .padding(12)
            .background(Color.DefaultBackground)
            .roundedOuterBorder(
                cornerRadius: 12,
                color: .quaternarySystemFill,
                lineWidth: 1
            )
            .frame(maxHeight: 120)
            .padding(.bottom, 50)

            Button(action: { viewState = .starter }) {
                Text("Back")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.wallet(.secondary))
            Button(action: {
                isImporting = true
                model.importWallet(inputPhrase: inputPhrase) {
                    isImporting = false
                    viewState = .dashboard
                }
            }) {
                HStack {
                    Text(isImporting ? "Importing  " : "Import")
                    if isImporting {
                        ProgressView()
                    }
                }.frame(maxWidth: .infinity)
            }
            .buttonStyle(.wallet(.primary))
            .disabled(inputPhrase.isEmpty)
        }
        .padding(.horizontal, 16)
        .ignoresSafeArea(.keyboard)
    }
}

struct NoAutoCapitalize: ViewModifier {
    func body(content: Content) -> some View {
        if #available(iOS 15.0, *) {
            content
                .textInputAutocapitalization(.never)
        } else {
            content
                .autocapitalization(.none)
        }
    }
}
