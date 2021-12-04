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
}

struct CryptoWalletView: View {
    @State var viewState: ViewState = .starter
    @State var isCreatingWallet: Bool = false

    var onDismiss: () -> Void

    var body: some View {
        ScrollView(.vertical) {
            VStack {
                HStack {
                    Spacer()
                    Button(action: onDismiss) {
                        Text("Close")
                            .frame(minWidth: 50, minHeight: 30)
                    }
                    .padding(2)
                    .background(Color.ui.gray91)
                    .cornerRadius(10)
                }
                .padding()
                .padding(.trailing, 20)

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
                        WelcomeStarterView(isCreatingWallet: $isCreatingWallet)
                            .padding(.horizontal, 25)
                    } else if viewState == .dashboard {
                        WalletDashboard()
                    } else if viewState == .transaction {

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
