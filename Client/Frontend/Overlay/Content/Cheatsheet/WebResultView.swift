// Copyright Neeva. All rights reserved.

import SDWebImageSwiftUI
import Shared
import SwiftUI

struct WebResultItem: View {
    let item: WebResult
    @Environment(\.onOpenURL) var onOpenURL

    var body: some View {
        Button(action: onClick) {
            VStack(alignment: .leading) {
                HStack {
                    WebImage(url: URL(string: item.faviconURL))
                        .resizable()
                        .scaledToFit()
                        .frame(width: 14, height: 14, alignment: .center)
                        .clipped()
                        .cornerRadius(2)
                    ScrollView(.horizontal) {
                        HStack(spacing: 2) {
                            Text(item.displayURLHost)
                                .foregroundColor(Color.ui.gray40)
                            Text(item.displayURLPath)
                                .foregroundColor(Color.ui.gray60)
                        }
                        .font(.system(size: 12))
                    }
                }
                Text("\(item.title)")
                    .font(.system(size: 18))
                    .foregroundColor(.brand.variant.blue)
                    .lineLimit(1)
                    .padding(.bottom, 1)
                if let publicationDate = item.publicationDate {
                    Text("\(publicationDate)")
                }
                if let snippet = item.snippet {
                    Text(snippet)
                        .font(.system(size: 13))
                        .foregroundColor(Color.ui.gray40)
                        .lineLimit(3)
                        .multilineTextAlignment(.leading)
                }
            }
        }
        .padding(.bottom, 10)
    }

    func onClick() {
        onOpenURL(item.actionURL)
    }
}

struct WebResultList: View {
    let webResult: [WebResult]

    var body: some View {
        VStack(alignment: .leading) {
            Text("Neeva Search")
                .withFont(.headingXLarge)
                .foregroundColor(.label)
                .padding(.bottom, 8)
            VStack(alignment: .leading) {
                ForEach(webResult, id: \.actionURL) { web in
                    WebResultItem(item: web)
                }
            }
        }
        .padding(.bottom, 18)
    }
}
