// Copyright Neeva. All rights reserved.

import Shared
import SwiftUI

struct SpaceCardsView: View {
    @EnvironmentObject var spacesModel: SpaceCardModel
    var body: some View {
        if FeatureFlag[.enableCryptoWallet] && !AssetStore.shared.assets.isEmpty {
            AssetGroupView(assetGroup: AssetGroup())
        }
        ForEach(spacesModel.detailsMatchingFilter, id: \.id) { details in
            FittedCard(details: details)
                .id(details.id)
        }.accessibilityHidden(spacesModel.detailedSpace != nil)
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
                }, id: \.id
            ) { details in
                if let rootID = details.manager.get(for: details.id)?.rootUUID,
                    let groupDetails = tabGroupModel.allDetails.first { $0.id == rootID }
                {
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
