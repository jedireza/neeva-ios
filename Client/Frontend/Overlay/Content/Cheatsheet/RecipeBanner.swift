// Copyright Neeva. All rights reserved.

import SDWebImageSwiftUI
import Shared
import SwiftUI

struct RecipeBanner: View {
    var recipe: Recipe

    var body: some View {
        HStack(alignment: .center) {
            if let imageURL = URL(string: recipe.imageURL) {
                WebImage(url: imageURL)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 42, height: 42)
                    .clipped()
                    .cornerRadius(6)
            }
            VStack(alignment: .leading, spacing: 0) {
                Text(recipe.title)
                    .withFont(.headingSmall)
                    .foregroundColor(Color.label)
                    .lineLimit(1)
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
                        }
                    }
                    if let totalTime = recipe.totalTime {
                        Text("·")
                            .padding(.horizontal, -1)
                        Text(String(totalTime))
                    }
                }
                .withFont(unkerned: .bodySmall)
                .foregroundColor(Color.secondaryLabel)
            }
        }
    }
}
