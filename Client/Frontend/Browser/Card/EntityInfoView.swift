// Copyright Neeva. All rights reserved.

import Shared
import Storage
import SwiftUI

struct EntityInfoView: View {
    let url: URL
    let entity: PreviewEntity

    var body: some View {
        switch entity {
        case .newsItem(let newsItem):
            NewsInfoView(newsItem: newsItem)
        case .retailProduct(let product):
            ProductInfoView(product: product)
        case .richEntity(let _):
            EmptyView()
        case .recipe(let recipe):
            RecipeInfoView(recipe: recipe)
        case .techDoc(let _):
            URLDisplayView(url: url)
        case .webPage:
            URLDisplayView(url: url)
        }
    }
}

struct ProductInfoView: View {
    let product: RetailProduct

    var body: some View {
        HStack {
            Text(product.formattedPrice)
                .withFont(.headingSmall)
                .foregroundColor(.label)
            if let productStars = product.ratingSummary?.productStars {
                Image(systemSymbol: .starFill)
                    .renderingMode(.template)
                    .foregroundColor(Color.brand.red)
                    .font(.system(size: 12))
                    .padding(.trailing, -5)
                    .padding(.bottom, 2)
                Text("\(round(productStars * 10) / 10.0)/5")
                    .withFont(.bodyMedium)
                    .foregroundColor(.label)
            }
            if let numReviews = product.ratingSummary?.numReviews {
                if numReviews > 0 {
                    Text("(\(numReviews))")
                        .withFont(.bodyMedium)
                        .foregroundColor(.label)
                        .padding(.leading, -3)
                }
            }
        }
    }
}

struct NewsInfoView: View {
    let newsItem: NewsItem

    var body: some View {
        HStack(spacing: 4) {
            if let favicon = newsItem.faviconURL {
                FaviconView(forFavicon: Favicon(url: favicon))
                    .frame(width: 12, height: 12)
                    .cornerRadius(4)
            }
            Text(newsItem.providerName)
                .withFont(.bodySmall)
                .foregroundColor(.label)
        }
    }
}

struct RecipeInfoView: View {
    let recipe: Recipe

    var body: some View {
        HStack(alignment: .center) {
            if let recipeRating = recipe.recipeRating {
                if recipeRating.recipeStars > 0 {
                    Image(systemSymbol: .starFill)
                        .renderingMode(.template)
                        .foregroundColor(Color.brand.orange)
                        .withFont(unkerned: .bodySmall)
                        .padding(.trailing, -5)
                        .padding(.bottom, 2)
                    Text("\(round(recipeRating.recipeStars * 10) / 10.0)")
                        .withFont(.bodySmall)
                        .foregroundColor(.label)
                    if let numReviews = recipeRating.numReviews {
                        if numReviews > 0 {
                            Text("\(numReviews)")
                                .withFont(.bodySmall)
                                .foregroundColor(.label)
                                .padding(.leading, -3)
                        }
                    }

                    if let _ = recipe.totalTime {
                        Text("·")
                            .withFont(.bodySmall)
                            .foregroundColor(.secondaryLabel)
                            .padding(.horizontal, -1)
                    }
                }
            }
            if let totalTime = recipe.totalTime {
                Text(totalTime)
                    .withFont(.bodySmall)
                    .foregroundColor(.label)
            }
        }
        .withFont(unkerned: .bodySmall)
        .foregroundColor(Color.secondaryLabel)
    }
}
