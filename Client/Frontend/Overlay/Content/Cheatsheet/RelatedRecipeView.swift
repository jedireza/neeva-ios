// Copyright Neeva. All rights reserved.

import SDWebImageSwiftUI
import Shared
import SwiftUI

struct RelatedRecipeItem: View {
    let recipe: RelatedRecipe
    let onDismiss: (() -> Void)?
    @Environment(\.onOpenURL) var onOpenURL

    var body: some View {
        Button(action: onClick) {
            VStack(alignment: .leading) {
                WebImage(url: URL(string: recipe.imageURL))
                    .placeholder {
                        Rectangle().foregroundColor(.gray)
                    }
                    .resizable()
                    .scaledToFill()
                    .frame(width: 175, height: 100, alignment: .center)
                    .clipped()
                    .cornerRadius(11, corners:[.topLeft, .topRight])
                Text(recipe.title)
                    .withFont(.headingMedium)
                    .foregroundColor(Color.label)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                    .padding(.horizontal, 12)
                HStack(alignment: .center) {
                    if let recipeRating = recipe.recipeRating {
                        if recipeRating.recipeStars > 0 {
                            Image(systemSymbol: .starFill)
                                .renderingMode(.template)
                                .foregroundColor(Color.brand.orange)
                                .font(.system(size: 12))
                                .padding(.trailing, -5)
                                .padding(.bottom, 2)
                            Text(String(round(recipeRating.recipeStars * 10) / 10.0))
                            if let numReviews = recipeRating.numReviews {
                                if numReviews > 0 {
                                    Text("(\(String(numReviews)))")
                                        .padding(.leading, -3)
                                }
                            }
                            if let _ = recipe.totalTime {
                                Text("·")
                                    .padding(.horizontal, -1)
                            }
                        }
                    }
                    if let totalTime = recipe.totalTime {
                        Text(String(totalTime))
                            .lineLimit(1)
                    }
                }
                .padding(.horizontal, 12)
                .withFont(unkerned: .bodyMedium)
                .foregroundColor(Color.ui.gray30)
                Spacer()
                if let baseDomain = recipe.url.baseDomain {
                    HStack(alignment: .center) {
                        FaviconView(forSiteUrl: recipe.url)
                            .frame(width: 16, height: 16)
                            .clipShape(Circle())
                        Text(ProviderList.shared.getDisplayName(for: baseDomain))
                            .withFont(.bodySmall)
                            .lineLimit(1)
                            .foregroundColor(Color.label)
                    }
                    .padding(.horizontal, 12)
                }
            }
            .padding(.bottom, 10)
            .frame(width: 175, height: 240)
            .overlay(
                RoundedRectangle(cornerRadius: 11)
                    .stroke(Color.ui.gray91, lineWidth: 1)
            )

        }
    }

    func onClick() {
        if let onDismiss = onDismiss {
            onDismiss()
        }
        onOpenURL(recipe.url)
    }
}

struct RelatedRecipeList: View {
    let recipes: [RelatedRecipe]
    let onDismiss: (() -> Void)?

    var body: some View {
        VStack(alignment: .leading) {
            Text("Related Recipes")
                .withFont(.headingXLarge)
                .foregroundColor(Color.label)
                .padding(.bottom, 8)
            ScrollView(.horizontal) {
                HStack {
                    ForEach(recipes, id: \.url) { recipe in
                        RelatedRecipeItem(recipe: recipe, onDismiss: onDismiss)
                    }
                }
            }
        }
    }
}
