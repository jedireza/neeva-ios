// Copyright Neeva. All rights reserved.

import Apollo
import Combine
import Defaults
import Shared
import Storage
import UIKit

struct SuggestionPositionInfo {
    let positionIndex: Int
    let chipSuggestionIndex: Int?

    init(
        positionIndex: Int,
        chipSuggestionIndex: Int? = nil
    ) {
        self.positionIndex = positionIndex
        self.chipSuggestionIndex = chipSuggestionIndex
    }

    public func loggingAttributes() -> [ClientLogCounterAttribute] {
        var clientLogAttributes = [ClientLogCounterAttribute]()

        clientLogAttributes.append(
            ClientLogCounterAttribute(
                key: LogConfig.SuggestionAttribute.suggestionPosition, value: String(positionIndex)))
        if let chipSuggestionIndex = chipSuggestionIndex {
            clientLogAttributes.append(
                ClientLogCounterAttribute(
                    key: LogConfig.SuggestionAttribute.chipSuggestionPosition,
                    value: String(chipSuggestionIndex)))
        }

        let bvc = SceneDelegate.getBVC(for: nil)
        clientLogAttributes.append(
            ClientLogCounterAttribute(
                key: LogConfig.SuggestionAttribute.urlBarNumOfCharsTyped,
                value: String(bvc.searchQueryModel.value.count)))
        return clientLogAttributes
    }
}
