// Copyright Neeva. All rights reserved.

import SDWebImageSwiftUI
import Shared
import SwiftUI

struct RecipeCheatsheetStripView: View {
    let tabManager: TabManager
    @ObservedObject var scrollingController: TabScrollingController
    @ObservedObject var recipeModel: RecipeViewModel
    let overlayModel: OverlaySheetModel = OverlaySheetModel()
    var height: CGFloat
    @State private var presentSheet: Bool = false

    init(
        tabManager: TabManager,
        recipeModel: RecipeViewModel,
        scrollingController: TabScrollingController,
        height: CGFloat
    ) {
        self.tabManager = tabManager
        self.recipeModel = recipeModel
        self.scrollingController = scrollingController
        self.recipeModel = recipeModel
        self.height = height
    }

    var body: some View {
        if !recipeModel.recipe.title.isEmpty {
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
                    onDismiss: { presentSheet = false }
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
                            currentURL: self.tabManager.selectedTab?.url
                        )
                    }
                    .padding()
                    .background(Color.DefaultBackground)
                }
            }
        }
    }

    func showOverlaySheet() {
        presentSheet = true
        overlayModel.show()
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
}
