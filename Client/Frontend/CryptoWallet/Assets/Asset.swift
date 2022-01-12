// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Combine
import Foundation
import SDWebImageSwiftUI
import Shared
import SwiftUI

public struct Asset: Codable, SelectableThumbnail, Identifiable {
    public let id: Int
    public let tokenID: String
    public let imageURL: URL
    public let name: String
    public let description: String?
    public let contract: AssetContract
    public let collection: Collection?
    public let traits: [Trait]?
    public let creator: Web3Profile?
    public let owner: Web3Profile

    enum CodingKeys: String, CodingKey {
        case id = "id"
        case tokenID = "token_id"
        case imageURL = "image_url"
        case name = "name"
        case description = "description"
        case contract = "asset_contract"
        case collection = "collection"
        case traits = "traits"
        case creator = "creator"
        case owner = "owner"
    }

    var thumbnail: some View {
        WebImage(
            url: imageURL,
            context: [
                .imageThumbnailPixelSize: CGSize(
                    width: 800,
                    height: 800)
            ]
        )
        .resizable()
        .aspectRatio(contentMode: .fill)
    }

    func onSelect() {}
}

public struct Web3Profile: Codable {
    public let address: String
}

public struct AssetContract: Codable {
    public let address: String
    public let schemaName: String
    public let externalURL: URL?
    public let payoutAddress: String?

    enum CodingKeys: String, CodingKey {
        case address = "address"
        case schemaName = "schema_name"
        case externalURL = "external_link"
        case payoutAddress = "payout_address"
    }
}

public struct Trait: Codable {
    public let type: String
    public let traitCount: Int

    enum CodingKeys: String, CodingKey {
        case type = "trait_type"
        case traitCount = "trait_count"
    }
}

struct AssetView: View {
    @Environment(\.cardSize) private var cardSize
    @Environment(\.aspectRatio) private var aspectRatio
    @Environment(\.onOpenURLForSpace) private var openURLForSpace
    @EnvironmentObject var web3Model: Web3Model
    @EnvironmentObject var gridModel: GridModel
    let asset: Asset

    var body: some View {
        HStack {
            asset.thumbnail
                .frame(width: cardSize, height: cardSize * aspectRatio)
                .cornerRadius(CardUX.CornerRadius)
                .padding(16)
            VStack {
                Text(asset.name)
                    .withFont(.headingMedium)
                Text(asset.description ?? "")
                    .withFont(.bodyMedium)
                    .foregroundColor(.secondaryLabel)
                    .lineLimit(4)
                Image("open-sea-badge")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 24)
                    .padding(12)
                    .background(Color.tertiarySystemFill)
                    .clipShape(Capsule())
                    .highPriorityGesture(
                        TapGesture().onEnded({
                            guard
                                let url = URL(
                                    string:
                                        "https://opensea.io/assets/\(asset.contract.address)/\(asset.tokenID)"
                                )
                            else {
                                return
                            }

                            web3Model.showingWalletDetails = false
                            gridModel.hideWithNoAnimation()
                            DispatchQueue.main.async {
                                openURLForSpace(url, WalletAccessor().publicAddress)
                            }
                        }))
            }.padding(.trailing, 16)
        }
    }
}

public class AssetGroup: ThumbnailModel, Identifiable {
    public var id: String = UUID().uuidString
    var allDetails: [Asset] = []
    var assetStoreSubscription: AnyCancellable? = nil
    var collections: [String] = []

    init(collectionSlug: String) {
        allDetails = AssetStore.shared.assets.filter {
            $0.collection?.openSeaSlug == collectionSlug
        }
        collections = [collectionSlug]

        assetStoreSubscription = AssetStore.shared.$state.sink { state in
            guard case .ready = state else { return }
            self.allDetails = AssetStore.shared.assets.filter {
                $0.collection?.openSeaSlug == self.collections[0]
            }
        }
    }

    init() {
        allDetails = AssetStore.shared.assets
        collections = AssetStore.shared.collections.map { $0.openSeaSlug }

        assetStoreSubscription = AssetStore.shared.$state.sink { state in
            guard case .ready = state else { return }
            self.allDetails = AssetStore.shared.assets
            self.collections = AssetStore.shared.collections.map { $0.openSeaSlug }
        }
    }
}

struct AssetGroupView: View {
    @EnvironmentObject var web3Model: Web3Model

    let assetGroup: AssetGroup
    @State var isPressed = false

    func collectionBadge(collection: String) -> some View {
        WebImage(
            url: AssetStore.shared.collections.first(where: { $0.openSeaSlug == collection })?
                .imageURL
        )
        .resizable()
        .scaledToFit()
        .frame(width: 18, height: 18)
        .clipShape(Circle())
    }

    var body: some View {
        VStack(spacing: 0) {
            Button(
                action: {
                    web3Model.showingWalletDetails = true
                },
                label: {
                    ThumbnailGroupView(model: assetGroup)
                }
            )
            .buttonStyle(.reportsPresses(to: $isPressed))
            .scaleEffect(isPressed ? 0.95 : 1)
            HStack(alignment: .center) {
                Spacer(minLength: 12)
                ForEach(assetGroup.collections.prefix(4), id: \.self) { collection in
                    self.collectionBadge(collection: collection)
                }
                if assetGroup.collections.count > 5 {
                    Text("\(assetGroup.collections.count - 4)")
                        .withFont(.labelSmall)
                        .lineLimit(1)
                        .foregroundColor(Color.white)
                        .frame(width: 18, height: 18)
                        .background(Color.ui.adaptive.blue)
                        .clipShape(Circle())
                } else if assetGroup.collections.count == 5 {
                    collectionBadge(collection: assetGroup.collections[4])
                }
                Spacer(minLength: 12)
            }.frame(height: CardUX.HeaderSize)
        }
        .shadow(radius: 0)
        .onAppear {
            DispatchQueue.global(qos: .userInitiated).async {
                AssetStore.shared.fetchCollections()
            }
        }
    }
}
