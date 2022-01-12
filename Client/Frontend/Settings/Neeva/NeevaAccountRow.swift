// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Shared
import SwiftUI

struct NeevaAccountRow: View {
    @ObservedObject var userInfo: NeevaUserInfo

    var body: some View {
        HStack(spacing: 13) {
            Group {
                if let data = userInfo.pictureData,
                    let image = UIImage(data: data)
                {
                    Image(uiImage: image)
                        .resizable()
                } else if let pictureUrl = userInfo.pictureUrl, !pictureUrl.isEmpty {
                    Color.secondarySystemFill
                } else {
                    let name = (userInfo.displayName ?? "?").prefix(2).uppercased()
                    Color.brand.blue
                        .overlay(
                            Text(name)
                                .accessibilityHidden(true)
                                .font(.system(size: 35 / 2))
                                .foregroundColor(.white)
                        )
                }
            }
            .clipShape(Circle())
            .aspectRatio(contentMode: .fill)
            .frame(width: 35, height: 35)

            VStack(alignment: .leading, spacing: 3) {
                if let name = userInfo.displayName {
                    HStack {
                        Text(name)
                        if let type = userInfo.subscriptionType {
                            Text(type.displayName)
                                .font(.caption)
                                .padding(3)
                                .padding(.horizontal, 3)
                                .background(Color.secondarySystemFill)
                                .cornerRadius(5)
                                .fixedSize()
                                .frame(height: 1)
                        }
                    }
                }
                if let email = userInfo.email {
                    Text(email)
                        .foregroundColor(.secondaryLabel)
                        .font(.system(size: 15))
                }
            }
        }.frame(height: 60 - 12)
    }
}

struct NeevaAccountRow_Previews: PreviewProvider {
    static var previews: some View {
        SettingPreviewWrapper {
            NeevaAccountRow(
                userInfo: NeevaUserInfo(
                    previewDisplayName: "First Last", email: "name@example.com",
                    pictureUrl:
                        "https://pbs.twimg.com/profile_images/1273823608297500672/MBtG7NMI_400x400.jpg",
                    authProvider: .apple))
            NeevaAccountRow(
                userInfo: NeevaUserInfo(
                    previewDisplayName: "Jane Doe", email: "name@example.com",
                    pictureUrl: "invalid-url", authProvider: .apple))
            NeevaAccountRow(
                userInfo: NeevaUserInfo(
                    previewDisplayName: "No Icon", email: "name@example.com", pictureUrl: nil,
                    authProvider: .apple))
        }
    }
}
