// Copyright Neeva. All rights reserved.

import Defaults
import Foundation
import SDWebImageSwiftUI
import Shared
import SwiftUI
import WalletConnectSwift

struct SessionInfoView: View {
    @EnvironmentObject var web3Model: Web3SessionModel

    let dAppSession: Session
    @Binding var showdAppSessionControls: Bool

    var body: some View {
        VStack {
            WebImage(url: dAppSession.dAppInfo.peerMeta.icons.first)
                .resizable()
                .placeholder {
                    Color.secondarySystemFill
                }
                .transition(.opacity)
                .scaledToFit()
                .frame(width: 48, height: 48)
                .cornerRadius(12)
            Text(
                dAppSession.dAppInfo.peerMeta.url.baseDomain ?? ""
            )
            .withFont(.labelLarge)
            .foregroundColor(.ui.adaptive.blue)
            if let description = dAppSession.dAppInfo.peerMeta.description {
                Text(description)
                    .withFont(.bodyLarge)
                    .foregroundColor(.secondaryLabel)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer().frame(maxHeight: 50)
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
                        .frame(maxWidth: .infinity)
                }
            ).buttonStyle(NeevaButtonStyle(.primary))
        }.padding(16).frame(minHeight: 300)
    }
}
