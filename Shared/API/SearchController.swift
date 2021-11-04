// Copyright Neeva. All rights reserved.

import Apollo
import Foundation

public struct Seller {
    public let url: String
    public let price: Double
    public let displayName: String
    public let providerCode: String
}

public struct BuyingGuideReviewHeader {
    public let title: String
    public let summary: String
}

public struct BuyingGuideReview {
    public let source: String
    public let reviewURL: String
    public let header: BuyingGuideReviewHeader
}

public struct Product {
    public let productName: String
    public let thumbnailURL: String
    public let buyingGuideReviews: [BuyingGuideReview]?
    public let sellers: [Seller]?
    public let priceLow: Double?
}

public typealias ProductClusterResult = ([Product])
public typealias RecipeBlockResult = ([RelatedRecipe])
public typealias RelatedSearchesResult = ([String])

public enum RichResultType {
    case ProductCluster(result: ProductClusterResult)
    case RecipeBlock(result: RecipeBlockResult)
    case RelatedSearches(result: RelatedSearchesResult)
}

public class SearchController:
    QueryController<SearchQuery, [SearchController.RichResult]>
{
    public struct RichResult: Identifiable {
        public var id = UUID()
        public let resultType: RichResultType
    }

    private var query: String

    public init(query: String) {
        self.query = query
        super.init()
    }

    public override func reload() {
        self.perform(query: SearchQuery(query: query))
    }

    public override class func processData(_ data: SearchQuery.Data) -> [RichResult] {
        var richResult: [RichResult] = []

        if let resultGroup = data.search?.resultGroup {
            for resultArray in resultGroup {
                if let result = resultArray?.result {
                    for item in result {
                        if let typeSpecific = item?.typeSpecific,
                            let typename = item?.typeSpecific?.__typename
                        {
                            // process product clusters result
                            if typename == "ProductClusters" {
                                if let products = typeSpecific.asProductClusters?.productClusters?
                                    .products
                                {
                                    var productResult: [Product] = []

                                    for product in products {
                                        if let productName = product.productName,
                                            let thumbnailURL = product.thumbnailUrl
                                        {
                                            var sellers: [Seller] = []
                                            if let productSellers = product.sellers {
                                                for seller in productSellers {
                                                    if let url = seller.url,
                                                        let price = seller.price,
                                                        let displayName = seller.displayName,
                                                        let providerCode = seller.providerCode
                                                    {
                                                        sellers.append(
                                                            Seller(
                                                                url: url,
                                                                price: price,
                                                                displayName: displayName,
                                                                providerCode: providerCode
                                                            )
                                                        )
                                                    }
                                                }
                                            }

                                            var buyingGuideReviews: [BuyingGuideReview] = []
                                            if let productBuyingGuideReviews = product
                                                .buyingGuideReviews
                                            {
                                                for buyingGuideReview in productBuyingGuideReviews {
                                                    if let source = buyingGuideReview.source,
                                                        let reviewURL = buyingGuideReview.reviewUrl,
                                                        let title = buyingGuideReview.header?.title,
                                                        let summary = buyingGuideReview.header?
                                                            .summary
                                                    {
                                                        buyingGuideReviews.append(
                                                            BuyingGuideReview(
                                                                source: source,
                                                                reviewURL: reviewURL,
                                                                header: BuyingGuideReviewHeader(
                                                                    title: title, summary: summary)
                                                            )
                                                        )
                                                    }
                                                }
                                            }

                                            productResult.append(
                                                Product(
                                                    productName: productName,
                                                    thumbnailURL: thumbnailURL,
                                                    buyingGuideReviews: buyingGuideReviews,
                                                    sellers: sellers, priceLow: product.priceLow))
                                        }
                                    }

                                    let productClusterResult = ProductClusterResult(productResult)
                                    let finalResult = RichResultType.ProductCluster(
                                        result: productClusterResult)
                                    richResult.append(RichResult(resultType: finalResult))
                                }
                            } else if typename == "RecipeBlock" {
                                if let recipes = typeSpecific.asRecipeBlock?.recipeBlock?.recipes {
                                    var recipeResult: [RelatedRecipe] = []

                                    for recipe in recipes {
                                        if let title = recipe.title,
                                            let imageURL = recipe.imageUrl,
                                            let urlString = recipe.url
                                        {
                                            let url = URL(string: urlString)!

                                            var recipeRating: RecipeRating?

                                            if let maxStars = recipe.recipeRating?.maxStars,
                                                let recipeStars = recipe.recipeRating?.recipeStars,
                                                let numReviews = recipe.recipeRating?.numReviews
                                            {
                                                recipeRating = RecipeRating(
                                                    maxStars: maxStars, recipeStars: recipeStars,
                                                    numReviews: numReviews)
                                            }

                                            recipeResult.append(
                                                RelatedRecipe(
                                                    title: title, imageURL: imageURL, url: url,
                                                    totalTime: recipe.totalTime,
                                                    recipeRating: recipeRating))
                                        }
                                    }

                                    if richResult.count > 0 {
                                        for (index, item) in richResult.enumerated() {
                                            switch item.resultType {
                                            case .RecipeBlock(let existingResult):
                                                recipeResult += existingResult
                                                richResult.remove(at: index)
                                            default:
                                                break
                                            }
                                        }
                                    }

                                    let recipeBlockResult = RecipeBlockResult(recipeResult)
                                    let finalResult = RichResultType.RecipeBlock(
                                        result: recipeBlockResult)
                                    richResult.append(RichResult(resultType: finalResult))

                                }
                            } else if typename == "RelatedSearches" {
                                if let relatedSearches = typeSpecific.asRelatedSearches?.relatedSearches?.entries {

                                    var relatedSearchesResult: [String] = []

                                    for item in relatedSearches {
                                        if let searchText = item.searchText {
                                            relatedSearchesResult.append(searchText)
                                        }
                                    }

                                    let finalResult = RichResultType.RelatedSearches(result: relatedSearchesResult)
                                    richResult.append(RichResult(resultType: finalResult))
                                }
                            }
                        }
                    }
                }
            }
        }
        return richResult
    }

    @discardableResult public static func getRichResult(
        query: String, completion: @escaping (Result<[RichResult], Error>) -> Void
    ) -> Apollo.Cancellable {
        Self.perform(query: SearchQuery(query: query), completion: completion)
    }
}
