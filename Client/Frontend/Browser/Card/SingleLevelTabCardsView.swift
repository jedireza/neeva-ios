// Copyright Neeva. All rights reserved.

import Shared
import SwiftUI

enum SingleLevelTabCardsViewUX {
    static let TabGroupCarouselTitleSize: CGFloat = 22
    static let TabGroupCarouselTitleSpacing: CGFloat = 16
    static let TabGroupCarouselTopPadding: CGFloat = 16
    static let TabGroupCarouselBottomPadding: CGFloat = 8
    static let TabGroupCarouselTabSpacing: CGFloat = 12
}

struct SingleLevelTabCardsView: View {
    @EnvironmentObject var tabModel: TabCardModel
    @EnvironmentObject var tabGroupModel: TabGroupCardModel
    @Environment(\.cardSize) private var size
    @Environment(\.aspectRatio) private var aspectRatio

    let containerGeometry: GeometryProxy
    let incognito: Bool

    var body: some View {
        Group {
            ForEach(
                tabModel.getAllDetails(matchingIncognitoState: incognito).filter { tabCard in
                    (tabGroupModel.representativeTabs.contains(
                        tabCard.manager.get(for: tabCard.id)!)
                        || tabModel.allDetailsWithExclusionList.contains { $0.id == tabCard.id })
                }, id: \.id
            ) { details in
                if let rootID = details.manager.get(for: details.id)?.rootUUID,
                    let groupDetails = tabGroupModel.allDetails.first { $0.id == rootID }
                {
                    VStack(spacing: 0) {
                        HStack {
                            Symbol(decorative: .squareGrid2x2Fill)
                                .foregroundColor(.label)
                            Text(groupDetails.title)
                                .withFont(.labelLarge)
                                .foregroundColor(.label)
                            Spacer()
                        }.padding(.leading, CardGridUX.GridSpacing).frame(
                            height: SingleLevelTabCardsViewUX.TabGroupCarouselTitleSize)
                        ScrollView(.horizontal, showsIndicators: false) {
                            LazyHStack(
                                spacing: SingleLevelTabCardsViewUX.TabGroupCarouselTabSpacing
                            ) {
                                Color.clear.frame(
                                    width: CardGridUX.GridSpacing
                                        - SingleLevelTabCardsViewUX.TabGroupCarouselTabSpacing)
                                ForEach(groupDetails.allDetails, id: \.id) { childTabDetail in
                                    FittedCard(details: childTabDetail, dragToClose: false)
                                        .modifier(
                                            CardTransitionModifier(
                                                details: childTabDetail,
                                                containerGeometry: containerGeometry)
                                        )
                                        .id(childTabDetail.id)
                                }
                            }
                        }
                        .padding(.bottom, SingleLevelTabCardsViewUX.TabGroupCarouselBottomPadding)
                        .padding(.top, SingleLevelTabCardsViewUX.TabGroupCarouselTitleSpacing)
                    }
                    .padding(.top, SingleLevelTabCardsViewUX.TabGroupCarouselTopPadding)
                    .frame(
                        width: size * 2 + 3 * CardGridUX.GridSpacing,
                        height: size * aspectRatio + CardUX.HeaderSize
                            + SingleLevelTabCardsViewUX.TabGroupCarouselTopPadding
                            + SingleLevelTabCardsViewUX.TabGroupCarouselBottomPadding
                            + SingleLevelTabCardsViewUX.TabGroupCarouselTitleSize
                            + SingleLevelTabCardsViewUX.TabGroupCarouselTitleSpacing
                    )
                    .background(Color.secondarySystemFill)
                    .cornerRadius(
                        24,
                        corners: groupDetails.allDetails.count > 2
                            ? [.topLeft, .bottomLeft] : [.allCorners]
                    )
                    .padding(.horizontal, -CardGridUX.GridSpacing)
                    .id(groupDetails.id)
                    Color.clear.frame(width: size, height: size * aspectRatio + CardUX.HeaderSize)
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
        .transition(.identity)
    }
}
