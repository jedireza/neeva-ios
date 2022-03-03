// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Foundation
import Shared

class SpotlightLogger {
    public static let shared = SpotlightLogger()
}

extension SpotlightLogger: SpaceStoreSpotlightEventDelegate {
    func willIndex(_ spaces: [Space]) {
        ClientLogger.shared.logCounter(
            .willIndex,
            attributes: EnvironmentHelper.shared.getAttributes() + [
                ClientLogCounterAttribute(
                    key: LogConfig.SpotlightAttribute.itemType,
                    value: LogConfig.SpotlightAttribute.ItemType.space.rawValue
                ),
                ClientLogCounterAttribute(
                    key: LogConfig.SpotlightAttribute.indexCount,
                    value: String(spaces.count)
                )
            ]
        )
    }

    func willIndexEntities(for space: Space, count: Int) {
        ClientLogger.shared.logCounter(
            .willIndex,
            attributes: EnvironmentHelper.shared.getAttributes() + [
                ClientLogCounterAttribute(
                    key: LogConfig.SpotlightAttribute.itemType,
                    value: LogConfig.SpotlightAttribute.ItemType.spaceEntity.rawValue
                ),
                ClientLogCounterAttribute(
                    key: LogConfig.SpotlightAttribute.indexCount,
                    value: String(count)
                ),
                ClientLogCounterAttribute(
                    key: LogConfig.SpotlightAttribute.spaceIdPayload,
                    value: space.id.id
                )
            ]
        )
    }

    func didIndex(_ spaces: [Space], error: Error?) {
        ClientLogger.shared.logCounter(
            .didIndex,
            attributes: EnvironmentHelper.shared.getAttributes() + [
                ClientLogCounterAttribute(
                    key: LogConfig.SpotlightAttribute.itemType,
                    value: LogConfig.SpotlightAttribute.ItemType.space.rawValue
                ),
                ClientLogCounterAttribute(
                    key: "error",
                    value: error?.localizedDescription
                )
            ]
        )
    }

    func didIndexEntities(for space: Space, error: Error?) {
        ClientLogger.shared.logCounter(
            .didIndex,
            attributes: EnvironmentHelper.shared.getAttributes() + [
                ClientLogCounterAttribute(
                    key: LogConfig.SpotlightAttribute.itemType,
                    value: LogConfig.SpotlightAttribute.ItemType.spaceEntity.rawValue
                ),
                ClientLogCounterAttribute(
                    key: LogConfig.SpotlightAttribute.spaceIdPayload,
                    value: space.id.id
                ),
                ClientLogCounterAttribute(
                    key: "error",
                    value: error?.localizedDescription
                )
            ]
        )
    }
}
