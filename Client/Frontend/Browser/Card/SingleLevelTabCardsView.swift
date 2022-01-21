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
    @Binding var tabGroupContainerFrame: CGRect
    @Binding var tabGroupCardFrame: CGRect

    var body: some View {
        ForEach(
            tabModel.buildRows(
                incognito: incognito, tabGroupModel: tabGroupModel, maxCols: columns.count)
        ) { row in
            HStack(spacing: CardGridUX.GridSpacing) {
                ForEach(row.cells) { details in
                    switch details {
                    case .tabGroup(let groupDetails):
                        CollapsableCardGroupView(
                            groupDetails: groupDetails, containerGeometry: containerGeometry, tabGroupCardFrame: $tabGroupCardFrame
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
            }
            .background(
                GeometryReader { geom in
                    Color.clear.useEffect(deps: geom.frame(in: .global)) { frame in
                        self.tabGroupContainerFrame = frame
                    }
                }
            )
            .padding(.horizontal, CardGridUX.GridSpacing)
            .zIndex(row.cells.contains(where: \.isSelected) ? 1 : 0)
        }
    }
}
