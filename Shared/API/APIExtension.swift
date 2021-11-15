// Copyright Neeva. All rights reserved.

import Foundation

extension SuggestionsQuery.Data.Suggest.QuerySuggestion.Annotation {
    public func isChangeInStockPricePositive() -> Bool {
        return stockInfo?.changeFromPreviousClose ?? 0.0 > 0
    }

    public func dictionarySupplementText() -> String {
        var supplementText = ""
        if let phoneticSpelling = dictionaryInfo?.phoneticSpelling {
            supplementText += "| \(phoneticSpelling) "
        }
        if let lexicalCategory = dictionaryInfo?.lexicalCategory {
            supplementText += "| \(lexicalCategory) "
        }
        return supplementText
    }
}
