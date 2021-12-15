// Copyright Neeva. All rights reserved.

import Shared
import SwiftUI

struct SpaceCardsView: View {
    @EnvironmentObject var spacesModel: SpaceCardModel
    var body: some View {
        ForEach(spacesModel.allDetails, id: \.id) { details in
            FittedCard(details: details)
                .id(details.id)
        }.accessibilityHidden(spacesModel.detailedSpace != nil)
    }
}

struct MainGridComponent: View{
    @EnvironmentObject var tabModel: TabCardModel
    @EnvironmentObject var tabGroupModel: TabGroupCardModel

    let subarray: ArraySlice<TabCardDetails>

    var hGridLayout = [
        GridItem(.flexible())
    ]

    var body: some View {
        let firstDetail = subarray.first!
        Group {
            if tabModel.allDetailsWithExclusionList.contains{$0.id == subarray.first?.id} {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: CardGridUX.GridSpacing) {
                    ForEach(subarray, id: \.id){ details in
                        FittedCard(details: details)
                            .id(details.id)
                    }
                }
            } else {
                if let rootID = firstDetail.manager.get(for: firstDetail.id)?.rootUUID, let groupDetails = tabGroupModel.allDetails.first {$0.id == rootID }
                {
                    ScrollView(.horizontal) {
                        LazyHGrid(rows: hGridLayout) {
                            ForEach(groupDetails.allDetails, id: \.id) { details in
                                FittedCard(details: details)
                                    .contextMenu {
                                        FeatureFlag[.tabGroupsPinning]
                                            ? TabGroupContextMenu(details: details) : nil
                                    }
                            }
                        }
                    }
                }
            }
        }
    }
}

struct TabCardsView: View {
    @EnvironmentObject var tabModel: TabCardModel
    @EnvironmentObject var tabGroupModel: TabGroupCardModel

    let containerGeometry: GeometryProxy

    var body: some View {
        Group {
            ForEach(
                tabModel.allDetails.filter { tabCard in
                    (tabGroupModel.representativeTabs.contains(
                        tabCard.manager.get(for: tabCard.id)!)
                        || tabModel.allDetailsWithExclusionList.contains { $0.id == tabCard.id })
                }
                , id: \.id
            ) { details in
                if let rootID = details.manager.get(for: details.id)?.rootUUID,
                    let groupDetails = tabGroupModel.allDetails.first { $0.id == rootID }
                {
                    //Tab group enters here
                    FittedCard(details: groupDetails)
                        .modifier(
                            CardTransitionModifier(
                                details: groupDetails, containerGeometry: containerGeometry)
                        )
                        .id(groupDetails.id)
                        .environment(\.selectionCompletion) {
                            var attributes = EnvironmentHelper.shared.getAttributes()

                            attributes.append(
                                ClientLogCounterAttribute(
                                    key: LogConfig.TabGroupAttribute.numTabsInTabGroup,
                                    value: String(
                                        tabGroupModel.manager.get(for: details.id)?.children.count
                                            ?? 0)
                                )
                            )

                            ClientLogger.shared.logCounter(.tabGroupClicked, attributes: attributes)
                        }
                } else {
                    FittedCard(details: details)
                        .modifier(
                            CardTransitionModifier(
                                details: details, containerGeometry: containerGeometry)
                        )
                        .id(details.id)
                }
            }
        }
    }
}
