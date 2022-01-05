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
    @Environment(\.columns) private var columns

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
                    if groupDetails.isShowingDetails {
                        ForEach(
                            (0..<getTotalCards(groupDetails.allDetails.count, columns.count)),
                            id: \.self
                        ) { index in
                            VStack(spacing: 0) {
                                HStack {
                                    if isTopLeft(index, groupDetails.allDetails.count) {
                                        Symbol(decorative: .squareGrid2x2Fill)
                                            .foregroundColor(.label)
                                        Text(groupDetails.title)
                                            .withFont(.labelLarge)
                                            .foregroundColor(.label)
                                    }
                                    Spacer()
                                    if isTopRight(index, groupDetails.allDetails.count) {
                                        Button {
                                            groupDetails.isShowingDetails.toggle()
                                        } label: {
                                            Label("caret", systemImage: "chevron.up")
                                                .foregroundColor(.label)
                                                .labelStyle(.iconOnly)
                                                .rotationEffect(
                                                    .degrees(
                                                        groupDetails.isShowingDetails ? -180 : 0)
                                                )
                                                .padding()
                                        }
                                    }
                                }.padding(.leading, CardGridUX.GridSpacing).frame(
                                    height: SingleLevelTabCardsViewUX.TabGroupCarouselTitleSize)
                                if index < groupDetails.allDetails.count {
                                    FittedCard(details: groupDetails.allDetails[index])
                                        .modifier(
                                            CardTransitionModifier(
                                                details: details,
                                                containerGeometry: containerGeometry)
                                        )
                                        .id(details.id)
                                        .padding(
                                            .top,
                                            SingleLevelTabCardsViewUX.TabGroupCarouselTitleSpacing)
                                }
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
                                24,
                                corners: isTopLeft(index, groupDetails.allDetails.count)
                                    ? .topLeft
                                    : (isTopRight(index, groupDetails.allDetails.count)
                                        ? .topRight
                                        : (isBottomLeft(index, groupDetails.allDetails.count)
                                            ? .bottomLeft
                                            : (isBottomRight(index, groupDetails.allDetails.count)
                                                ? .bottomRight : [])))
                            )
                            .padding(.horizontal, -CardGridUX.GridSpacing)

                        }
                    } else {
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
                                        .rotationEffect(
                                            .degrees(groupDetails.isShowingDetails ? -180 : 0)
                                        )
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
                            .padding(
                                .bottom, SingleLevelTabCardsViewUX.TabGroupCarouselBottomPadding
                            )
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

                        Color.clear.frame(
                            width: size, height: size * aspectRatio + CardUX.HeaderSize)
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

    func getTotalCards(_ total: Int, _ columns: Int) -> Int {
        return Int(round((total * 1.0) / columns)) * columns
    }

    func isTopLeft(_ index: Int, _ total: Int) -> Bool {
        let row = Int(round((total * 1.0) / columns.count))
        return index / row == 0 && index % columns.count == 0

    }

    func isTopRight(_ index: Int, _ total: Int) -> Bool {
        let row = Int(round((total * 1.0) / columns.count))
        return index / row == 0 && index % columns.count == columns.count - 1
    }

    func isBottomLeft(_ index: Int, _ total: Int) -> Bool {
        let row = Int(round((total * 1.0) / columns.count))
        return index / row == row - 1 && index % columns.count == 0
    }

    func isBottomRight(_ index: Int, _ total: Int) -> Bool {
        let row = Int(round((total * 1.0) / columns.count))
        return index / row == row - 1 && index % columns.count == columns.count - 1
    }
}
