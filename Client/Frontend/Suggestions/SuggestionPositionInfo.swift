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
                key: LogConfig.Attribute.suggestionPosition, value: String(positionIndex)))
        if let chipSuggestionIndex = chipSuggestionIndex {
            clientLogAttributes.append(
                ClientLogCounterAttribute(
                    key: LogConfig.Attribute.chipSuggestionPosition,
                    value: String(chipSuggestionIndex)))
        }

        let bvc = SceneDelegate.getBVC()
        clientLogAttributes.append(
            ClientLogCounterAttribute(
                key: LogConfig.Attribute.urlBarNumOfCharsTyped,
                value: String(bvc.urlBar.shared.queryModel.value.count)))
        return clientLogAttributes
    }
}
