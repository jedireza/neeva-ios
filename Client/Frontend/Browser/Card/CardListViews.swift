// Copyright Neeva. All rights reserved.

import Shared
import SwiftUI

private struct HideSelectedForTransition<Details: CardDetails>: ViewModifier {
    let details: Details

    @EnvironmentObject private var gridModel: GridModel

    func body(content: Content) -> some View {
        content
            .opacity(details.isSelected && gridModel.animationThumbnailState != .hidden ? 0 : 1)
    }
}

struct SpaceCardsView: View {
    @EnvironmentObject var spacesModel: SpaceCardModel

    var body: some View {
        ForEach(spacesModel.allDetails, id: \.id) { details in
            FittedCard(details: details)
                .modifier(HideSelectedForTransition(details: details))
                .id(details.id)
        }
    }
}

struct TabCardsView: View {
    @EnvironmentObject var tabModel: TabCardModel
    @EnvironmentObject var tabGroupModel: TabGroupCardModel

    var body: some View {
        Group {
            if FeatureFlag[.groupsInSwitcher] {
                ForEach(tabGroupModel.allDetails, id: \.id) { details in
                    FittedCard(details: details)
                        .modifier(HideSelectedForTransition(details: details))
                        .id(details.id)
                }
                ForEach(tabModel.allDetailsWithExclusionList, id: \.id) { details in
                    FittedCard(details: details)
                        .modifier(HideSelectedForTransition(details: details))
                        .id(details.id)
                }
            } else {
                ForEach(tabModel.allDetails, id: \.id) { details in
                    FittedCard(details: details)
                        .modifier(HideSelectedForTransition(details: details))
                        .id(details.id)
                }
            }

        }
    }
}
