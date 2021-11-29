// Copyright Neeva. All rights reserved.

import Apollo
import Combine
import Defaults
import Shared
import Storage
import UIKit

struct SuggestionPositionInfo {
    let positionIndex: Int

    init(
        positionIndex: Int
    ) {
        self.positionIndex = positionIndex
    }

    public func loggingAttributes() -> [ClientLogCounterAttribute] {
        var clientLogAttributes = [ClientLogCounterAttribute]()

        clientLogAttributes.append(
            ClientLogCounterAttribute(
                key: LogConfig.SuggestionAttribute.suggestionPosition, value: String(positionIndex)))

        let bvc = SceneDelegate.getBVC(for: nil)
        clientLogAttributes.append(
            ClientLogCounterAttribute(
                key: LogConfig.SuggestionAttribute.urlBarNumOfCharsTyped,
                value: String(bvc.searchQueryModel.value.count)))
        return clientLogAttributes
    }
}
