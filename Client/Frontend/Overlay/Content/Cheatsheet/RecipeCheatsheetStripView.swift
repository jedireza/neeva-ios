// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import SDWebImageSwiftUI
import Shared
import SwiftUI

struct RecipeCheatsheetStripView: View {
    @Environment(\.onOpenURL) var onOpenURL
    let tabManager: TabManager
    let overlayManager: OverlayManager
    var height: CGFloat
    var yOffset: CGFloat
    @ObservedObject var recipeModel: RecipeViewModel
    let chromeModel: TabChromeModel
    @State private var richResults: [SearchController.RichResult]?

    init(
        tabManager: TabManager,
        recipeModel: RecipeViewModel,
        yOffset: CGFloat,
        height: CGFloat,
        chromeModel: TabChromeModel,
        overlayManager: OverlayManager
    ) {
        self.tabManager = tabManager
        self.recipeModel = recipeModel
        self.yOffset = yOffset
        self.recipeModel = recipeModel
        self.height = height
        self.chromeModel = chromeModel
        self.overlayManager = overlayManager
    }

    var body: some View {
        if !recipeModel.recipe.title.isEmpty && onAllowedDomain() {
            Button(action: showOverlaySheet) {
                RecipeBanner(recipe: recipeModel.recipe)
                Spacer()
                Symbol(decorative: .chevronUp)
                    .foregroundColor(Color.label)
                    .padding(.trailing, 8)
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 12)
            .background(Color.DefaultBackground)
            .cornerRadius(10)
            .shadow(radius: 4)
            .padding(.bottom, 8)
            .padding(.horizontal, 18)
            .offset(
                x: 0,
                y: -height * yOffset
            )
            .animation(.easeInOut)
            .onAppear(perform: logBannerImpression)
        }
    }

    @ViewBuilder
    var recipeView: some View {
        if let ingredients = recipeModel.recipe.ingredients,
            let instructions = recipeModel.recipe.instructions
        {
            if ingredients.count > 0 && instructions.count > 0 {
                LazyVStack {
                    RecipeView(
                        title: recipeModel.recipe.title,
                        imageURL: recipeModel.recipe.imageURL,
                        totalTime: recipeModel.recipe.totalTime,
                        prepTime: recipeModel.recipe.prepTime,
                        ingredients: ingredients,
                        instructions: instructions,
                        yield: recipeModel.recipe.yield,
                        recipeRating: RecipeRating(
                            maxStars: recipeModel.recipe.recipeRating?.maxStars ?? 0,
                            recipeStars: recipeModel.recipe.recipeRating?.recipeStars ?? 0,
                            numReviews: recipeModel.recipe.recipeRating?.numReviews ?? 0),
                        reviews: constructReviewList(recipe: recipeModel.recipe),
                        faviconURL: self.tabManager.selectedTab?.favicon?.url,
                        currentURL: self.tabManager.selectedTab?.url,
                        tabUUID: self.tabManager.selectedTab?.tabUUID
                    )
                    .padding(.bottom, 20)

                    if let richResults = self.richResults {
                        VStack(alignment: .leading) {
                            ForEach(richResults) { richResult in
                                renderRichResult(for: richResult)
                            }
                        }
                    }
                }
                .padding()
                .background(Color.DefaultBackground)
                .environment(\.onOpenURL, self.onOpenURL)
                .onAppear(perform: loadRelatedContent)
                .onDisappear(perform: resetRelatedContent)
            }
        }
    }

    func loadRelatedContent() {
        if let relatedQuery = recipeModel.relatedQuery {
            SearchController.getRichResult(query: relatedQuery) { searchResult in
                switch searchResult {
                case .success(let richResult):
                    self.richResults = richResult
                case .failure:
                    break
                }
            }
        }
    }

    func resetRelatedContent() {
        self.richResults = nil
    }

    func renderRichResult(for richResult: SearchController.RichResult) -> AnyView {
        switch richResult.resultType {
        case .RecipeBlock(let recipes):
            return AnyView(
                RelatedRecipeList(
                    recipes: recipes.filter { $0.url != self.tabManager.selectedTab?.url ?? "" },
                    onDismiss: {
                        self.chromeModel.toolBarContentView = .regularContent
                    }
                )
                .padding(.bottom, 30)
            )
        case .RelatedSearches(let relatedSearches):
            return AnyView(
                RelatedSearchesView(
                    relatedSearches: relatedSearches,
                    onDismiss: {
                        self.chromeModel.toolBarContentView = .regularContent
                    }
                )
                .padding(.bottom, 30)
            )
        default:
            return AnyView(EmptyView())
        }
    }

    func showOverlaySheet() {
        if let tabUUID = tabManager.selectedTab?.tabUUID,
            let url = tabManager.selectedTab?.url?.absoluteString
        {
            RecipeCheatsheetLogManager.shared.logInteraction(
                logType: .clickRecipeBanner, tabUUIDAndURL: tabUUID + url)
        }

        self.chromeModel.currentCheatsheetFaviconURL = self.tabManager.selectedTab?.favicon?.url
        self.chromeModel.toolBarContentView = .recipeContent

        overlayManager.show(
            overlay: .sheet(
                OverlaySheetRootView(
                    overlayPosition: .top,
                    style: .spaces,
                    content: {
                        AnyView(erasing: recipeView)
                    },
                    onDismiss: {
                        self.chromeModel.toolBarContentView = .regularContent
                        overlayManager.hideCurrentOverlay()
                    }, onOpenURL: { _ in }, headerButton: nil)))
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

    func logBannerImpression() {
        if let tabUUID = tabManager.selectedTab?.tabUUID,
            let url = tabManager.selectedTab?.url?.absoluteString
        {
            RecipeCheatsheetLogManager.shared.logInteraction(
                logType: .impression, tabUUIDAndURL: tabUUID + url)
        }
    }

    func onAllowedDomain() -> Bool {
        if let url = self.tabManager.selectedTab?.url {
            return RecipeViewModel.isRecipeAllowed(url: url)
        } else {
            return false
        }
    }
}
