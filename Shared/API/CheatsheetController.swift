// Copyright Neeva. All rights reserved.

import Apollo
import Foundation

public class CheatsheetQueryController:
    QueryController<CheatsheetInfoQuery, [CheatsheetQueryController.CheatsheetInfo]>
{
    public struct PriceHistory {
        public var InStock: Bool
        public var Max: PriceDate
        public var Min: PriceDate
        public var Current: PriceDate
        public var Average: PriceDate
    }

    public struct PriceDate {
        public var Date: String
        public var Price: String
    }

    public struct CheatsheetInfo {
        public var reviewURL: [String]?
        public var priceHistory: PriceHistory?
        public var memorizedQuery: [String]?
    }

    private var url: URL

    public init(url: URL) {
        self.url = url
        super.init()
    }

    public override func reload() {
        self.perform(query: CheatsheetInfoQuery(input: url.absoluteString))
    }

    public override class func processData(_ data: CheatsheetInfoQuery.Data) -> [CheatsheetInfo] {
        var result: CheatsheetInfo = CheatsheetInfo()

        if let reviewUrl = data.getCheatsheetInfo?.reviewUrl {
            result.reviewURL = reviewUrl
        }

        if let memorizedQuery = data.getCheatsheetInfo?.memorizedQuery {
            result.memorizedQuery = memorizedQuery
        }

        if let priceHistory = data.getCheatsheetInfo?.priceHistory {
            let inStock = priceHistory.inStock ?? false
            let max = PriceDate(
                Date: priceHistory.max?.date ?? "",
                Price: priceHistory.max?.priceUsd ?? "")
            let min = PriceDate(
                Date: priceHistory.min?.date ?? "",
                Price: priceHistory.min?.priceUsd ?? "")
            let current = PriceDate(
                Date: priceHistory.current?.date ?? "",
                Price: priceHistory.current?.priceUsd ?? "")
            let average = PriceDate(
                Date: priceHistory.average?.date ?? "",
                Price: priceHistory.average?.priceUsd ?? "")

            result.priceHistory = PriceHistory(
                InStock: inStock, Max: max, Min: min, Current: current, Average: average)
        }

        return [result]
    }

    @discardableResult public static func getCheatsheetInfo(
        url: String, completion: @escaping (Result<[CheatsheetInfo], Error>) -> Void
    ) -> Apollo.Cancellable {
        Self.perform(query: CheatsheetInfoQuery(input: url), completion: completion)
    }
}
