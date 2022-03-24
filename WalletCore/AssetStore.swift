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
    public var availableThemes = Set<Web3Theme>()

    public func refresh() {
        guard !Defaults[.cryptoPublicKey].isEmpty else {
            return
        }
        DispatchQueue.main.async {
            self.state = .syncing
        }
        Web3NetworkProvider.default.request(
            target: OpenSeaAPI.assets(owner: Defaults[.cryptoPublicKey]),
            model: AssetsResult.self,
            completion: { [weak self] response in
                guard let self = self else {
                    return
                }
                switch response {
                case .success(let result):
                    self.assets = result.assets
                    self.assets.forEach({
                        guard let collection = $0.collection else { return }
                        if let theme = Web3Theme.allCases.first(
                            where: { $0.rawValue == collection.openSeaSlug })
                        {
                            self.availableThemes.insert(theme)
                        }
                        self.collections.insert(collection)
                    })
                    self.state = .ready
                case .failure(let error):
                    print(error.localizedDescription)
                    self.state = .error
                }
            })
    }

    public func fetch(collection slug: String, onFetch: @escaping (Collection) -> Void) {
        Web3NetworkProvider.default.request(
            target: OpenSeaAPI.collection(slug: slug),
            model: CollectionResult.self,
            completion: { [weak self] response in
                guard let self = self else { return }
                switch response {
                case .success(let result):
                    if let current = self.collections.first(where: {
                        $0.openSeaSlug == result.collection.openSeaSlug
                    }) {
                        self.collections.remove(current)
                    }
                    self.collections.insert(result.collection)
                    onFetch(result.collection)
                    self.state = .ready
                case .failure(let error):
                    print(error)
                    self.state = .error
                }
            })
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
