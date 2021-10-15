// Copyright Neeva. All rights reserved.

import Combine
import Shared
import SwiftUI

struct ReviewURLButton: View {
    let url: URL
    @Environment(\.onOpenURL) var onOpenURL

    var body: some View {
        Button(action: { onOpenURL(url) }) {
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
    @Environment(\.onOpenURL) var onOpenURL

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
            onOpenURL(target)
        }
    }
}

public class CheatsheetMenuViewModel: ObservableObject {
    @Published var cheatsheetInfo: CheatsheetQueryController.CheatsheetInfo?
    @Published var searchRichResults: [SearchController.RichResult]?
    @Published var currentPageURL: URL?

    private var subscriptions: Set<AnyCancellable> = []

    init(tabManager: TabManager) {
        self.cheatsheetInfo = tabManager.selectedTab?.cheatsheetData
        self.searchRichResults = tabManager.selectedTab?.searchRichResults
        self.currentPageURL = tabManager.selectedTab?.webView?.url

        tabManager.selectedTabPublisher
            .compactMap { $0?.cheatsheetData }
            .assign(to: \.cheatsheetInfo, on: self)
            .store(in: &subscriptions)

        tabManager.selectedTabPublisher
            .compactMap { $0?.searchRichResults }
            .assign(to: \.searchRichResults, on: self)
            .store(in: &subscriptions)

        tabManager.selectedTabPublisher
            .compactMap { $0?.webView?.url }
            .assign(to: \.currentPageURL, on: self)
            .store(in: &subscriptions)
    }
}

public struct CheatsheetMenuView: View {
    @EnvironmentObject private var model: CheatsheetMenuViewModel
    private let menuAction: (NeevaMenuAction) -> Void

    init(menuAction: @escaping (NeevaMenuAction) -> Void) {
        self.menuAction = menuAction
    }

    public var body: some View {
        GeometryReader { geom in
            ScrollView(.vertical) {
                VStack(alignment: .leading) {
                    CompactNeevaMenuView(menuAction: menuAction)
                    recipeView
                        .padding()
                    richResult()
                    priceHistorySection
                    reviewURLSection
                    memorizedQuerySection
                }.frame(width: geom.size.width)
            }
            .frame(minHeight: 200)
        }
    }

    @ViewBuilder
    var recipeView: some View {
        if let recipe = model.cheatsheetInfo?.recipe {
            if let ingredients = recipe.ingredients, let instructions = recipe.instructions {
                if ingredients.count > 0 && instructions.count > 0 {
                    RecipeView(
                        title: recipe.title,
                        imageURL: recipe.imageURL,
                        totalTime: recipe.totalTime,
                        prepTime: recipe.prepTime,
                        ingredients: ingredients,
                        instructions: instructions,
                        yield: recipe.yield,
                        recipeRating: RecipeRating(
                            maxStars: recipe.recipeRating?.maxStars ?? 0,
                            recipeStars: recipe.recipeRating?.recipeStars ?? 0,
                            numReviews: recipe.recipeRating?.numReviews ?? 0),
                        reviews: constructReviewList(recipe: recipe),
                        faviconURL: nil,
                        currentURL: nil
                    )
                }
            }
        }
    }

    func constructReviewList(recipe: Recipe) -> [Review] {
        guard let reviewList = recipe.reviews else { return [] }
        return reviewList.map { item in
            Review(
                body: item.body,
                reviewerName: item.reviewerName,
                rating: Rating(
                    maxStars: item.rating.maxStars,
                    actualStarts: item.rating.actualStarts
                )
            )
        }
    }

    func richResult() -> AnyView {
        if let richResults = model.searchRichResults {
            for richResult in richResults {
                switch richResult.resultType {
                case .ProductCluster(let productCluster):
                    return AnyView(ProductClusterList(products: productCluster))
                }
            }
        }
        return AnyView(EmptyView())
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
                ForEach(model.cheatsheetInfo?.memorizedQuery?.prefix(5) ?? [], id: \.self) {
                    query in
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
