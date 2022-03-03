// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import CoreSpotlight
import Foundation
import SDWebImage
import UIKit

public protocol SpaceStoreSpotlightEventDelegate: AnyObject {
    func willIndex(_ spaces: [Space])
    func willIndexEntities(for space: Space, count: Int)
    func didIndex(_ spaces: [Space], error: Error?)
    func didIndexEntities(for space: Space, error: Error?)
}

extension SpaceStore {
    enum CSConst {
        public static let spaceDomainIdentifier: String = "co.neeva.app.ios.browser.space"
        public static let spaceContentType: UTType = .urlBookmarkData

        public static let spacePageDomainIdentifier: String = "co.neeva.app.ios.browser.space.page"
        public static let spacePageContentType: UTType = .urlBookmarkData
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

    /// SDWebImageTransformer
    static let resizeTransformer = SDImageResizingTransformer(
        size: CGSize(width: 180, height: 270),
        scaleMode: .aspectFit
    )

    // MARK: - Space Methods
    /// Add or update spaces in index
    func addSpacesToCoreSpotlight(
        _ spaces: [Space],
        completionHandler: ((Error?) -> Void)? = nil
    ) {
        Self.CSIndexQueue.async {
            // add spaces to CS
            DispatchQueue.main.async { [weak self] in
                self?.spotlightEventDelegate?.willIndex(spaces)
            }
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
                }
            ) { error in
                DispatchQueue.main.async { [weak self] in
                    self?.spotlightEventDelegate?.didIndex(spaces, error: error)
                    completionHandler?(error)
                }
            }
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

    // MARK: - Page Methods
    func addSpaceURLsToCoreSpotlight(
        from space: Space,
        completionHandler: ((Error?) -> Void)? = nil
    ) {
        Self.CSIndexQueue.async {
            // the data might have changed between when the func is called and when this executes
            // but it should always be correct to use the most recent data in the Space instance
            guard let data = space.contentData else { return }

            let group = DispatchGroup()

            var items: [CSSearchableItem?] = Array(repeating: nil, count: data.count)

            for (idx, entity) in data.enumerated() {
                guard let url = entity.url else { continue }
                group.enter()
                Self.getThumbnailData(for: entity) { image in
                    let attributes = CSSearchableItemAttributeSet(contentType: CSConst.spacePageContentType)
                    attributes.title = entity.displayTitle
                    attributes.contentDescription = entity.displayDescription
                    attributes.thumbnailData = image?.pngData()
                    attributes.url = url
                    let item = CSSearchableItem(
                        uniqueIdentifier: url.absoluteString,
                        domainIdentifier: CSConst.spacePageDomainIdentifier,
                        attributeSet: attributes)
                    items[idx] = item
                    group.leave()
                }
            }

            // block the queue
            group.wait()

            DispatchQueue.main.async {[weak self] in
                self?.spotlightEventDelegate?.willIndexEntities(
                    for: space,
                    count: items.compactMap{$0}.count
                )
            }

            Self.searchableIndex.indexSearchableItems(
                items.compactMap { $0 }
            ) { error in
                DispatchQueue.main.async {[weak self] in
                    self?.spotlightEventDelegate?.didIndexEntities(for: space, error: error)
                    completionHandler?(error)
                }
            }
        }
    }

    // MARK: - Clear Index
    // Remove all space items in the index
    public class func removeAllSpacesFromCoreSpotlight(completionHandler: ((Error?) -> Void)? = nil) {
        Self.CSIndexQueue.async {
            searchableIndex.deleteSearchableItems(
                withDomainIdentifiers: [CSConst.spaceDomainIdentifier],
                completionHandler: completionHandler
            )
        }
    }

    public class func removeAllSpaceURLsFromCoreSpotlight(completionHandler: ((Error?) -> Void)? = nil) {
        Self.CSIndexQueue.async {
            searchableIndex.deleteSearchableItems(
                withDomainIdentifiers: [CSConst.spacePageDomainIdentifier],
                completionHandler: completionHandler
            )
        }
    }

    // Clear all items in the index
    public class func clearIndex(completionHandler: ((Error?) -> Void)? = nil) {
        Self.CSIndexQueue.async {
            searchableIndex.deleteAllSearchableItems(completionHandler: completionHandler)
        }
    }

    // MARK: - Helpers
    // Query Image from SDWebImage
    private class func getThumbnailData(
        for entity: SpaceEntityData,
        completionHandler: @escaping (UIImage?) -> Void
    ) {
        if let thumbnailData = entity.thumbnail?.dataURIBody {
            completionHandler(UIImage.imageFromDataThreadSafe(thumbnailData))
        } else if let thumbnailURL = entity.getThumbnailURL() {
            downloadHelperSDWebImage(imageURL: thumbnailURL) { image in
                if let image = image {
                    completionHandler(image)
                } else {
                    downloadDomainLevelFavicon(url: entity.url, completionHandler: completionHandler)
                }
            }
        } else {
            downloadDomainLevelFavicon(url: entity.url, completionHandler: completionHandler)
        }
    }

    private class func downloadDomainLevelFavicon(
        url: URL?,
        completionHandler: @escaping (UIImage?) -> Void
    ) {
        guard let url = url else {
            completionHandler(nil)
            return
        }

        let siteIconURL = url.domainURL.appendingPathComponent("favicon.ico")

        downloadHelperSDWebImage(imageURL: siteIconURL, completionHandler: completionHandler)
    }

    private class func downloadHelperSDWebImage(
        imageURL: URL,
        completionHandler: @escaping (UIImage?) -> Void
    ) {
        let manager = SDWebImageManager.shared
        let options: SDWebImageOptions = .lowPriority

        let onCompletedPageFavicon: SDInternalCompletionBlock = {
            (img, _, _, _, _, _) -> Void in
            completionHandler(img)
        }

        manager.loadImage(
            with: imageURL,
            options: options,
            context: [.imageTransformer: Self.resizeTransformer],
            progress: nil,
            completed: onCompletedPageFavicon
        )
    }

}

extension SpaceEntityData {
    static let imageExtensions = Set(["jpeg", "jpg", "png", "gif"])

    var isImage: Bool {
        guard let pathExtension = url?.pathExtension else {
            return false
        }
        return Self.imageExtensions.contains(pathExtension)
    }

    var displayTitle: String? {
        switch previewEntity {
        case .richEntity(let richEntity):
            return richEntity.title
        case .retailProduct(let product):
            return product.title
        case .techDoc(let doc):
            return doc.title
        case .newsItem(let newsItem):
            return newsItem.title
        case .recipe(let recipe):
            return recipe.title
        case .webPage, .spaceLink:
            return title
        }
    }

    var displayDescription: String? {
        switch previewEntity {
        case .richEntity(let richEntity):
            return richEntity.description
        case .retailProduct(let product):
            return product.description.first
        case .newsItem(let newsItem):
            return newsItem.snippet
        case .webPage, .spaceLink, .recipe, .techDoc:
            return snippet
        }
    }

    func getThumbnailURL() -> URL? {
        switch previewEntity {
        case let .recipe(recipe):
            return URL(string: recipe.imageURL)
        case let .richEntity(richEntity):
            return richEntity.imageURL
        case let .newsItem(newsItem):
            return newsItem.thumbnailURL
        default:
            break
        }
        if isImage {
            return url
        }
        return nil
    }
}
