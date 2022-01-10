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
    @Environment(\.columns) private var columns

    let containerGeometry: GeometryProxy
    let incognito: Bool

    var body: some View {
        ForEach(tabModel.buildRows(tabGroupModel: tabGroupModel, maxCols: columns.count)) { row in
            HStack(spacing: CardGridUX.GridSpacing) {
                ForEach(row.cells) { details in
                    switch details {
                    case .tabGroup(let groupDetails):
                        CollapsableCardGroupView(
                            groupDetails: groupDetails, containerGeometry: containerGeometry
                        )
                            .padding(.horizontal, -CardGridUX.GridSpacing)
                    case .tab(let tabDetails):
                        FittedCard(details: tabDetails)
                            .modifier(
                                CardTransitionModifier(
                                    details: tabDetails, containerGeometry: containerGeometry)
                            )
                    }
                }
            }.padding(.horizontal, CardGridUX.GridSpacing)
        }
    }
}
