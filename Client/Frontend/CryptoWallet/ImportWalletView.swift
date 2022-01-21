// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Defaults
import Shared
import SwiftUI
import web3swift

struct ImportWalletView: View {
    @EnvironmentObject var web3Model: Web3Model
    @State var inputPhrase: String = ""
    @Binding var viewState: ViewState
    @State var isImporting: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Import Your Wallet")
                .font(.roobert(size: 28))

            Text("Enter your secret recovery phrase below")
                .font(.system(size: 16))
                .multilineTextAlignment(.leading)
                .foregroundColor(.secondary)

            TextEditor(text: $inputPhrase)
                .foregroundColor(Color.ui.gray20)
                .font(.system(size: 26))
                .modifier(NoAutoCapitalize())
                .border(Color.brand.charcoal, width: 1)
                .frame(maxHeight: 300)

            HStack {
                Spacer()
                Button(action: { viewState = .starter }) {
                    Text("Back")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.neeva(.secondary))
                .padding(.top, 8)

                Button(action: {
                    isImporting = true
                    web3Model.importWallet(inputPhrase: inputPhrase) {
                        isImporting = false
                        viewState = .dashboard
                    }
                }) {
                    HStack {
                        Text(isImporting ? "Importing " : "Import")
                        if isImporting {
                            ProgressView()
                        }
                    }.frame(maxWidth: .infinity)
                }
                .buttonStyle(.neeva(.primary))
                .padding(.top, 8)
                .disabled(inputPhrase.isEmpty)
            }
        }
        .padding(16)
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
