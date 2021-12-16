// Copyright Neeva. All rights reserved.

import Shared
import SwiftUI

enum SpaceFilterState {
    case allSpaces
    case ownedByMe
}

struct SpacesFilterView: View {
    @EnvironmentObject var spaceCardModel: SpaceCardModel

    var body: some View {
        GroupedStack {
            GroupedCell.Decoration {
                VStack(spacing: 0) {
                    NeevaMenuRowButtonView(
                        label: "All Spaces",
                        symbol: spaceCardModel.filterState == .allSpaces ? .checkmark : nil
                    ) {
                        spaceCardModel.filterState = .allSpaces
                    }.onTapGesture {
                        logFilterTapped()
                    }

                    Color.groupedBackground.frame(height: 1)

                    NeevaMenuRowButtonView(
                        label: "Owned by me",
                        symbol: spaceCardModel.filterState == .ownedByMe ? .checkmark : nil
                    ) {
                        spaceCardModel.filterState = .ownedByMe
                    }.onTapGesture {
                        logFilterTapped()
                    }
                }
                .accentColor(.label)
            }
        }
        .overlayIsFixedHeight(isFixedHeight: true)
        .padding(.bottom, -12)
    }

    func logFilterTapped() {
        ClientLogger.shared.logCounter(LogConfig.Interaction.SpaceFilterClicked)
    }
}
