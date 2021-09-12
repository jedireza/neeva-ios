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

public enum RichResultType {
    case ProductCluster(result: ProductClusterResult)
}

public class SearchController:
    QueryController<SearchQuery, [SearchController.RichResult]>
{
    public struct RichResult {
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
                                if let products = typeSpecific.asProductClusters?.productClusters?.products {
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
                                            if let productBuyingGuideReviews = product.buyingGuideReviews
                                            {
                                                for buyingGuideReview in productBuyingGuideReviews {
                                                    if let source = buyingGuideReview.source,
                                                        let reviewURL = buyingGuideReview.reviewUrl,
                                                        let title = buyingGuideReview.header?.title,
                                                        let summary = buyingGuideReview.header?.summary {
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

                                    let productClusterResuslt = ProductClusterResult(productResult)
                                    let finalResult = RichResultType.ProductCluster(result: productClusterResuslt)
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
