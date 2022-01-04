// Copyright Neeva. All rights reserved.

import Foundation
import SDWebImageSwiftUI
import SwiftUI

struct WalletDetailView: View {
    @ObservedObject var store = AssetStore.shared

    var body: some View {
        NavigationView {
            List {
                ForEach(
                    AssetStore.shared.collections.sorted(by: {
                        $0.stats?.oneDaySales ?? 0 > $1.stats?.oneDaySales ?? 0
                    }), id: \.openSeaSlug
                ) { collection in
                    CollectionView(collection: collection)
                        .modifier(ListSeparatorModifier())
                        .listRowBackground(Color.DefaultBackground)
                    ForEach(
                        AssetStore.shared.assets.filter({
                            $0.collection?.openSeaSlug == collection.openSeaSlug
                        })
                    ) { asset in
                        AssetView(asset: asset)
                            .modifier(ListSeparatorModifier())
                            .listRowBackground(Color.DefaultBackground)
                    }
                    Color.TrayBackground
                        .frame(height: 24)
                        .modifier(ListSeparatorModifier())
                }
            }
            .modifier(ListStyleModifier())
            .navigationBarHidden(true)
            .edgesIgnoringSafeArea([.top, .bottom])
        }.modifier(iPadOnlyStackNavigation())
    }
}
