// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Defaults
import Foundation
import Shared
import SwiftUI

public enum AssetStoreState {
    case ready, syncing, error
}

public class AssetStore: ObservableObject {
    public static var shared = AssetStore()

    @Published public private(set) var state: AssetStoreState = .ready
    public var assets: [Asset] = []
    public var collections = Set<Collection>()

    public func refresh() {
        guard
            let url = URL(
                string:
                    "https://api.opensea.io/api/v1/assets?order_direction=desc&offset=0&owner=\(Defaults[.cryptoPublicKey])"
            )
        else {
            return
        }
        self.state = .syncing

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Accept")

        URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard error == nil, let data = data else { return }

            guard let result = try? JSONDecoder().decode(AssetsResult.self, from: data) else {
                DispatchQueue.main.async {
                    self.state = .error
                }
                return
            }
            DispatchQueue.main.async {
                self.assets = result.assets
                self.assets.forEach({
                    guard let collection = $0.collection else { return }
                    self.collections.insert(collection)
                })
                self.state = .ready
            }
        }.resume()
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
