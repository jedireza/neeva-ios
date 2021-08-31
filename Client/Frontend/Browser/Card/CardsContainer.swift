// Copyright Neeva. All rights reserved.

import SwiftUI

extension EnvironmentValues {
    private struct ColumnsKey: EnvironmentKey {
        static var defaultValue: [GridItem] = Array(
            repeating:
                GridItem(
                    .fixed(CardUX.DefaultCardSize),
                    spacing: CardGridUX.GridSpacing),
            count: 2)
    }

    public var columns: [GridItem] {
        get { self[ColumnsKey] }
        set { self[ColumnsKey] = newValue }
    }
}
struct CardsContainer: View {
    @EnvironmentObject var tabModel: TabCardModel
    @EnvironmentObject var spacesModel: SpaceCardModel
    @EnvironmentObject var gridModel: GridModel

    let columns: [GridItem]

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            ScrollViewReader { value in
                LazyVGrid(columns: columns, spacing: CardGridUX.GridSpacing) {
                    if case .spaces = gridModel.switcherState {
                        SpaceCardsView()
                            .environment(\.columns, columns)
                    } else {
                        TabCardsView().environment(\.selectionCompletion) {
                            withAnimation {
                                value.scrollTo(tabModel.selectedTabID)
                            }
                            
                            gridModel.hideWithAnimation()
                        }
                    }
                }
                .padding(.vertical, CardGridUX.GridSpacing)
                .useEffect(
                    deps: tabModel.selectedTabID, gridModel.isHidden, gridModel.switcherState
                ) { _, _, _ in
                    switch gridModel.switcherState {
                    case .tabs:
                        value.scrollTo(tabModel.selectedTabID)
                    case .spaces:
                        spacesModel.manager.refresh()
                        value.scrollTo(spacesModel.allDetails.first?.id ?? "")
                    }
                }
                .background(
                    GeometryReader { proxy in
                        Color.clear.preference(
                            key: ScrollViewOffsetPreferenceKey.self,
                            value: proxy.frame(in: .named("scroll")).minY)
                    })
            }
        }.coordinateSpace(name: "scroll")
            .onPreferenceChange(ScrollViewOffsetPreferenceKey.self) { scrollOffset in
                gridModel.scrollOffset = scrollOffset
            }
    }
}
