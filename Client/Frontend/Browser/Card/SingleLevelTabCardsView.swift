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
/*
struct SingleLevelTabGroupView: View {

    let groupDetails: TabGroupCardDetails
    let details: TabCardDetails
    @Environment(\.cardSize) private var size
    @Environment(\.aspectRatio) private var aspectRatio

    let containerGeometry: GeometryProxy
    @State var isExpanded = false

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Symbol(decorative: .squareGrid2x2Fill)
                    .foregroundColor(.label)
                Text(groupDetails.title)
                    .withFont(.labelLarge)
                    .foregroundColor(.label)
                Spacer()
                Button {
                    isExpanded.toggle()
                } label: {
                    Label("caret", systemImage: "chevron.up")
                        .foregroundColor(.label)
                        .labelStyle(.iconOnly)
                        .rotationEffect(.degrees(isExpanded ? -180 : 0))
                        .padding()
                }
            }.padding(.leading, CardGridUX.GridSpacing).frame(
                height: SingleLevelTabCardsViewUX.TabGroupCarouselTitleSize)
            
            if isExpanded {
                LazyVGrid(columns: columns, spacing: CardGridUX.GridSpacing) {
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
            } else {
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
    }
}
 */


struct SingleLevelTabCardsView: View {
    @EnvironmentObject var tabModel: TabCardModel
    @EnvironmentObject var tabGroupModel: TabGroupCardModel
    @Environment(\.cardSize) private var size
    @Environment(\.aspectRatio) private var aspectRatio

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
                    /*
                    SingleLevelTabGroupView(
                        groupDetails: groupDetails,
                        details: details,
                        containerGeometry: containerGeometry
                    )
                    */
                    VStack(spacing: 0) {
                        HStack {
                            Symbol(decorative: .squareGrid2x2Fill)
                                .foregroundColor(.label)
                            Text(groupDetails.title)
                                .withFont(.labelLarge)
                                .foregroundColor(.label)
                            Spacer()
                            Button {
                                groupDetails.isExpanded.toggle()
                            } label: {
                                Label("caret", systemImage: "chevron.up")
                                    .foregroundColor(.label)
                                    .labelStyle(.iconOnly)
                                    .rotationEffect(.degrees(groupDetails.isExpanded ? -180 : 0))
                                    .padding()
                            }
                        }.padding(.leading, CardGridUX.GridSpacing).frame(
                            height: SingleLevelTabCardsViewUX.TabGroupCarouselTitleSize)
                        if groupDetails.isExpanded {
                            // plan to draw a lazVGrid here
                            /*
                             LazyVGrid(){
                                ForEach(...){
                             
                                }
                             }
                             */
                        } else {
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
                    
                    if groupDetails.isExpanded {
                        ForEach((0..<numBlankCardsToDraw(groupDetails)), id: \.self) { _ in
                            Color.blue.frame(width: size, height: size * aspectRatio + CardUX.HeaderSize)
                        }
                    }
                    else {
                        Color.blue.frame(width: size, height: size * aspectRatio + CardUX.HeaderSize)
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

    func numBlankCardsToDraw(_ groupDetails: TabGroupCardDetails) -> Int {
        let numCardsInTabGroup = groupDetails.allDetails.count
        return numCardsInTabGroup % 2 == 0 ? numCardsInTabGroup - 1 : numCardsInTabGroup
    }
}
