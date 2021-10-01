// Copyright Neeva. All rights reserved.

import SDWebImageSwiftUI
import Shared
import SwiftUI

struct RecipeView: View {
    @Environment(\.colorScheme) var colorScheme

    let title: String?
    let imageURL: String?
    let totalTime: String?
    let prepTime: String?
    let ingredients: [String]?
    let instructions: [String]?
    let yield: String?
    let recipeRating: RecipeRating?
    let reviews: [Review]?

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            if let title = title {
                Text(title)
                    .withFont(.displayMedium)
            }
            if let imageURL = imageURL {
                WebImage(url: URL(string: imageURL))
                    .resizable()
                    .scaledToFill()
                    .frame(height: 80)
                    .clipped()
                    .cornerRadius(10)
            }
            if let recipeRating = recipeRating {
                if recipeRating.recipeStars > 0 {
                    HStack {
                        Image(systemSymbol: .starFill)
                            .renderingMode(.template)
                            .foregroundColor(.yellow)
                        Text(String(recipeRating.recipeStars))
                            .withFont(.headingMedium)

                        if let numReviews = recipeRating.numReviews {
                            if numReviews > 0 {
                                Text("(\(String(numReviews)))")
                            }
                        }
                    }
                    .font(.system(size: 14))
                    .foregroundColor(colorScheme == .dark ? Color.white : Color.ui.gray20)
                }
            }
            Group {
                if let totalTime = totalTime {
                    ScrollView(.horizontal) {
                        HStack(alignment: .center) {
                            Image(systemSymbol: .clock)
                            Text("\(totalTime) (Total Time)")
                            if let prepTime = prepTime {
                                Text(", \(prepTime) (Prep Time)")
                            }
                        }
                        .withFont(unkerned: .bodyMedium)
                    }
                }
                if let yield = yield {
                    HStack(alignment: .center) {
                        Image(systemSymbol: .person2)
                        Text("Makes \(yield)")
                            .withFont(.bodyMedium)
                    }
                }
                Divider()
                if let ingredients = ingredients {
                    Text("Ingredients")
                        .withFont(.headingMedium)
                    ForEach(ingredients, id: \.self) {
                        Text($0)
                            .withFont(.bodyMedium)
                    }
                }
                Divider()
                if let instructions = instructions {
                    Text("Instructions")
                        .withFont(.headingMedium)
                    ForEach(instructions.indices) { i in
                        Text("\(i+1). ").font(.system(size: 14)).bold()
                            + Text("\(instructions[i])").font(.system(size: 14))
                    }
                }
            }
            .foregroundColor(colorScheme == .dark ? Color.white : Color.ui.gray20)
        }
        .padding(20)
        .background(Color.DefaultBackground)
        .cornerRadius(10)
        .padding()
    }
}
