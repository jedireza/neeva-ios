//
//  NeevaAccountRow.swift
//  
//
//

import SwiftUI
import Shared

struct NeevaAccountRow: View {
    @ObservedObject var userInfo: NeevaUserInfo

    var body: some View {
        HStack(spacing: 13) {
            Group {
                if let data = userInfo.pictureData,
                   let image = UIImage(data: data) {
                    Image(uiImage: image)
                        .resizable()
                } else if userInfo.pictureUrl != nil {
                    Color.secondarySystemFill
                } else {
                    let name = firstCharacters(2, from: userInfo.displayName ?? "?")
                    Color.Neeva.Brand.Blue
                        .overlay(
                            Text(name)
                                .accessibilityHidden(true)
                                .font(.system(size: 35/2))
                                .foregroundColor(Color.Neeva.Brand.White)
                        )
                }
            }
            .clipShape(Circle())
            .aspectRatio(contentMode: .fill)
            .frame(width: 35, height: 35)

            VStack(alignment: .leading) {
                if let name = userInfo.displayName {
                    Text(name)
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
            NeevaAccountRow(userInfo: NeevaUserInfo(previewDisplayName: "First Last", email: "name@example.com", pictureUrl: "https://pbs.twimg.com/profile_images/1273823608297500672/MBtG7NMI_400x400.jpg", authProvider: .apple))
            NeevaAccountRow(userInfo: NeevaUserInfo(previewDisplayName: "Jane Doe", email: "name@example.com", pictureUrl: "invalid-url", authProvider: .apple))
            NeevaAccountRow(userInfo: NeevaUserInfo(previewDisplayName: "No Icon", email: "name@example.com", pictureUrl: nil, authProvider: .apple))
        }
    }
}
