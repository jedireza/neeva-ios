// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

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
    @Environment(\.columns) private var columns

    let containerGeometry: GeometryProxy
    let incognito: Bool

    var body: some View {
        ForEach(
            tabModel.buildRows(
                incognito: incognito, tabGroupModel: tabGroupModel, maxCols: columns.count)
        ) { row in
            HStack(spacing: CardGridUX.GridSpacing) {
                ForEach(row.cells) { details in
                    switch details {
                    case .tabGroupInline(let groupDetails):
                        CollapsableCardGroupView(
                            groupDetails: groupDetails, containerGeometry: containerGeometry
                        )
                        .padding(.horizontal, -CardGridUX.GridSpacing)
                    case .tabGroupGridRow(let groupDetails, let range):
                        // XXX
                        HStack(spacing: CardGridUX.GridSpacing) {
                            ForEach(groupDetails.allDetails[range]) { childTabDetail in
                                FittedCard(details: childTabDetail, dragToClose: false)
//                                    .matchedGeometryEffect(id: childTabDetail.id, in: cardGroup)
                                    .modifier(
                                        CardTransitionModifier(
                                            details: childTabDetail,
                                            containerGeometry: containerGeometry)
                                    )
                            }
                        }
                        .background(Color.gray)
                        .zIndex(groupDetails.allDetails[range].contains(where: \.isSelected) ? 1 : 0)
                    case .tab(let tabDetails):
                        FittedCard(details: tabDetails)
                            .modifier(
                                CardTransitionModifier(
                                    details: tabDetails, containerGeometry: containerGeometry)
                            )
                    }
                }
            }
            .padding(.horizontal, CardGridUX.GridSpacing)
            .zIndex(row.cells.contains(where: \.isSelected) ? 1 : 0)
        }
    }
}
