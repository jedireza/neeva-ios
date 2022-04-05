// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Defaults
import Shared
import SwiftUI
import web3swift

private struct XYZIntroModel: Identifiable, Codable {
    var id = UUID()
    var image: String
    var text: String
}

private class XYZIntroViewModel {
    @Published var dataSource: [XYZIntroModel] = [
        XYZIntroModel(
            image: "web3dummy",
            text: "Explore and browse web3 with integrated search"),
        XYZIntroModel(
            image: "web3dummy",
            text: "Beat scammers! Receive warnings before connecting to sketchy sites"),
        XYZIntroModel(
            image: "web3dummy",
            text: "Stake, swap tokens, and buy NFTs on web3 sites"),
    ]
}

public struct XYZIntroView: View {
    fileprivate let viewModel = XYZIntroViewModel()
    @Default(.cryptoPublicKey) var publicKey
    @State var isCreatingWallet: Bool = false
    @Binding var viewState: ViewState

    public init(viewState: Binding<ViewState>) {
        self._viewState = viewState
    }

    public var body: some View {
        GeometryReader { geometry in
            VStack(alignment: .leading) {
                TabView {
                    ForEach(
                        viewModel.dataSource, id: \.id,
                        content: {
                            createIntroView(with: $0, proxy: geometry)
                        })
                }
                .tabViewStyle(PageTabViewStyle())
                Button(action: { viewState = .starter }) {
                    Text("Let's go!")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.wallet(.primary))
                .padding(.horizontal, 24)
                .padding(.bottom, 50)
            }
        }
    }

    private func createIntroView(with model: XYZIntroModel, proxy: GeometryProxy) -> some View {
        VStack {
            Image(model.image)
                .resizable()
                .scaledToFill()
                .clipped()
                .frame(width: proxy.size.width, height: proxy.size.width)
            Text(model.text)
                .lineLimit(nil)
                .font(.system(size: 30, weight: .regular))
//                .font(.roobert(.normal, size: 30))
                .multilineTextAlignment(.center)
                .padding(.bottom, 40)
                .padding(.horizontal, 24)
            Spacer()
        }
    }
}
