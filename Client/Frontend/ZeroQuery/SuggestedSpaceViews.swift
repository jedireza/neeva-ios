// Copyright © Neeva. All rights reserved.

import SwiftUI
import Shared

struct SuggestedSpacesView: View {
    @ObservedObject var spaceStore = SpaceStore.shared
    @ObservedObject var userInfo = NeevaUserInfo.shared

    @Environment(\.onOpenURL) var openURL

    var body: some View {
        VStack {
            if !userInfo.isUserLoggedIn {
                ZeroQueryPlaceholder(label: "Your spaces go here")
            } else if case .refreshing = spaceStore.state, spaceStore.allSpaces.isEmpty {
                VStack(spacing: ZeroQueryUX.Padding) {
                    ForEach(0..<3) { _ in
                        LoadingSpaceListItem()
                    }
                }
                .padding(.horizontal, ZeroQueryUX.Padding)
                .padding(.vertical, ZeroQueryUX.Padding / 2)
            } else {
                VStack(spacing: 0) {
                    // show the 3 most recently updated spaces
                    ForEach(spaceStore.allSpaces.prefix(3)) { space in
                        Button(action: { openURL(space.url) }) {
                            SuggestedSpaceView(space: space)
                                .foregroundColor(.primary)
                        }
                        .buttonStyle(TableCellButtonStyle())
                        .contextMenu { ZeroQueryCommonContextMenuActions(siteURL: space.url) }
                    }
                }.opacity({
                    if case .refreshing = spaceStore.state {
                        return 0.6
                    } else {
                        return 1
                    }
                }())
            }
        }
        .padding(.vertical, ZeroQueryUX.Padding / 2)
        .onAppear {
            spaceStore.refresh()
        }
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
        SuggestedSpacesView(spaceStore: .createMock([.stackOverflow, .savedForLater, .sharedSpace, .publicSpace]), userInfo: .previewLoggedOut)
            .previewLayout(.sizeThatFits)
        SuggestedSpacesView(spaceStore: .createMock([.stackOverflow, .savedForLater, .sharedSpace, .publicSpace]))
            .previewLayout(.sizeThatFits)
    }
}
