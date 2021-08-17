// Copyright Neeva. All rights reserved.

import Foundation

public extension SuggestionsQuery.Data.Suggest.QuerySuggestion.Annotation {
    func isChangeInStockPricePositive() -> Bool {
        return stockInfo?.changeFromPreviousClose ?? 0.0 > 0
    }
}
