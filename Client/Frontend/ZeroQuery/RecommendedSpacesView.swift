// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Shared
import SwiftUI

struct RecommendedSpacesView: View {
    @ObservedObject var store: SpaceStore
    @ObservedObject var viewModel: ZeroQueryModel
    @Binding var expandSuggestedSpace: Bool

    var body: some View {
        if let space = store.allSpaces.first {
            ZeroQueryHeader(
                title: "\(space.name)",
                action: { expandSuggestedSpace.toggle() },
                label: "\(expandSuggestedSpace ? "hides" : "shows") this section",
                icon: expandSuggestedSpace ? .chevronUp : .chevronDown
            )
            if expandSuggestedSpace {
                CompactSpaceDetailList(
                    primitive: SpaceCardDetails(
                        space: space,
                        manager: SpaceStore.suggested)
                )
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .environment(
                    \.onOpenURLForSpace,
                    { url, _ in
                        if url.absoluteString.starts(
                            with: NeevaConstants.appSpacesURL.absoluteString),
                            let navPath = NavigationPath.navigationPath(
                                from: URL(
                                    string: NeevaConstants.appDeepLinkURL.absoluteString
                                        + "space?id="
                                        + url.lastPathComponent)!,
                                with: viewModel.bvc)
                        {
                            viewModel.bvc.hideZeroQuery()
                            NavigationPath.handle(nav: navPath, with: viewModel.bvc)
                        } else {
                            viewModel.bvc.tabManager.createOrSwitchToTab(
                                for: url)
                            viewModel.bvc.hideZeroQuery()
                        }
                    }
                )
                .environmentObject(viewModel.bvc.gridModel)
                .environmentObject(viewModel.bvc.gridModel.tabCardModel)
                .environmentObject(viewModel.bvc.gridModel.spaceCardModel)
            }
        }
    }
}
