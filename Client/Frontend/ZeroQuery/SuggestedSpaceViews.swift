// Copyright © Neeva. All rights reserved.

import Shared
import SwiftUI

struct SuggestedSpacesView: View {
    @ObservedObject var spaceStore =
        NeevaUserInfo.shared.isUserLoggedIn
        ? SpaceStore.shared : SpaceStore.suggested
    @ObservedObject var userInfo = NeevaUserInfo.shared

    @Environment(\.onOpenURL) var openURL
    @State var shareTargetView: UIView!

    var itemsToShow: Int {
        userInfo.isUserLoggedIn ? 3 : 6
    }

    var body: some View {
        VStack {
            if case .refreshing = spaceStore.state, spaceStore.allSpaces.isEmpty {
                VStack(spacing: ZeroQueryUX.Padding) {
                    ForEach(0..<itemsToShow) { _ in
                        LoadingSpaceListItem()
                    }
                }
                .padding(.horizontal, ZeroQueryUX.Padding)
                .padding(.vertical, ZeroQueryUX.Padding / 2)
            } else {
                VStack(spacing: 0) {
                    // show the 3 most recently updated spaces
                    ForEach(spaceStore.allSpaces.prefix(itemsToShow)) { space in
                        Button(action: {
                            ClientLogger.shared.logCounter(
                                .RecommendedSpaceVisited,
                                attributes: EnvironmentHelper.shared.getFirstRunAttributes())
                            openURL(space.url)
                        }) {
                            SuggestedSpaceView(space: space)
                                .foregroundColor(.primary)
                        }
                        .buttonStyle(TableCellButtonStyle())
                        .uiViewRef($shareTargetView)
                        .contextMenu {
                            ZeroQueryCommonContextMenuActions(
                                siteURL: space.url, title: nil, description: nil,
                                shareTarget: shareTargetView)
                        }
                    }
                }.opacity(
                    {
                        if case .refreshing = spaceStore.state {
                            return 0.6
                        } else {
                            return 1
                        }
                    }())
            }
        }
        .padding(.vertical, ZeroQueryUX.Padding / 2)
    }
}

struct SuggestedSpaceView: View {
    let space: Space

    var body: some View {
        HStack(spacing: ZeroQueryUX.Padding) {
            LargeSpaceIconView(space: space)
            Text(space.name).withFont(.labelMedium)
            Spacer()
        }
        .padding(.horizontal, ZeroQueryUX.Padding)
        .padding(.vertical, ZeroQueryUX.Padding / 2)
        .onDrag { NSItemProvider(url: space.url) }
    }
}

struct SuggestedSpaceViews_Previews: PreviewProvider {
    static var previews: some View {
        SuggestedSpaceView(space: .stackOverflow)
            .padding(.vertical, ZeroQueryUX.Padding / 2)
            .previewLayout(.sizeThatFits)
        SuggestedSpacesView(
            spaceStore: .createMock([.stackOverflow, .savedForLater, .shared, .public]),
            userInfo: .previewLoggedOut
        )
        .previewLayout(.sizeThatFits)
        SuggestedSpacesView(
            spaceStore: .createMock([.stackOverflow, .savedForLater, .shared, .public])
        )
        .previewLayout(.sizeThatFits)
    }
}
