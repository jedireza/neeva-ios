// Copyright Neeva. All rights reserved.

import SDWebImageSwiftUI
import Shared
import SwiftUI

struct RelatedRecipeItem: View {
    let recipe: RelatedRecipe
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
                    .frame(width: 140, height: 140, alignment: .center)
                    .clipped()
                    .cornerRadius(16)
                Text(recipe.title)
                    .withFont(.headingSmall)
                    .foregroundColor(Color.label)
                    .lineLimit(3)
                    .multilineTextAlignment(.leading)
                    .padding(.horizontal, 6)
                Spacer()
                if let baseDomain = recipe.url.baseDomain {
                    Text(baseDomain)
                        .withFont(.bodySmall)
                        .lineLimit(1)
                        .foregroundColor(Color.secondaryLabel)
                        .padding(.horizontal, 6)
                }
            }
            .frame(width: 140, height: 220)

        }
    }

    func onClick() {
        onOpenURL(recipe.url)
    }
}

struct RelatedRecipeList: View {
    let recipes: [RelatedRecipe]

    var body: some View {
        VStack(alignment: .leading) {
            Text("Related Recipes")
                .withFont(.headingXLarge)
                .foregroundColor(Color.label)
                .padding(.bottom, 8)
            ScrollView(.horizontal) {
                HStack {
                    ForEach(recipes, id: \.url) { recipe in
                        RelatedRecipeItem(recipe: recipe)
                    }
                }
            }
        }
        .padding()
    }
}
