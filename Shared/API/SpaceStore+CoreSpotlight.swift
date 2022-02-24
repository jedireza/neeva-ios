// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import CoreSpotlight
import Foundation

public extension SpaceStore {
    enum CSConst {
        public static let spaceDomainIdentifier: String = "co.neeva.app.ios.browser.space"
        public static let spaceContentType: UTType = .urlBookmarkData
    }

    static let searchableIndex = CSSearchableIndex(name: "co.neeva.app.ios.browser.spaces")
    // Serial queue to protect all indexing operations
    static let CSIndexQueue = DispatchQueue(
        label: "co.neeva.app.ios.browser.spaces.csqueue",
        qos: .utility,
        attributes: [],
        autoreleaseFrequency: .inherit,
        target: nil
    )

    /// Add or update spaces in index
    class func addSpacesToCoreSpotlight(
        _ spaces: [Space],
        completionHandler: ((Error?) -> Void)? = nil
    ) {
        Self.CSIndexQueue.async {
        // add spaces to CS
            Self.searchableIndex.indexSearchableItems(
                spaces.map { space in
                    let attributes = CSSearchableItemAttributeSet(contentType: CSConst.spaceContentType)
                    attributes.title = space.name
                    attributes.contentDescription = space.description
                    let item = CSSearchableItem(
                        // Space.SpaceID.id
                        uniqueIdentifier: space.id.id,
                        domainIdentifier: CSConst.spaceDomainIdentifier,
                        attributeSet: attributes
                    )
                    item.expirationDate = .distantFuture
                    return item
                },
                completionHandler: completionHandler
            )
        }
    }

    /// Remove spaces from corespoltight by id
    class func removeSpacesFromCoreSpotlight(
        _ ids: [SpaceID],
        completionHandler: ((Error?) -> Void)? = nil
    ) {
        Self.CSIndexQueue.async {
            Self.searchableIndex.deleteSearchableItems(
                withIdentifiers: ids.map { $0.id },
                completionHandler: completionHandler
            )
        }
    }

    // Remove all space items in the index
    class func removeAllSpacesFromCoreSpotlight(completionHandler: ((Error?) -> Void)? = nil) {
        Self.CSIndexQueue.async {
            searchableIndex.deleteSearchableItems(
                withDomainIdentifiers: [CSConst.spaceDomainIdentifier],
                completionHandler: completionHandler
            )
        }
    }

    // Clear all items in the index
    class func clearIndex(completionHandler: ((Error?) -> Void)? = nil) {
        Self.CSIndexQueue.async {
            searchableIndex.deleteAllSearchableItems(completionHandler: completionHandler)
        }
    }
}
