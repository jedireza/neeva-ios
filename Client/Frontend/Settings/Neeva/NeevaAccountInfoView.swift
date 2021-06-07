//
//  NeevaAccountInfoView.swift
//  Client
//
//  Copyright © 2021 Neeva. All rights reserved.
//

import SwiftUI
import Shared

struct NeevaAccountInfoView: View {
    @ObservedObject var userInfo: NeevaUserInfo
    @Binding var isPresented: Bool

    @State var signingOut = false

    var body: some View {
        List {
            SwiftUI.Section(header: Text("Signed in to Neeva with")) {
                HStack {
                    (userInfo.authProvider?.icon ?? Image("placeholder-avatar"))
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 20, height: 20)
                        .padding(.trailing, 14)
                    VStack(alignment: .leading, spacing: 2) {
                        Text(userInfo.authProvider?.displayName ?? "Unknown")
                        Text(userInfo.email ?? "")
                            .font(.footnote)
                            .foregroundColor(.secondaryLabel)
                    }
                    .padding(.vertical, 5)
                }
                .accessibilityElement(children: .ignore)
                .accessibilityLabel("\(userInfo.authProvider?.displayName ?? "Unknown"), \(userInfo.email ?? "")")

                Button("Sign Out") { signingOut = true }
                    .actionSheet(isPresented: $signingOut) {
                        ActionSheet(title: Text("Sign out of Neeva?"), buttons: [
                            .destructive(Text("Sign Out")) {
                                ClientLogger.shared.logCounter(.SettingSignout, attributes: EnvironmentHelper.shared.getAttributes())
                                if userInfo.hasLoginCookie() {
                                    userInfo.clearCache()
                                    userInfo.deleteLoginCookie()
                                    userInfo.didLogOut()
                                    isPresented = false
                                }
                            },
                            .cancel()
                        ])
                    }
            }
        }
        .listStyle(GroupedListStyle())
        .navigationTitle(userInfo.displayName ?? "Neeva Account")
    }
}

struct NeevaAccountInfoView_Previews: PreviewProvider {
    static var previews: some View {
        ForEach(SSOProvider.allCases, id: \.self) { authProvider in
            NeevaAccountInfoView(userInfo: NeevaUserInfo(previewDisplayName: "First Last", email: "name@example.com", pictureUrl: "https://pbs.twimg.com/profile_images/1273823608297500672/MBtG7NMI_400x400.jpg", authProvider: authProvider), isPresented: .constant(true))
        }.previewLayout(.fixed(width: 375, height: 150))
    }
}
