// Copyright Neeva. All rights reserved.

import Shared
import SwiftUI

struct ReviewURLButton: View {
    let url: URL
    let openInNewTab: (URL) -> Void

    var body: some View {
        Button(action: { openInNewTab(url) }) {
            getHostName()
        }
    }

    @ViewBuilder
    func getHostName() -> some View {
        let host = url.baseDomain?.replacingOccurrences(of: ".com", with: "")
        let lastPath = url.lastPathComponent.replacingOccurrences(of: ".html", with: "")
        if host != nil {
            HStack {
                Text(host!).bold()
                if !lastPath.isEmpty {
                    Text("(")
                        + Text(lastPath)
                        + Text(")")
                }
            }
            .withFont(unkerned: .bodyMedium)
            .lineLimit(1)
            .background(
                RoundedRectangle(cornerRadius: 10).stroke(Color.gray, lineWidth: 1).padding(-6)
            )
            .padding(6)
            .foregroundColor(.secondaryLabel)
        }
    }
}

struct QueryButton: View {
    let query: String

    var body: some View {
        Button(action: onClick) {
            Label(query, systemSymbol: .magnifyingglass)
        }
        .withFont(unkerned: .bodyMedium)
        .lineLimit(1)
        .background(
            RoundedRectangle(cornerRadius: 20).stroke(Color.gray, lineWidth: 1).padding(-10)
        )
        .padding(10)
        .foregroundColor(.secondaryLabel)
    }

    func onClick() {
        if let encodedQuery = query.addingPercentEncoding(
            withAllowedCharacters: .urlQueryAllowed), !encodedQuery.isEmpty
        {
            let target = URL(string: "\(NeevaConstants.appSearchURL)?q=\(encodedQuery)")!
            SceneDelegate.getBVC(for: nil).openURLInNewTab(target)
        }
    }
}

struct CheatsheetMenuView: View {
    let openInNewTab: (URL) -> Void
    @ObservedObject var cheatsheetInfo = CheatsheetInfo.shared

    var body: some View {
        GeometryReader { geom in
            ScrollView(.vertical) {
                VStack(alignment: .leading) {
                    priceHistorySection
                    reviewURLSection
                    memorizedQuerySection
                    if cheatsheetInfo.currentURL != nil {
                        VStack(alignment: .leading) {
                            Text("Cheatsheet for URL: ").bold()
                            Text(cheatsheetInfo.currentURL!)
                                .multilineTextAlignment(.leading)
                                .lineLimit(2)
                        }
                        .withFont(unkerned: .bodyXSmall)
                        .padding()
                    }
                }.frame(width: geom.size.width)
            }
            .frame(minHeight: 200)
        }
    }

    @ViewBuilder
    var reviewURLSection: some View {
        if cheatsheetInfo.cheatsheetData?.reviewURL?.count ?? 0 > 0 {
            VStack(alignment: .leading, spacing: 20) {
                Text("Buying Guide").withFont(.headingMedium)
                ForEach(cheatsheetInfo.cheatsheetData?.reviewURL ?? [], id: \.self) { review in
                    if let url = URL(string: review) {
                        ReviewURLButton(url: url, openInNewTab: openInNewTab)
                    }
                }
            }
            .padding()
        }
    }

    @ViewBuilder
    var memorizedQuerySection: some View {
        if cheatsheetInfo.cheatsheetData?.memorizedQuery?.count ?? 0 > 0 {
            VStack(alignment: .leading, spacing: 10) {
                Text("Keep Looking").withFont(.headingMedium)
                ForEach(cheatsheetInfo.cheatsheetData?.memorizedQuery ?? [], id: \.self) { query in
                    QueryButton(query: query)
                }
            }
            .padding()
        }
    }

    @ViewBuilder
    var priceHistorySection: some View {
        if let priceHistory = cheatsheetInfo.cheatsheetData?.priceHistory,
            !priceHistory.Max.Price.isEmpty || !priceHistory.Min.Price.isEmpty
        {
            VStack(alignment: .leading, spacing: 10) {
                Text("Price History").withFont(.headingMedium)
                if let max = priceHistory.Max,
                    !max.Price.isEmpty
                {
                    HStack {
                        Text("Highest: ").bold()
                        Text("$")
                            + Text(max.Price)

                        if !max.Date.isEmpty {
                            Text("(")
                                + Text(max.Date)
                                + Text(")")
                        }
                    }
                    .foregroundColor(.hex(0xCC3300))
                    .withFont(unkerned: .bodyMedium)
                }

                if let min = priceHistory.Min,
                    !min.Price.isEmpty
                {
                    HStack {
                        Text("Lowest: ").bold()
                        Text("$")
                            + Text(min.Price)

                        if !min.Date.isEmpty {
                            Text("(")
                                + Text(min.Date)
                                + Text(")")
                        }
                    }
                    .foregroundColor(.hex(0x008800))
                    .withFont(unkerned: .bodyMedium)
                }

                if let average = priceHistory.Average,
                    !average.Price.isEmpty
                {
                    HStack {
                        Text("Average: ").bold()
                        Text("$")
                            + Text(average.Price)
                    }
                    .foregroundColor(.hex(0x555555))
                    .withFont(unkerned: .bodyMedium)
                }
            }
            .padding()
        }
    }
}

struct CheatsheetMenuView_Previews: PreviewProvider {
    static var previews: some View {
        CheatsheetMenuView(openInNewTab: { _ in })
    }
}
