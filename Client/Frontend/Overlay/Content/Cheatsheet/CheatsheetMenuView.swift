// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

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
    let onDismiss: (() -> Void)?

    @Environment(\.onOpenURL) var onOpenURL

    var body: some View {
        Button(action: onClick) {
            ScrollView(.horizontal) {
                HStack(alignment: .center) {
                    Label {
                        Text(query)
                            .foregroundColor(.label)
                    } icon: {
                        Symbol(decorative: .magnifyingglass)
                            .foregroundColor(.tertiaryLabel)
                    }
                }
            }
        }
        .withFont(unkerned: .bodyLarge)
        .lineLimit(1)
        .padding(.bottom, 8)
    }

    func onClick() {
        if let onDismiss = onDismiss {
            onDismiss()
        }

        if let encodedQuery = query.addingPercentEncoding(
            withAllowedCharacters: .urlQueryAllowed), !encodedQuery.isEmpty
        {
            ClientLogger.shared.logCounter(
                .RelatedSearchClick, attributes: EnvironmentHelper.shared.getAttributes())
            let target = URL(string: "\(NeevaConstants.appSearchURL)?q=\(encodedQuery)")!
            onOpenURL(target)
        }
    }
}

struct CheatsheetNoResultView: View {
    var body: some View {
        VStack(alignment: .center) {
            Text("Sorry, we couldn't find any results related to your search")
                .withFont(.headingLarge)
                .foregroundColor(.label)
                .fixedSize(horizontal: false, vertical: true)
                .layoutPriority(1)
            Text("If this persists, let us know what happened, and we'll fix it soon.")
                .withFont(.bodyLarge)
                .foregroundColor(.secondaryLabel)
            Image("question-mark", bundle: .main)
                .resizable()
                .scaledToFit()
                .frame(minHeight: 115, maxHeight: 300)
                .accessibilityHidden(true)
                .padding(.bottom)
        }
        .multilineTextAlignment(.center)
        .padding(.top, 10)
        .padding(.horizontal, 27)
    }
}

public struct CheatsheetMenuView: View {
    @State var height: CGFloat = 0
    @EnvironmentObject private var model: CheatsheetMenuViewModel
    private let menuAction: (NeevaMenuAction) -> Void

    init(menuAction: @escaping (NeevaMenuAction) -> Void) {
        self.menuAction = menuAction
    }

    public var body: some View {
        GeometryReader { geom in
            if model.currentPageURL?.origin == NeevaConstants.appURL.origin {
                VStack(alignment: .center) {
                    VStack(alignment: .leading) {
                        Text("What is Neeva Cheatsheet?").withFont(.headingXLarge).padding(
                            .top, 32)
                        Text(
                            "Cheatsheet will show you information about the website you're visiting."
                        )
                        .withFont(.bodyLarge)
                        .foregroundColor(.secondaryLabel)
                        Text(
                            "Try it by visiting a website outside of Neeva and tap this Neeva logo again!"
                        )
                        .withFont(.bodyLarge)
                        .foregroundColor(.secondaryLabel)
                    }
                    .padding(.horizontal, 32)
                    .fixedSize(horizontal: false, vertical: true)
                    Image("notification-prompt", bundle: .main)
                        .resizable()
                        .frame(width: 160, height: 140)
                        .padding(24)
                }
            } else if model.cheatsheetDataLoading {
                VStack(alignment: .center) {
                    LoadingView("something good on it's way")
                }
            } else if model.cheatSheetIsEmpty {
                CheatsheetNoResultView()
            } else {
                VStack(alignment: .leading) {
                    recipeView
                        .padding()
                    if let richResults = model.searchRichResults {
                        VStack(alignment: .leading) {
                            ForEach(richResults) { richResult in
                                renderRichResult(for: richResult)
                            }
                        }
                        .padding()

                    }
                    priceHistorySection
                    reviewURLSection
                    memorizedQuerySection
                }
                .frame(width: geom.size.width)
                .onHeightOfViewChanged { height in
                    self.height = height
                }
            }
        }.frame(minHeight: height < 200 ? 200 : height)
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
                        currentURL: nil,
                        tabUUID: nil
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

    func renderRichResult(for richResult: SearchController.RichResult) -> AnyView {
        switch richResult.resultType {
        case .ProductCluster(let productCluster):
            return AnyView(
                ProductClusterList(
                    products: productCluster, currentURL: model.currentPageURL?.absoluteString ?? ""
                ))
        case .RecipeBlock(let recipes):
            // filter out result already showing on the current page
            return AnyView(
                RelatedRecipeList(
                    recipes: recipes.filter { $0.url != model.currentPageURL },
                    onDismiss: nil
                )
                .padding(.bottom, 20)
            )
        case .RelatedSearches(let relatedSearches):
            return AnyView(RelatedSearchesView(relatedSearches: relatedSearches, onDismiss: nil))
        case .WebGroup(let result):
            // filter out result already showing on the current page
            return AnyView(
                WebResultList(
                    webResult: result.filter { $0.actionURL != model.currentPageURL },
                    currentCheatsheetQuery: model.currentCheatsheetQuery
                ))
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
                Text("Keep Looking").withFont(.headingXLarge)
                ForEach(model.cheatsheetInfo?.memorizedQuery?.prefix(5) ?? [], id: \.self) {
                    query in
                    QueryButton(query: query, onDismiss: nil)
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
