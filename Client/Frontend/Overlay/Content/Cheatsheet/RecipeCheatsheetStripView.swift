// Copyright Neeva. All rights reserved.

import SDWebImageSwiftUI
import Shared
import SwiftUI

struct RecipeCheatsheetStripView: View {
    @Environment(\.onOpenURL) var onOpenURL
    let tabManager: TabManager
    let overlayModel: OverlaySheetModel = OverlaySheetModel()
    var height: CGFloat
    @ObservedObject var scrollingController: TabScrollingController
    @ObservedObject var recipeModel: RecipeViewModel
    @State private var presentSheet: Bool = false
    let chromeModel: TabChromeModel
    @State private var richResults: [SearchController.RichResult]?

    init(
        tabManager: TabManager,
        recipeModel: RecipeViewModel,
        scrollingController: TabScrollingController,
        height: CGFloat,
        chromeModel: TabChromeModel
    ) {
        self.tabManager = tabManager
        self.recipeModel = recipeModel
        self.scrollingController = scrollingController
        self.recipeModel = recipeModel
        self.height = height
        self.chromeModel = chromeModel
    }

    var body: some View {
        if !recipeModel.recipe.title.isEmpty && onAllowedDomain() {
            if presentSheet {
                recipeView
            } else {
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
                    y: -height * scrollingController.headerTopOffset
                        / scrollingController.headerHeight
                )
                .animation(.easeInOut)
                .onAppear(perform: logBannerImpression)
            }
        }
    }

    @ViewBuilder
    var recipeView: some View {
        if let ingredients = recipeModel.recipe.ingredients,
            let instructions = recipeModel.recipe.instructions
        {
            if ingredients.count > 0 && instructions.count > 0 {
                OverlaySheetView(
                    model: overlayModel,
                    style: .spaces,
                    onDismiss: {
                        presentSheet = false
                        self.chromeModel.toolBarContentView = .regularContent
                    },
                    headerButton: nil
                ) {
                    ScrollView(.vertical, showsIndicators: false) {
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
                        presentSheet = false
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
                        presentSheet = false
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
        presentSheet = true
        self.chromeModel.toolBarContentView = .recipeContent
        overlayModel.show(defaultPosition: .top)
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
            if let host = url.host, let baseDomain = url.baseDomain {
                return DomainAllowList.recipeDomains[host] ?? false
                    || DomainAllowList.recipeDomains[baseDomain] ?? false
            }
        }
        return false
    }
}
