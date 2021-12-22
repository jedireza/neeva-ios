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
    @Environment(\.columns) private var columns

    let containerGeometry: GeometryProxy
    //@State var listtt = tabGroupModel.allDetails.count

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
                    
//                    let _ = print("Charles groupDetails.isShowingDetails \(groupDetails.isShowingDetails)")
                    if groupDetails.isShowingDetails && groupDetails.allDetails.count > 2 {
                        //draw top left card
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
                            FittedCard(details: groupDetails.allDetails[0])
                                .modifier(
                                    CardTransitionModifier(
                                        details: details, containerGeometry: containerGeometry)
                                )
                                .id(details.id)
                                .padding(.top, SingleLevelTabCardsViewUX.TabGroupCarouselTitleSpacing)

                        }
                        .padding(.top, SingleLevelTabCardsViewUX.TabGroupCarouselTopPadding)
                        .frame(
                            width: size * 1 + 1.5 * CardGridUX.GridSpacing,
                            height: size * aspectRatio + CardUX.HeaderSize
                                + SingleLevelTabCardsViewUX.TabGroupCarouselTopPadding
                                + SingleLevelTabCardsViewUX.TabGroupCarouselBottomPadding
                                + SingleLevelTabCardsViewUX.TabGroupCarouselTitleSize
                                + SingleLevelTabCardsViewUX.TabGroupCarouselTitleSpacing
                        )
                        .background(Color.secondarySystemFill)
                        .cornerRadius(
                            24, corners: .topLeft
                        )
                        .padding(.horizontal, -CardGridUX.GridSpacing)
                        
                        //draw top right card
                        VStack(spacing: 0) {
                            HStack {
                                Spacer()
                                Button {
                                    groupDetails.isShowingDetails.toggle()
                                } label: {
                                    Label("caret", systemImage: "chevron.up")
                                        .foregroundColor(.label)
                                        .labelStyle(.iconOnly)
                                        .rotationEffect(.degrees(groupDetails.isShowingDetails ? -180 : 0))
                                        .padding()
                                }
                            }.padding(.leading, CardGridUX.GridSpacing).frame(
                                height: SingleLevelTabCardsViewUX.TabGroupCarouselTitleSize)
                            FittedCard(details: groupDetails.allDetails[1])
                                .modifier(
                                    CardTransitionModifier(
                                        details: details, containerGeometry: containerGeometry)
                                )
                                .id(details.id)
                                .padding(.top, SingleLevelTabCardsViewUX.TabGroupCarouselTitleSpacing)

                        }
                        .padding(.top, SingleLevelTabCardsViewUX.TabGroupCarouselTopPadding)
                        .frame(
                            width: size * 1 + 1.5 * CardGridUX.GridSpacing,
                            height: size * aspectRatio + CardUX.HeaderSize
                                + SingleLevelTabCardsViewUX.TabGroupCarouselTopPadding
                                + SingleLevelTabCardsViewUX.TabGroupCarouselBottomPadding
                                + SingleLevelTabCardsViewUX.TabGroupCarouselTitleSize
                                + SingleLevelTabCardsViewUX.TabGroupCarouselTitleSpacing
                        )
                        .background(Color.secondarySystemFill)
                        .cornerRadius(
                            24, corners: .topRight
                        )
                        .padding(.horizontal, -CardGridUX.GridSpacing)
                        
                        
                        ForEach(groupDetails.allDetails.indices.suffix(from: 2).prefix(groupDetails.allDetails.count - 4), id:\.self) { index in
                            VStack(spacing: 0) {
                                FittedCard(details: groupDetails.allDetails[index])
                                    .modifier(
                                        CardTransitionModifier(
                                            details: details, containerGeometry: containerGeometry)
                                    )
                                    .id(details.id)
                            }
                            .padding(.top, SingleLevelTabCardsViewUX.TabGroupCarouselTopPadding)
                            .frame(
                                width: size * 1 + 1.5 * CardGridUX.GridSpacing,
                                height: size * aspectRatio + CardUX.HeaderSize
                                    + SingleLevelTabCardsViewUX.TabGroupCarouselTopPadding
                                    + SingleLevelTabCardsViewUX.TabGroupCarouselBottomPadding
                                    + SingleLevelTabCardsViewUX.TabGroupCarouselTitleSize
                                    + SingleLevelTabCardsViewUX.TabGroupCarouselTitleSpacing
                            )
                            .background(Color.secondarySystemFill)
                            .padding(.horizontal, -CardGridUX.GridSpacing)
                        }
                         
                        if groupDetails.allDetails.count % 2 == 0 {
                            //first draw bottom left, then bottom right
                            
                        } else {
                            // draw bottom right, then bottom left, and the Color.clear at the bottom right
                            Color.blue.frame(width: size, height: size * aspectRatio + CardUX.HeaderSize)
                        }
                    }
                    else {
                        VStack(spacing: 0) {
                            HStack {
                                Symbol(decorative: .squareGrid2x2Fill)
                                    .foregroundColor(.label)
                                Text(groupDetails.title)
                                    .withFont(.labelLarge)
                                    .foregroundColor(.label)
                                Spacer()
                                Button {
                                    groupDetails.isShowingDetails.toggle()
                                } label: {
                                    Label("caret", systemImage: "chevron.up")
                                        .foregroundColor(.label)
                                        .labelStyle(.iconOnly)
                                        .rotationEffect(.degrees(groupDetails.isShowingDetails ? -180 : 0))
                                        .padding()
                                }
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
