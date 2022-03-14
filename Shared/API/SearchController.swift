// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Apollo
import Combine
import CoreGraphics

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

public struct InlineSearchProduct {
    public let productName: String
    public let thumbnailURL: String
    public let actionURL: URL
    public let price: String?
}

public struct BuyingGuide {
    public let reviewType: String?
    public let thumbnailURL: String
    public let productName: String
    public let actionURL: URL
    public let reviewSummary: String?
    public let price: String?
}

public struct WebResult {
    public let faviconURL: String
    public let displayURLHost: String
    public let displayURLPath: String
    public let actionURL: URL
    public let title: String
    public let snippet: String?
    public let publicationDate: String?
    public let inlineSearchProducts: [InlineSearchProduct]
    public let buyingGuides: [BuyingGuide]
}

public struct NewsResult {
    public struct Provider {
        public let name: String?
        public let site: String?
    }
    public let title: String
    public let snippet: String
    public let url: URL
    public let thumbnailURL: String
    public let thumbnailSize: CGSize
    public let datePublished: String
    public let faviconURL: String?
    public let provider: Provider
}

public typealias ProductClusterResult = ([Product])
public typealias RecipeBlockResult = ([RelatedRecipe])
public typealias RelatedSearchesResult = ([String])
public typealias WebResults = ([WebResult])
public struct NewsResults {
    public var news: [NewsResult]
    public let title: String?
    public let snippet: String?
    public let actionURL: URL
}

public enum RichResultType {
    case ProductCluster(result: ProductClusterResult)
    case RecipeBlock(result: RecipeBlockResult)
    case RelatedSearches(result: RelatedSearchesResult)
    case WebGroup(result: WebResults)
    case NewsGroup(result: NewsResults)

    var order: Int {
        switch self {
        case .ProductCluster, .RecipeBlock, .NewsGroup:
            return 0
        case .WebGroup:
            return 1
        case .RelatedSearches:
            return 2
        }
    }
}

public class SearchController:
    QueryController<SearchQuery, [SearchController.RichResult]>
{
    public struct RichResult: Identifiable {
        public var id = UUID()
        public var resultType: RichResultType

        public init(id: UUID = UUID(), resultType: RichResultType) {
            self.id = id
            self.resultType = resultType
        }
    }

    private var query: String

    public init(query: String) {
        self.query = query
        super.init()
    }

    public override func reload() {
        self.perform(query: SearchQuery(query: query))
    }

    class func constructProductCluster(from result: SearchQuery.Data.Search.ResultGroup.Result)
        -> ProductClusterResult?
    {
        guard
            let products = result.typeSpecific?
                .asProductClusters?
                .productClusters?
                .products
        else {
            return nil
        }

        let productItems = products.compactMap { product -> Product? in
            guard let productName = product.productName,
                let thumbnailURL = product.thumbnailUrl
            else {
                return nil
            }

            let sellers: [Seller]? = product.sellers?.compactMap { seller in
                guard let url = seller.url,
                    let price = seller.price,
                    let displayName = seller.displayName,
                    let providerCode = seller.providerCode
                else {
                    return nil
                }
                return Seller(
                    url: url, price: price, displayName: displayName, providerCode: providerCode
                )
            }

            let buyingGuideReviews: [BuyingGuideReview]? = product.buyingGuideReviews?
                .compactMap { review in
                    guard let source = review.source,
                        let reviewURL = review.reviewUrl,
                        let title = review.header?.title,
                        let summary = review.header?.summary
                    else {
                        return nil
                    }
                    return BuyingGuideReview(
                        source: source,
                        reviewURL: reviewURL,
                        header: BuyingGuideReviewHeader(
                            title: title,
                            summary: summary
                        ))
                }

            return Product(
                productName: productName,
                thumbnailURL: thumbnailURL,
                buyingGuideReviews: buyingGuideReviews,
                sellers: sellers,
                priceLow: product.priceLow
            )
        }

        guard !productItems.isEmpty else {
            return nil
        }

        return ProductClusterResult(productItems)
    }

    class func constructRecipeBlock(from result: SearchQuery.Data.Search.ResultGroup.Result)
        -> RecipeBlockResult?
    {
        guard
            let recipes = result.typeSpecific?
                .asRecipeBlock?
                .recipeBlock?
                .recipes
        else {
            return nil
        }

        let relatedRecipes =
            recipes
            .compactMap { recipe -> RelatedRecipe? in
                guard let title = recipe.title,
                    let imageURL = recipe.imageUrl,
                    let urlString = recipe.url,
                    let url = URL(string: urlString)
                else {
                    return nil
                }

                var recipeRating: RecipeRating?
                if let maxStars = recipe.recipeRating?.maxStars,
                    let recipeStars = recipe.recipeRating?.recipeStars,
                    let numReviews = recipe.recipeRating?.numReviews
                {
                    recipeRating = RecipeRating(
                        maxStars: maxStars, recipeStars: recipeStars,
                        numReviews: numReviews)
                }

                return RelatedRecipe(
                    title: title,
                    imageURL: imageURL,
                    url: url,
                    totalTime: recipe.totalTime,
                    recipeRating: recipeRating
                )
            }

        guard !relatedRecipes.isEmpty else {
            return nil
        }

        return RecipeBlockResult(relatedRecipes)
    }

    class func constructRelatedSearch(from result: SearchQuery.Data.Search.ResultGroup.Result)
        -> RelatedSearchesResult?
    {
        guard
            let relatedSearches = result.typeSpecific?
                .asRelatedSearches?
                .relatedSearches?
                .entries
        else {
            return nil
        }

        let searchTexts = relatedSearches.compactMap { item in
            return item.searchText
        }

        guard !searchTexts.isEmpty else {
            return nil
        }

        return RelatedSearchesResult(searchTexts)
    }

    class func constructWebResult(from result: SearchQuery.Data.Search.ResultGroup.Result)
        -> WebResult?
    {
        guard
            let web = result.typeSpecific?
                .asWeb?
                .web
        else {
            return nil
        }

        guard let faviconURL = web.favIconUrl,
            let title = result.title,
            let actionURL = URL(string: result.actionUrl),
            let hostname = web.structuredUrl?.hostname,
            let paths = web.structuredUrl?.paths
        else {
            return nil
        }

        let displayURLHost = hostname
        let displayURLPath = paths.joined(separator: " > ")

        let snippet = web.highlightedSnippet?.segments?.compactMap { segment in
            return segment.text
        }.joined()

        let inlineSearchProducts =
            web.inlineSearchProducts?.compactMap { item -> InlineSearchProduct? in
                guard let productName = item.productName,
                    let thumbnailURL = item.thumbnailUrl,
                    let productActionURLString = item.actionUrl,
                    let productActionURL = URL(string: productActionURLString)
                else {
                    return nil
                }

                return InlineSearchProduct(
                    productName: productName,
                    thumbnailURL: thumbnailURL,
                    actionURL: productActionURL,
                    price: item.priceLow
                )
            } ?? []

        let buyingGuides =
            web.buyingGuideProducts?.compactMap { item -> BuyingGuide? in
                guard let productName = item.productName,
                    let thumbnailURL = item.thumbnailUrl
                else {
                    return nil
                }

                return BuyingGuide(
                    reviewType: item.reviewType,
                    thumbnailURL: thumbnailURL,
                    productName: productName,
                    actionURL: actionURL,
                    reviewSummary: item.reviewSummary,
                    price: item.priceLow)
            } ?? []

        return WebResult(
            faviconURL: faviconURL,
            displayURLHost: displayURLHost,
            displayURLPath: displayURLPath,
            actionURL: actionURL,
            title: title,
            snippet: snippet,
            publicationDate: web.publicationDate,
            inlineSearchProducts: inlineSearchProducts,
            buyingGuides: buyingGuides
        )
    }

    class func constructNewsResult(from result: SearchQuery.Data.Search.ResultGroup.Result)
        -> NewsResults?
    {
        guard let subResults = result.subResults,
            let actionURL = URL(string: result.actionUrl)
        else {
            return nil
        }

        let newsResults =
            subResults
            .compactMap { subResult -> NewsResult? in
                guard let news = subResult.asNews?.news,
                    let url = URL(string: news.url)
                else {
                    return nil
                }
                return NewsResult(
                    title: news.title,
                    snippet: news.snippet,
                    url: url,
                    thumbnailURL: news.thumbnailImage.url,
                    thumbnailSize: CGSize(
                        width: news.thumbnailImage.width, height: news.thumbnailImage.height),
                    datePublished: news.datePublished,
                    faviconURL: news.favIconUrl,
                    provider: NewsResult.Provider(
                        name: news.provider?.name,
                        site: news.provider?.site
                    )
                )
            }

        guard !newsResults.isEmpty else {
            return nil
        }

        return NewsResults(
            news: newsResults,
            title: result.title,
            snippet: result.snippet,
            actionURL: actionURL
        )
    }

    public override class func processData(_ data: SearchQuery.Data) -> [RichResult] {
        var richResults: [RichResult] = []
        // recipe and web results need to be merged into single RichResult objects
        // recipeblocks are flipped and then concatenated
        var recipeBlocks: [RecipeBlockResult] = []
        var webResults: [WebResult] = []

        data.search?.resultGroups?
            // [ResultGroup?]
            .compactMap { group in
                return group?.result
            }
            // [[Result?]]
            .flatMap { $0 }
            // [Result?]
            .compactMap { $0 }
            // [Result]
            .forEach { result in
                // assume that, for results with non-empty subresults
                // every subresult has the same typename
                if let subResultTypeName = result.subResults?.first?.__typename {
                    switch subResultTypeName {
                    case "News":
                        if let newsResults = constructNewsResult(from: result) {
                            richResults.append(
                                RichResult(resultType: .NewsGroup(result: newsResults))
                            )
                        }
                    default:
                        return
                    }
                } else if let typename = result.typeSpecific?.__typename {
                    switch typename {
                    case "ProductClusters":
                        if let productClusterResult = constructProductCluster(from: result) {
                            richResults.append(
                                RichResult(
                                    resultType: .ProductCluster(result: productClusterResult))
                            )
                        }
                    case "RelatedSearches":
                        if let relatedSearchesResult = constructRelatedSearch(from: result) {
                            richResults.append(
                                RichResult(
                                    resultType: .RelatedSearches(result: relatedSearchesResult))
                            )
                        }
                    case "RecipeBlock":
                        if let recipeBlockResult = constructRecipeBlock(from: result) {
                            recipeBlocks.append(recipeBlockResult)
                        }
                    case "Web":
                        if let webResult = constructWebResult(from: result) {
                            webResults.append(webResult)
                        }
                    default:
                        return
                    }
                }
            }

        if !recipeBlocks.isEmpty {
            // merge recipe blocks
            let recipeRichResult = RichResult(
                resultType: .RecipeBlock(
                    result:
                        RecipeBlockResult(
                            recipeBlocks.reversed().flatMap { $0 }
                        )
                )
            )
            richResults.append(recipeRichResult)
        }

        if !webResults.isEmpty {
            // merge web result blocks
            let webRichResult = RichResult(resultType: .WebGroup(result: WebResults(webResults)))
            richResults.append(webRichResult)

            // order the results
            richResults.sort {
                $0.resultType.order < $1.resultType.order
            }
        }

        return richResults
    }

    @discardableResult public static func getRichResult(
        query: String, completion: @escaping (Result<[RichResult], Error>) -> Void
    ) -> Combine.Cancellable {
        Self.perform(query: SearchQuery(query: query), completion: completion)
    }
}
