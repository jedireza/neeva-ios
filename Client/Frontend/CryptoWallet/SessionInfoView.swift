// Copyright Neeva. All rights reserved.

import Defaults
import Foundation
import SDWebImageSwiftUI
import Shared
import SwiftUI
import WalletConnectSwift

struct SessionInfoView: View {
    @EnvironmentObject var web3Model: Web3Model

    let dAppSession: Session
    @Binding var showdAppSessionControls: Bool

    var body: some View {
        VStack {
            if let matchingCollection = web3Model.matchingCollection {
                CollectionView(collection: matchingCollection)
            } else {
                VStack {
                    HStack(alignment: .center, spacing: 8) {
                        WebImage(url: dAppSession.dAppInfo.peerMeta.icons.first)
                            .resizable()
                            .placeholder {
                                Color.secondarySystemFill
                            }
                            .transition(.opacity)
                            .scaledToFit()
                            .frame(width: 36, height: 36)
                            .cornerRadius(8)
                        Text(
                            dAppSession.dAppInfo.peerMeta.url.baseDomain ?? ""
                        )
                        .withFont(.labelLarge)
                        .foregroundColor(.ui.adaptive.blue)
                    }
                    if let description = dAppSession.dAppInfo.peerMeta.description {
                        Text(description)
                            .withFont(.bodyLarge)
                            .foregroundColor(.secondaryLabel)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
                .padding(16)
                .frame(minHeight: 300)
            }
            Button(
                action: {
                    DispatchQueue.global(qos: .userInitiated).async {
                        try? web3Model.server?.disconnect(from: dAppSession)
                    }
                    UserDefaults.standard.set(
                        nil, forKey: DappsSessionKey(for: dAppSession.dAppInfo.peerId))
                    Defaults[.sessionsPeerIDs].remove(dAppSession.dAppInfo.peerId)
                    showdAppSessionControls = false
                    web3Model.currentSession = nil
                },
                label: {
                    Text("Disconnect")
                        .frame(width: 300)
                }
            ).buttonStyle(NeevaButtonStyle(.primary))
        }.padding(.vertical, 16)
    }
}

struct SessionInfoButton: View {
    @EnvironmentObject var web3Model: Web3Model

    let dAppSession: Session
    @State var showdAppSessionControls: Bool = false

    var body: some View {
        Button(
            action: {
                showdAppSessionControls = true
            },
            label: {
                Image("ethLogo")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 16, height: 16)
                    .padding(2)
                    .background(
                        Circle()
                            .fill(
                                web3Model.matchingCollection == nil
                                    ? Color.clear : Color.ui.adaptive.blue.opacity(0.3))
                    ).roundedOuterBorder(
                        cornerRadius: 10,
                        color: web3Model.matchingCollection == nil
                            ? Color.label : Color.ui.adaptive.blue,
                        lineWidth: web3Model.matchingCollection == nil
                            ? 1 : 2)
            }
        ).presentAsPopover(
            isPresented: $showdAppSessionControls,
            dismissOnTransition: true
        ) {
            SessionInfoView(
                dAppSession: dAppSession,
                showdAppSessionControls: $showdAppSessionControls
            ).environmentObject(web3Model)
        }
    }
}
