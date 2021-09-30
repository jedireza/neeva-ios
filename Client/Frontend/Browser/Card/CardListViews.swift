// Copyright Neeva. All rights reserved.

import Shared
import SwiftUI

struct HideSelectedForTransition<Details: CardDetails>: ViewModifier {
    let details: Details

    @EnvironmentObject private var gridModel: GridModel

    func body(content: Content) -> some View {
        content
            .opacity(details.isSelected && gridModel.animationThumbnailState != .hidden ? 0 : 1)
            .animation(nil)
    }
}

struct SpaceCardsView: View {
    @EnvironmentObject var spacesModel: SpaceCardModel
    var body: some View {
        ForEach(spacesModel.allDetails, id: \.id) { details in
            FittedCard(details: details)
                .id(details.id)
        }.accessibilityHidden(spacesModel.detailedSpace != nil)
    }
}

struct TabCardsView: View {
    @EnvironmentObject var tabModel: TabCardModel
    @EnvironmentObject var tabGroupModel: TabGroupCardModel

    var body: some View {
        Group {
            if FeatureFlag[.groupsInSwitcher] {
                ForEach(
                    tabModel.allDetails.filter { tabCard in
                        (tabGroupModel.representativeTabs.contains(
                            tabCard.manager.get(for: tabCard.id)!)
                            || tabModel.allDetailsWithExclusionList.contains { $0.id == tabCard.id })
                    }, id: \.id
                ) { details in
                    if let rootID = details.manager.get(for: details.id)?.rootUUID,
                        tabGroupModel.allDetails.contains { $0.id == rootID }
                    {
                        FittedCard(details: (tabGroupModel.allDetails.first { $0.id == rootID })!)
                            .modifier(HideSelectedForTransition(details: details))
                            .id(details.id)
                    } else {
                        FittedCard(details: details)
                            .modifier(HideSelectedForTransition(details: details))
                            .id(details.id)
                    }
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
