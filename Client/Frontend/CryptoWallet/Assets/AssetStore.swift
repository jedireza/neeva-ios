// Copyright Neeva. All rights reserved.

import Foundation
import Shared
import SwiftUI

public enum AssetStoreState {
    case ready, syncing, error
}

public class AssetStore: ObservableObject {
    public static var shared = AssetStore()

    @Published var state: AssetStoreState = .ready
    var assets: [Asset] = []
    var collections = Set<Collection>()

    public func refresh() {
        guard
            let url = URL(
                string:
                    "https://api.opensea.io/api/v1/assets?order_direction=desc&offset=0&owner=\(WalletAccessor().publicAddress)"
            )
        else {
            return
        }
        self.state = .syncing
        if let data = try? Data(contentsOf: url) {
            guard let result = try? JSONDecoder().decode(AssetsResult.self, from: data) else {
                self.state = .error
                return
            }
            assets = result.assets
            assets.forEach({
                guard let collection = $0.collection else { return }
                collections.insert(collection)
            })
            self.state = .ready
        }
    }

    public func fetch(collection slug: String, onFetch: @escaping (Collection) -> Void) {
        guard let url = URL(string: "https://api.opensea.io/api/v1/collection/\(slug)") else {
            return
        }
        self.state = .syncing
        if let data = try? Data(contentsOf: url) {
            guard let result = try? JSONDecoder().decode(CollectionResult.self, from: data) else {
                DispatchQueue.main.async {
                    self.state = .error
                }
                return
            }
            if let current = collections.first(where: {
                $0.openSeaSlug == result.collection.openSeaSlug
            }) {
                collections.remove(current)
            }
            collections.insert(result.collection)
            onFetch(result.collection)
            DispatchQueue.main.async {
                self.state = .ready
            }
        }
    }

    public func fetchCollections() {
        collections.forEach({ fetch(collection: $0.openSeaSlug, onFetch: { _ in }) })
    }
}

public struct AssetsResult: Codable {
    public let assets: [Asset]
}

public struct CollectionResult: Codable {
    public let collection: Collection
}
