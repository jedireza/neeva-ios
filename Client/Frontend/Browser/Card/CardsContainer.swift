// Copyright Neeva. All rights reserved.

import SwiftUI

struct CardsContainer: View {
    @EnvironmentObject var tabModel: TabCardModel
    @EnvironmentObject var tabGroupModel: TabGroupCardModel
    @EnvironmentObject var gridModel: GridModel

    @Binding var switcherState: SwitcherViews
    let columns: [GridItem]

    var indexInsideTabGroupModel: Int? {
        let selectedTab = tabModel.manager.selectedTab!
        return tabGroupModel.allDetails
            .firstIndex(where: { $0.id == selectedTab.rootUUID })
    }

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            ScrollViewReader { value in
                LazyVGrid(columns: columns, spacing: CardGridUX.GridSpacing) {
                    if case .spaces = switcherState {
                        SpaceCardsView()
                            .environment(\.selectionCompletion) {
                                gridModel.hideWithNoAnimation()
                                switcherState = .tabs
                                value.scrollTo(tabModel.manager.selectedTab?.tabUUID)
                            }
                    } else {
                        TabCardsView().environment(\.selectionCompletion) {
                            withAnimation {
                                value.scrollTo(
                                    indexInsideTabGroupModel != nil ?
                                        tabModel.manager.selectedTab?.rootUUID :
                                        tabModel.manager.selectedTab?.tabUUID)
                            }
                            gridModel.animationThumbnailState = .visibleForTrayHidden
                        }
                    }
                }
                .padding(.top, 20)
                .useEffect(deps: tabModel.selectedTabID) { _ in
                    value.scrollTo(
                        indexInsideTabGroupModel != nil ?
                            tabModel.manager.selectedTab?.rootUUID :
                            tabModel.selectedTabID)
                }
                .background(GeometryReader { proxy in
                    Color.clear.preference(key: ScrollViewOffsetPreferenceKey.self,
                                           value:  proxy.frame(in: .named("scroll")).minY)
                })
            }
        }.coordinateSpace(name: "scroll")
        .onPreferenceChange(ScrollViewOffsetPreferenceKey.self) { scrollOffset in
            gridModel.scrollOffset = scrollOffset
        }
    }
}
