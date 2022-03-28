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
    @State var isFocused: Bool = false

    public init(viewState: Binding<ViewState>) {
        self._viewState = viewState
    }

    public var body: some View {
        VStack(spacing: 16) {
            Text("Import Wallet")
                .withFont(.headingXLarge)
                .foregroundColor(.label)
                .padding(.top, 60)

            ZStack(alignment: .top) {
                if #available(iOS 15.0, *) {
                    FocusableTextEditor(inputPhrase: $inputPhrase, isFocusedCopy: $isFocused)
                } else {
                    TextEditor(text: $inputPhrase)
                        .colorMultiply(Color.DefaultBackground)
                        .withFont(unkerned: .bodyLarge)
                        .foregroundColor(.label)
                        .autocapitalization(.none)
                        .frame(maxWidth: .infinity)
                }
                Text("Type or paste your Secret Recovery Phrase")
                    .withFont(.bodyLarge)
                    .foregroundColor(.secondary)
                    .allowsHitTesting(false)
                    .animation(nil)
                    .opacity(inputPhrase.isEmpty && !isFocused ? 1 : 0)
                    .animation(.easeInOut(duration: 0.2))
            }
            .padding(12)
            .roundedOuterBorder(
                cornerRadius: 12,
                color: isFocused ? .ui.adaptive.blue : .tertiarySystemFill,
                lineWidth: 1
            )
            .frame(maxHeight: 120)

            if UIPasteboard.general.string?.split(separator: " ").count == 12 && isFocused {
                Button(
                    action: {
                        guard !isImporting else { return }

                        inputPhrase = UIPasteboard.general.string!
                        isImporting = true
                        model.importWallet(inputPhrase: inputPhrase) {
                            isImporting = false
                            viewState = .dashboard
                        }
                    },
                    label: {
                        HStack(spacing: 4) {
                            Symbol(decorative: .docOnClipboardFill, style: .bodyMedium)
                            Text("Paste & Import")

                        }
                    }
                )
                .buttonStyle(DashboardButtonStyle())
                .padding(.horizontal, 16)
                .frame(maxWidth: .infinity, alignment: .leading)
            } else {
                Spacer().frame(height: 50)
            }

            Button(action: { viewState = .starter }) {
                Text("Back")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.wallet(.secondary))
            Button(action: {
                guard !isImporting else { return }
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

@available(iOS 15.0, *)
struct FocusableTextEditor: View {
    @Binding var inputPhrase: String
    @Binding var isFocusedCopy: Bool
    @FocusState private var isFocused: Bool

    var body: some View {
        TextEditor(text: $inputPhrase)
            .focused($isFocused)
            .withFont(unkerned: .bodyLarge)
            .foregroundColor(.label)
            .textInputAutocapitalization(.never)
            .frame(maxWidth: .infinity)
            .onChange(of: isFocused) { val in
                isFocusedCopy = isFocused
            }
    }
}
