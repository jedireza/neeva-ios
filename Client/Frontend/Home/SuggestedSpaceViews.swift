// Copyright © Neeva. All rights reserved.

import SwiftUI
import Shared

struct SuggestedSpacesView: View {
    @ObservedObject var spaceStore = SpaceStore.shared

    @Environment(\.onOpenURL) var openURL

    var body: some View {
        VStack {
            if case .refreshing = spaceStore.state, spaceStore.allSpaces.isEmpty {
                VStack(spacing: NeevaHomeUX.Padding) {
                    ForEach(0..<3) { _ in
                        LoadingSpaceListItem()
                    }
                }
                .padding(.horizontal, NeevaHomeUX.Padding)
                .padding(.vertical, NeevaHomeUX.Padding / 2)
            } else {
                VStack(spacing: 0) {
                    // show the 3 most recently updated spaces
                    ForEach(spaceStore.allSpaces.prefix(3)) { space in
                        Button(action: { openURL(space.url) }) {
                            SuggestedSpaceView(space: space)
                        }.buttonStyle(TableCellButtonStyle())
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
        .padding(.vertical, NeevaHomeUX.Padding / 2)
        .onAppear {
            spaceStore.refresh()
        }
    }
}

struct SuggestedSpaceView: View {
    let space: Space

    var body: some View {
        HStack(spacing: NeevaHomeUX.Padding) {
            LargeSpaceIconView(space: space)
            Text(space.name).withFont(.labelMedium)
            Spacer()
        }
        .padding(.horizontal, NeevaHomeUX.Padding)
        .padding(.vertical, NeevaHomeUX.Padding / 2)
    }
}

struct SuggestedSpaceViews_Previews: PreviewProvider {
    static var previews: some View {
        SuggestedSpaceView(space: .stackOverflow)
            .padding(.vertical, NeevaHomeUX.Padding / 2)
            .previewLayout(.sizeThatFits)
        SuggestedSpacesView(spaceStore: .createMock([.stackOverflow, .savedForLater, .sharedSpace, .publicSpace]))
            .previewLayout(.sizeThatFits)
    }
}
