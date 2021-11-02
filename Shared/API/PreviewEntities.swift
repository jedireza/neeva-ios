// Copyright Neeva. All rights reserved.

import Foundation

public enum PreviewEntity {
    case richEntity(RichEntity)
    case recipe(Recipe)
    case techDoc(TechDoc)
    case retailProduct(RetailProduct)
    case webPage
}

public struct RichEntity {
    public let id: String
    public let title: String
    public let description: String
    public let imageURL: URL?
}

public struct TechDoc {
    public let id: String
    public let title: String
}

public struct ProductRating {
    public let numReviews: Int?
    public let productStars: Double
}

public struct RetailProduct {
    public let id: String
    public let url: URL
    public let title: String
    public let description: [String]
    public let currentPrice: Double
    public let ratingSummary: ProductRating?

    public var formattedPrice: String {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .currency
        numberFormatter.locale = Locale(identifier: "en_US")
        return numberFormatter.string(from: (currentPrice as NSNumber)) ?? ""
    }
}
