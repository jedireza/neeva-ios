// Copyright Neeva. All rights reserved.

import Combine
import Shared
import SwiftUI

struct ReviewURLButton: View {
    let url: URL
    @Environment(\.openInNewTab) var openInNewTab
    @Environment(\.isIncognito) private var isIncognito

    var body: some View {
        Button(action: { openInNewTab(url, isIncognito) }) {
            getHostName()
        }
    }

    @ViewBuilder
    func getHostName() -> some View {
        let host = url.baseDomain?.replacingOccurrences(of: ".com", with: "")
        let lastPath = url.lastPathComponent
            .replacingOccurrences(of: ".html", with: "")
            .replacingOccurrences(of: "-", with: " ")
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
    @Environment(\.openInNewTab) var openInNewTab
    @Environment(\.isIncognito) private var isIncognito

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
            openInNewTab(target, isIncognito)
        }
    }
}

class CheatsheetMenuViewModel: ObservableObject {
    @Published var cheatsheetInfo: CheatsheetQueryController.CheatsheetInfo?
    private var subscriptions: Set<AnyCancellable> = []

    init(tabManager: TabManager) {
        self.cheatsheetInfo = tabManager.selectedTab?.cheatsheetData
        tabManager.selectedTabPublisher
            .compactMap { $0?.cheatsheetData }
            .assign(to: \.cheatsheetInfo, on: self)
            .store(in: &subscriptions)
    }
}

public struct CheatsheetMenuView: View {
    @EnvironmentObject private var model: CheatsheetMenuViewModel
    private let menuAction: (NeevaMenuAction) -> Void
    @Environment(\.isIncognito) private var isIncognito

    init(menuAction: @escaping (NeevaMenuAction) -> Void) {
        self.menuAction = menuAction
    }

    public var body: some View {
        GeometryReader { geom in
            ScrollView(.vertical) {
                VStack(alignment: .leading) {
                    CompactNeevaMenuView(menuAction: menuAction, isIncognito: isIncognito)
                    priceHistorySection
                    reviewURLSection
                    memorizedQuerySection
                }.frame(width: geom.size.width)
            }
            .frame(minHeight: 200)
        }
    }

    @ViewBuilder
    var reviewURLSection: some View {
        if model.cheatsheetInfo?.reviewURL?.count ?? 0 > 0 {
            VStack(alignment: .leading, spacing: 20) {
                Text("Buying Guide").withFont(.headingMedium)
                ForEach(model.cheatsheetInfo?.reviewURL ?? [], id: \.self) { review in
                    if let url = URL(string: review) {
                        ReviewURLButton(url: url)
                    }
                }
            }
            .padding()
        }
    }

    @ViewBuilder
    var memorizedQuerySection: some View {
        if model.cheatsheetInfo?.memorizedQuery?.count ?? 0 > 0 {
            VStack(alignment: .leading, spacing: 10) {
                Text("Keep Looking").withFont(.headingMedium)
                ForEach(model.cheatsheetInfo?.memorizedQuery ?? [], id: \.self) { query in
                    QueryButton(query: query)
                }
            }
            .padding()
        }
    }

    @ViewBuilder
    var priceHistorySection: some View {
        if let priceHistory = model.cheatsheetInfo?.priceHistory,
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
        CheatsheetMenuView(menuAction: { _ in })
    }
}
