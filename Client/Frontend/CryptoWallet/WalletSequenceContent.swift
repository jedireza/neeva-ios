// Copyright Neeva. All rights reserved.

import Combine
import Foundation
import SDWebImageSwiftUI
import Shared
import SwiftUI
import WalletConnectSwift
import web3swift

enum SequenceType: String {
    case sessionRequest
    case personalSign
    case sendTransaction
}

struct SequenceInfo {
    let type: SequenceType
    let thumbnailURL: URL
    let dAppMeta: Session.ClientMeta
    let message: String
    let onAccept: () -> Void
    let onReject: () -> Void
    var ethAmount: String? = nil
}

class Web3SessionModel: ObservableObject, ResponseRelay {
    @Published var currentSequence: SequenceInfo? = nil
    @Published var currentSession: Session?

    let server: Server?
    let presenter: ModalPresenter
    private var selectedTab: Tab?

    private var selectedTabSubscription: AnyCancellable? = nil
    private var urlSubscription: AnyCancellable? = nil

    init(server: Server?, presenter: ModalPresenter, tabManager: TabManager) {
        self.server = server
        self.presenter = presenter
        self.currentSession =
            server?.openSessions().first(where: {
                $0.dAppInfo.peerMeta.url.baseDomain
                    == tabManager.selectedTab?.url?.baseDomain
            })
        self.selectedTab = tabManager.selectedTab

        self.selectedTabSubscription = tabManager.selectedTabPublisher.sink { tab in
            guard let tab = tab else { return }

            self.selectedTab = tab
            self.updateCurrentSession()
            self.urlSubscription = tab.$url.sink { _ in
                self.updateCurrentSession()
            }
        }
    }

    func updateCurrentSession() {
        let url =
            InternalURL(selectedTab?.url)?.isSessionRestore == true
            ? InternalURL(selectedTab?.url)?.extractedUrlParam : selectedTab?.url

        DispatchQueue.main.async {
            self.currentSession =
                self.server?.openSessions().first(where: {
                    $0.dAppInfo.peerMeta.url.baseDomain == url?.baseDomain
                })
        }
    }

    func reset() {
        currentSequence = nil
    }

    func send(_ response: Response) {
        server?.send(response)
    }

    func askToTransact(request: Request, value: String, transact: @escaping () -> String) {
        guard
            let dappInfo = server?.openSessions().first(where: {
                $0.dAppInfo.peerMeta.url.baseDomain
                    == currentSession?.dAppInfo.peerMeta.url.baseDomain
            })?.dAppInfo
        else {
            send(.reject(request))
            return
        }

        DispatchQueue.main.async {
            self.currentSequence = SequenceInfo(
                type: .sendTransaction,
                thumbnailURL: dappInfo.peerMeta.icons.first ?? .aboutBlank,
                dAppMeta: dappInfo.peerMeta,
                message:
                    "This will transfer this amount from your wallet to a wallet provided by \(dappInfo.peerMeta.name).",
                onAccept: {
                    DispatchQueue.global(qos: .userInitiated).async {
                        self.server?.send(.transaction(transact(), for: request))
                    }
                },
                onReject: {
                    DispatchQueue.global(qos: .userInitiated).async {
                        self.server?.send(.reject(request))
                    }
                },
                ethAmount: Web3.Utils.formatToEthereumUnits(Web3.Utils.hexToBigUInt(value) ?? .zero)
            )
            self.presenter.showModal(
                style: .spaces,
                headerButton: nil,
                content: {
                    WalletSequenceContent(model: self)
                },
                onDismiss: {
                    self.currentSequence = nil
                })
        }
    }

    func askToSign(request: Request, sign: @escaping () -> String) {
        guard
            let dappInfo = server?.openSessions().first(where: {
                $0.dAppInfo.peerMeta.url.baseDomain
                    == currentSession?.dAppInfo.peerMeta.url.baseDomain
            })?.dAppInfo
        else {
            send(.reject(request))
            return
        }

        DispatchQueue.main.async {
            self.currentSequence = SequenceInfo(
                type: .personalSign,
                thumbnailURL: dappInfo.peerMeta.icons.first ?? .aboutBlank,
                dAppMeta: dappInfo.peerMeta,
                message:
                    "This will not make any transactions with your wallet. But Neeva will be using your private key to sign the message.",
                onAccept: {
                    DispatchQueue.global(qos: .userInitiated).async {
                        let signature = sign()
                        self.server?.send(.signature(signature, for: request))
                    }
                },
                onReject: {
                    DispatchQueue.global(qos: .userInitiated).async {
                        self.server?.send(.reject(request))
                    }
                })
            self.presenter.showModal(
                style: .spaces,
                headerButton: nil,
                content: {
                    WalletSequenceContent(model: self)
                },
                onDismiss: {
                    self.currentSequence = nil
                })
        }
    }
}

struct WalletSequenceContent: View {
    @Environment(\.hideOverlay) private var hideOverlaySheet
    @ObservedObject var model: Web3SessionModel

    var header: String {
        guard let sequence = model.currentSequence else {
            return ""
        }

        switch sequence.type {
        case .sessionRequest:
            return " wants to connect to your wallet"
        case .personalSign:
            return
                " wants to personal sign a message using your wallet."
        case .sendTransaction:
            return " wants to send a transaction"
        }
    }

    var body: some View {
        VStack {
            if let sequence = model.currentSequence {
                WebImage(url: sequence.thumbnailURL)
                    .resizable()
                    .placeholder {
                        Color.secondarySystemFill
                    }
                    .transition(.opacity)
                    .scaledToFit()
                    .frame(width: 48, height: 48)
                    .cornerRadius(12)
                (Text(sequence.dAppMeta.name).bold()
                    + Text(header))
                    .withFont(.headingLarge)
                    .lineLimit(2)
                    .foregroundColor(.label)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity, alignment: .center)
                Text(
                    sequence.dAppMeta.url.baseDomain
                        ?? sequence.dAppMeta.url.domainURL.absoluteString
                )
                .withFont(.labelLarge)
                .foregroundColor(.ui.adaptive.blue)
                if let description = sequence.message {
                    Text(description)
                        .withFont(.bodyLarge)
                        .foregroundColor(.secondaryLabel)
                }
                if let ethAmount = sequence.ethAmount {
                    Label {
                        Text(ethAmount).withFont(.headingLarge).foregroundColor(.label)
                    } icon: {
                        Image("ethLogo")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 40, height: 40)
                            .padding(4)
                            .background(
                                Circle().stroke(Color.ui.gray80)
                            )
                    }
                }
                Spacer()
                HStack {
                    Button(
                        action: {
                            sequence.onReject()
                            hideOverlaySheet()
                        },
                        label: {
                            Text("Reject")
                                .frame(maxWidth: .infinity)
                        }
                    ).buttonStyle(NeevaButtonStyle(.secondary))
                        .disabled(model.currentSequence == nil)
                    Button(
                        action: {
                            sequence.onAccept()
                            hideOverlaySheet()
                        },
                        label: {
                            Text("Accept")
                                .frame(maxWidth: .infinity)
                        }
                    ).buttonStyle(NeevaButtonStyle(.primary))
                        .disabled(model.currentSequence == nil)
                }
            } else {
                Spacer()
                ProgressView()
                    .scaleEffect(x: 2, y: 2, anchor: .center)
                Spacer()
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
}
