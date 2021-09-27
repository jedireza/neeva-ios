// Copyright Neeva. All rights reserved.

import Combine
import Defaults
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
        get { self[ColumnsKey.self] }
        set { self[ColumnsKey.self] = newValue }
    }
}
struct CardsContainer: View {
    @Default(.seenSpacesIntro) var seenSpacesIntro: Bool

    @EnvironmentObject var tabModel: TabCardModel
    @EnvironmentObject var tabGroupModel: TabGroupCardModel
    @EnvironmentObject var spacesModel: SpaceCardModel
    @EnvironmentObject var gridModel: GridModel

    @StateObject private var recommendedSpacesModel = SpaceCardModel(manager: SpaceStore.suggested)

    let columns: [GridItem]

    var body: some View {
        ZStack {
            GeometryReader { geom in
                ScrollView(.vertical, showsIndicators: false) {
                    ScrollViewReader { spaceScrollValue in
                        VStack(alignment: .leading) {
                            if !recommendedSpacesModel.allDetails.isEmpty,
                                case .spaces = gridModel.switcherState
                            {
                                RecommendedSpacesView(
                                    recommendedSpacesModel: recommendedSpacesModel
                                ).id(
                                    RecommendedSpacesView.ID)
                            }
                            LazyVGrid(columns: columns, spacing: CardGridUX.GridSpacing) {
                                SpaceCardsView()
                                    .environment(\.columns, columns)
                            }.animation(nil)
                        }.padding(.vertical, CardGridUX.GridSpacing)
                            .useEffect(
                                deps: gridModel.isHidden
                            ) { _ in
                                spaceScrollValue.scrollTo(
                                    recommendedSpacesModel.allDetails.isEmpty
                                        ? spacesModel.allDetails.first?.id ?? ""
                                        : RecommendedSpacesView.ID
                                )
                            }
                    }
                }.offset(x: gridModel.switcherState == .spaces ? 0 : geom.size.width)
                    .animation(.easeInOut)
                ScrollView(.vertical, showsIndicators: false) {
                    ScrollViewReader { value in
                        LazyVGrid(columns: columns, spacing: CardGridUX.GridSpacing) {
                            TabCardsView()
                                .environment(\.aspectRatio, CardUX.DefaultTabCardRatio)
                                .environment(\.selectionCompletion) {
                                    guard tabGroupModel.detailedTabGroup == nil else {
                                        return
                                    }

                                    gridModel.hideWithAnimation()
                                }
                        }.background(
                            GeometryReader { proxy in
                                Color.clear.preference(
                                    key: ScrollViewOffsetPreferenceKey.self,
                                    value: proxy.frame(in: .named("scroll")).minY)
                            }
                        )
                        .padding(.vertical, CardGridUX.GridSpacing)
                        .useEffect(
                            deps: tabModel.selectedTabID
                        ) { _ in
                            // TODO Find a better signal to not necessitate the async post here.
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                value.scrollTo(tabModel.selectedTabID)
                                spacesModel.manager.refresh()
                            }
                        }
                    }
                }.offset(x: gridModel.switcherState == .tabs ? 0 : -geom.size.width)
                    .animation(.easeInOut)
                    .coordinateSpace(name: "scroll")
                    .onPreferenceChange(ScrollViewOffsetPreferenceKey.self) { scrollOffset in
                        gridModel.scrollOffset = scrollOffset
                    }
            }
        }.onChange(of: gridModel.switcherState) { value in
            guard case .spaces = value, !seenSpacesIntro else {
                return
            }
            SceneDelegate.getBVC(with: tabModel.manager.scene).showModal(
                style: .spaces,
                content: {
                    SpacesIntroOverlayContent()
                },
                onDismiss: {
                    gridModel.showSpaces()
                })
            seenSpacesIntro = true
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
