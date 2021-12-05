// Copyright Neeva. All rights reserved.

import Defaults
import SwiftUI
import web3swift

struct Wallet {
    let address: String
    let data: Data
    let name: String
    let isHD: Bool
}

struct HDKey {
    let name: String?
    let address: String
}

enum ViewState {
    case starter
    case dashboard
    case transaction
    case showPhrases
}

struct CryptoWalletView: View {
    @State var viewState: ViewState = Defaults[.cryptoPhrases].isEmpty ? .starter : .showPhrases
    // @State var viewState: ViewState = .starter
    var onDismiss: () -> Void

    var body: some View {
        ScrollView(.vertical) {
            VStack {
                HStack {
                    Spacer()
                    Button(action: onDismiss) {
                        Text("Close")
                            .frame(minWidth: 60, minHeight: 45, alignment: .center)
                    }
                    .background(Color.ui.gray91)
                    .contentShape(Rectangle())
                    .cornerRadius(10)
                }
                .padding()
                .padding(.trailing, 20)
                .padding(.top, 15)

                ZStack {
                    VStack {
                        Circle()
                            .strokeBorder(Color.brand.pistachio, lineWidth: 2)
                            .background(Circle().foregroundColor(Color.brand.pistachio))
                            .frame(width: 280, height: 280)
                            .offset(x: 140, y: 80)

                        Circle()
                            .strokeBorder(Color(hex: 0xD4F0F5), lineWidth: 2)
                            .background(Circle().foregroundColor(Color(hex: 0xD4F0F5)))
                            .frame(width: 300, height: 300)
                            .offset(x: -140, y: 120)
                    }
                    .frame(maxWidth: .infinity, maxHeight: 400)

                    if viewState == .starter {
                        WelcomeStarterView(viewState: $viewState)
                            .padding(.horizontal, 25)
                    } else if viewState == .dashboard {
                        WalletDashboard()
                    } else if viewState == .transaction {

                    } else if viewState == .showPhrases {
                        ShowPhrasesView(viewState: $viewState)
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.brand.offwhite)
        .ignoresSafeArea(.all)
        .colorScheme(.light)
    }
}
