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

enum TimeFilter: String, CaseIterable {
    case today = "Today"
    case lastWeek = "Last Week"
}

struct SingleLevelTabCardsView: View {
    @EnvironmentObject var tabModel: TabCardModel
    @EnvironmentObject private var browserModel: BrowserModel
    @Environment(\.columns) private var columns
    
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.verticalSizeClass) private var verticalSizeClass

    var landscapeMode: Bool {
        verticalSizeClass == .compact || horizontalSizeClass == .regular
    }

    let containerGeometry: GeometryProxy
    let incognito: Bool

    var body: some View {
        ForEach(TimeFilter.allCases, id: \.self) { time in
            HStack {
                VStack(alignment: .leading) {
                    Text(time.rawValue)
                        .withFont(.labelLarge)
                        .foregroundColor(.label)
                        .padding(.leading, 20)
                        .padding(.top, 12)
                    gettimeLineCardsView(time: time.rawValue)
                }
                Spacer()
            }
            .background(Color.background)
        }
        .padding(.top, 8)
    }

    func gettimeLineCardsView(time: String) -> some View {
        return ForEach(
            tabModel.getRows(incognito: incognito, byTime: time)
        ) { row in
            HStack(spacing: CardGridUX.GridSpacing) {
                ForEach(row.cells) { details in
                    switch details {
                    case .tabGroupInline(let groupDetails):
                        CollapsedCardGroupView(
                            groupDetails: groupDetails, containerGeometry: containerGeometry,
                            rowIndex: row.index,
                            nextToCells: row.multipleCellTypes
                        )
                        .padding(.horizontal, -CardGridUX.GridSpacing)
                        .padding(.bottom, CardGridUX.GridSpacing)
                        .zIndex(groupDetails.allDetails.contains(where: \.isSelected) ? 1 : 0)
                    case .tabGroupGridRow(let groupDetails, let range):
                        ExpandedCardGroupRowView(
                            groupDetails: groupDetails, containerGeometry: containerGeometry,
                            range: range, rowIndex: row.index, nextToCells: false
                        )
                        .padding(.horizontal, -CardGridUX.GridSpacing)
                        .padding(
                            .bottom,
                            lastRowTabGroup(range, groupDetails) ? CardGridUX.GridSpacing : 0)
                    case .tab(let tabDetails):
                        FittedCard(details: tabDetails)
                            .modifier(
                                CardTransitionModifier(
                                    details: tabDetails, containerGeometry: containerGeometry)
                            )
                            .padding(.bottom, CardGridUX.GridSpacing)
                            .environment(\.selectionCompletion) {
                                ClientLogger.shared.logCounter(
                                    .SelectTab,
                                    attributes: getLogCounterAttributesForTabs(
                                        selectedTabRow: row.index))
                                browserModel.hideWithAnimation()
                            }
                    }
                }
            }
            .padding(.horizontal, CardGridUX.GridSpacing)
            .zIndex(row.cells.contains(where: \.isSelected) ? 1 : 0)
        }
    }

    func lastRowTabGroup(_ rowInfo: Range<Int>, _ groupDetails: TabGroupCardDetails) -> Bool {
        return rowInfo.last == groupDetails.allDetails.count - 1
    }
}
