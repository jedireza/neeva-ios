// Copyright Neeva. All rights reserved.

import Combine
import Shared
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

    @StateObject private var recommendedSpacesModel = SpaceCardModel(
        bvc: SceneDelegate.getBVC(for: nil), manager: SpaceStore.suggested)

    let columns: [GridItem]

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            ScrollViewReader { value in
                VStack(alignment: .leading) {
                    if !recommendedSpacesModel.allDetails.isEmpty,
                        case .spaces = gridModel.switcherState
                    {
                        RecommendedSpacesView(recommendedSpacesModel: recommendedSpacesModel).id(
                            RecommendedSpacesView.ID)
                    }
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
                        value.scrollTo(
                            recommendedSpacesModel.allDetails.isEmpty
                                ? spacesModel.allDetails.first?.id ?? "" : RecommendedSpacesView.ID
                        )
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

struct RecommendedSpacesView: View {
    static let ID = "Recommended"
    @ObservedObject var recommendedSpacesModel: SpaceCardModel
    @EnvironmentObject var spaceModel: SpaceCardModel

    @State private var subscription: AnyCancellable? = nil

    var body: some View {
        Text("Suggested Public Spaces")
            .withFont(.headingMedium)
            .foregroundColor(.secondaryLabel)
            .minimumScaleFactor(0.6)
            .lineLimit(1)
            .padding()
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(spacing: 10) {
                ForEach(
                    recommendedSpacesModel.allDetails.filter { recommended in
                        !spaceModel.allDetails.contains(where: { $0.id == recommended.id })
                    }, id: \.id
                ) { details in
                    FittedCard(details: details)
                        .id(details.id + "suggested")
                        .environment(\.selectionCompletion) {
                            spaceModel.recommendedSpaceSelected(details: details)
                            ClientLogger.shared.logCounter(
                                .RecommendedSpaceVisited,
                                attributes: getLogCounterAttributesForSpaces(details: details))
                        }
                }
            }.padding(.bottom, 20).padding(.horizontal, 10)
        }
    }
}
