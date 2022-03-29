// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Defaults
import Shared
import SwiftUI
import web3swift

public struct XYZIntroView: View {
    @Default(.cryptoPublicKey) var publicKey
    @State var isCreatingWallet: Bool = false
    @Binding var viewState: ViewState

    public init(viewState: Binding<ViewState>) {
        self._viewState = viewState
    }

    public var body: some View {
        VStack(alignment: .leading) {
            Text("The Web3 Browser")
                .withFont(.displayMedium)
                .gradientForeground()
                .padding(.bottom, 64)
                .frame(maxWidth: .infinity, alignment: .center)
            Text("- Explore and browse web3 with integrated search")
                .withFont(.headingLarge)
                .gradientForeground()
            Text("- Beat scammers!")
                .withFont(.headingLarge)
                .gradientForeground()
            Text("- Stake, swap tokens, and buy NFTs on web3 sites")
                .withFont(.headingLarge)
                .gradientForeground()
            Text("All in one app.")
                .withFont(.displayMedium)
                .gradientForeground()
                .padding(.top, 24)
            Spacer()
            Button(action: { viewState = .starter }) {
                Text("LET'S GO!")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.wallet(.primary))
            .padding(.vertical, 8)
            .padding(.bottom, 64)
        }.padding(.horizontal, 32)
    }
}
