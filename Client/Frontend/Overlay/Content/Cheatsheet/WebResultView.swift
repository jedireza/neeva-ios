// Copyright Neeva. All rights reserved.

import SDWebImageSwiftUI
import Shared
import SwiftUI

struct WebResultHeader: View {
    let item: WebResult

    var body: some View {
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
                            .foregroundColor(
                                Color(light: Color.ui.gray40, dark: Color(hex: 0xdee6e6)))
                        Text(item.displayURLPath)
                            .foregroundColor(
                                Color(light: Color.ui.gray60, dark: Color(hex: 0x8f989a)))
                    }
                    .font(.system(size: 12))
                }
            }
            Text("\(item.title)")
                .font(.system(size: 18))
                .foregroundColor(Color(light: .brand.variant.blue, dark: Color(hex: 0x7cabe4)))
                .lineLimit(1)
                .padding(.bottom, 1)
        }
    }
}

struct WebResultItem: View {
    let item: WebResult
    @Environment(\.onOpenURL) var onOpenURL

    var body: some View {
        VStack(alignment: .leading) {
            if item.buyingGuides.count > 0 {
                WebResultHeader(item: item)
                    .onTapGesture(perform: onClick)
                    .accessibilityAddTraits(.isButton)
                    .accessibilityLabel(Text(item.title))

                BuyingGuideList(buyingGuides: item.buyingGuides)
            } else if item.inlineSearchProducts.count > 0 {
                WebResultHeader(item: item)
                    .onTapGesture(perform: onClick)
                    .accessibilityAddTraits(.isButton)
                    .accessibilityLabel(Text(item.title))

                InlineSearchProductList(inlineSearchProducts: item.inlineSearchProducts)
            } else if let snippet = item.snippet {
                VStack(alignment: .leading) {
                    WebResultHeader(item: item)

                    Text(snippet)
                        .font(.system(size: 13))
                        .foregroundColor(
                            Color(light: Color.ui.gray40, dark: Color(hex: 0xd0dada))
                        )
                        .lineLimit(3)
                        .multilineTextAlignment(.leading)
                }
                .onTapGesture(perform: onClick)
                .accessibilityAddTraits(.isButton)
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
    let currentCheatsheetQuery: String?
    @Environment(\.onOpenURL) var onOpenURL

    var body: some View {
        VStack(alignment: .leading) {
            Button(action: onClick) {
                HStack(alignment: .center) {
                    Text("Neeva Search")
                        .withFont(.headingXLarge)
                        .foregroundColor(.label)
                    Symbol(decorative: .arrowUpForward)
                        .foregroundColor(.label)
                        .frame(width: 18, height: 18, alignment: .center)
                }
                .padding(.bottom, 8)
            }
            VStack(alignment: .leading) {
                ForEach(webResult, id: \.actionURL) { web in
                    WebResultItem(item: web)
                }
            }
        }
        .padding(.bottom, 18)
    }

    func onClick() {
        if let query = currentCheatsheetQuery {
            if let encodedQuery = query.addingPercentEncoding(
                withAllowedCharacters: .urlQueryAllowed), !encodedQuery.isEmpty
            {
                if let url = URL(string: "\(NeevaConstants.appSearchURL)?q=\(encodedQuery)") {
                    onOpenURL(url)
                }
            }
        }
    }
}
