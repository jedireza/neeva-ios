// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Shared
import SwiftUI

struct NeevaAccountInfoView: View {
    @ObservedObject var userInfo: NeevaUserInfo
    @Binding var isPresented: Bool

    @Environment(\.onOpenURL) var openURL

    @State var signingOut = false

    var body: some View {
        List {
            Section(header: Text("Signed in to Neeva with")) {
                HStack {
                    (userInfo.authProvider?.icon ?? Image("placeholder-avatar"))
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 20, height: 20)
                        .padding(.trailing, 14)
                        .accessibilityHidden(true)
                    VStack(alignment: .leading, spacing: 2) {
                        Text(userInfo.authProvider?.displayName ?? "Unknown")
                        Text(userInfo.email ?? "")
                            .font(.footnote)
                            .foregroundColor(.secondaryLabel)
                    }
                    .padding(.vertical, 5)
                }
                .accessibilityElement(children: .ignore)
                .accessibilityLabel(
                    "\(Text(userInfo.authProvider?.displayName ?? "Unknown")), \(userInfo.email ?? "")"
                )

            }

            if let type = userInfo.subscriptionType {
                Section(header: Text(type.displayName)) {
                    Text(type.description).padding(.vertical, 5)
                }
            } else {
                DecorativeSection {
                    Button("No Subscription. Check status on the Neeva website.") {
                        openURL(NeevaConstants.appSettingsURL)
                    }
                }
            }

            DecorativeSection {
                Button("Sign Out") { signingOut = true }
                    .actionSheet(isPresented: $signingOut) {
                        ActionSheet(
                            title: Text("Sign out of Neeva?"),
                            buttons: [
                                .destructive(Text("Sign Out")) {
                                    ClientLogger.shared.logCounter(
                                        .SettingSignout,
                                        attributes: EnvironmentHelper.shared.getAttributes())
                                    if userInfo.hasLoginCookie() {
                                        NotificationPermissionHelper.shared
                                            .deleteDeviceTokenFromServer()
                                        userInfo.clearCache()
                                        userInfo.deleteLoginCookie()
                                        userInfo.didLogOut()
                                        isPresented = false
                                    }
                                },
                                .cancel(),
                            ])
                    }
            }
        }
        .listStyle(InsetGroupedListStyle())
        .navigationTitle(userInfo.displayName ?? "Neeva Account")
    }
}

struct NeevaAccountInfoView_Previews: PreviewProvider {
    static var previews: some View {
        ForEach(SSOProvider.allCases, id: \.self) { authProvider in
            NeevaAccountInfoView(
                userInfo: NeevaUserInfo(
                    previewDisplayName: "First Last", email: "name@example.com",
                    pictureUrl:
                        "https://pbs.twimg.com/profile_images/1273823608297500672/MBtG7NMI_400x400.jpg",
                    authProvider: authProvider), isPresented: .constant(true))
        }.previewLayout(.fixed(width: 375, height: 150))
    }
}
