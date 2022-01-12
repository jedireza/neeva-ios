// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

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
