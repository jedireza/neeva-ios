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

enum GridScrollContainerCategory {
    case incognitoTabs
    case normalTabs
    case spaces
}

struct ScrollContainer: View {
    let columns: [GridItem]
    let category: GridScrollContainerCategory

    @EnvironmentObject var tabModel: TabCardModel
    @EnvironmentObject var tabGroupModel: TabGroupCardModel
    @EnvironmentObject var spacesModel: SpaceCardModel
    @EnvironmentObject var gridModel: GridModel

    var selectedCardID: String? {
        if let details = tabModel.allDetailsWithExclusionList.first(where: \.isSelected) {
            return details.id
        }
        if let details = tabGroupModel.allDetails.first(where: \.isSelected) {
            return details.id
        }
        return nil
    }

    var body: some View {
        GeometryReader { scrollGeometry in
            ScrollView(.vertical, showsIndicators: false) {
                ScrollViewReader { scrollProxy in
                    switch category {
                    case .incognitoTabs, .normalTabs:
                        LazyVGrid(columns: columns, spacing: CardGridUX.GridSpacing) {
                            Group {
                                if FeatureFlag[.tabGroupsNewDesign] {
                                    SingleLevelTabCardsView(
                                        containerGeometry: scrollGeometry,
                                        incognito: category == .incognitoTabs)
                                } else {
                                    TabCardsView(
                                        containerGeometry: scrollGeometry,
                                        incognito: category == .incognitoTabs)
                                }
                            }
                            .environment(\.aspectRatio, CardUX.DefaultTabCardRatio)
                            .environment(\.selectionCompletion) {
                                guard tabGroupModel.detailedTabGroup == nil else {
                                    return
                                }
                                ClientLogger.shared.logCounter(
                                    .SelectTab,
                                    attributes: getLogCounterAttributesForTabs(
                                        selectedTabIndex: tabModel.allDetails.firstIndex(
                                            where: {
                                                $0.id == tabModel.selectedTabID
                                            })))
                                gridModel.hideWithAnimation()
                            }
                        }
                        .padding(.vertical, CardGridUX.GridSpacing)
                        .useEffect(deps: gridModel.needsScrollToSelectedTab) { _ in
                            if let selectedCardID = selectedCardID {
                                scrollProxy.scrollTo(selectedCardID)
                            }
                        }
                    case .spaces:
                        VStack(alignment: .leading) {
                            LazyVGrid(columns: columns, spacing: CardGridUX.GridSpacing) {
                                SpaceCardsView()
                                    .environment(\.columns, columns)
                            }.animation(nil)
                        }
                        .padding(.vertical, CardGridUX.GridSpacing)
                        .useEffect(
                            deps: gridModel.isHidden
                        ) { _ in
                            scrollProxy.scrollTo(
                                spacesModel.allDetails.first?.id ?? ""
                            )
                        }
                    }
                }
            }
        }
        .environment(\.columns, columns)
        .animation(gridModel.animateDetailTransitions ? .easeInOut : nil)
    }
}

struct CardsContainer: View {
    @Default(.seenSpacesIntro) var seenSpacesIntro: Bool

    @EnvironmentObject var tabModel: TabCardModel
    @EnvironmentObject var tabGroupModel: TabGroupCardModel
    @EnvironmentObject var spacesModel: SpaceCardModel
    @EnvironmentObject var gridModel: GridModel

    // Used to rebuild the scene when switching between portrait and landscape.
    @State var orientation: UIDeviceOrientation = .unknown
    @State var generationId: Int = 0
    @State var switchingState = false

    let columns: [GridItem]

    var body: some View {
        ZStack {
            GeometryReader { geom in
                // Spaces
                ScrollContainer(columns: columns, category: .spaces)
                    .offset(
                        x: (gridModel.switcherState == .spaces ? 0 : geom.size.width))

                // Normal Tabs
                ZStack {
                    EmptyCardGrid(isIncognito: false)
                        .opacity(tabModel.normalDetails.isEmpty ? 1 : 0)

                    ScrollContainer(columns: columns, category: .normalTabs)
                        .onAppear {
                            gridModel.scrollToSelectedTab()
                        }
                }.offset(
                    x: (gridModel.switcherState == .tabs
                        ? (gridModel.isIncognito ? geom.size.width : 0) : -geom.size.width)
                )

                // Incognito Tabs
                ZStack {
                    EmptyCardGrid(isIncognito: true)
                        .opacity(tabModel.incognitoDetails.isEmpty ? 1 : 0)

                    ScrollContainer(columns: columns, category: .incognitoTabs)
                        .onAppear {
                            gridModel.scrollToSelectedTab()
                        }
                }.offset(
                    x: (gridModel.switcherState == .tabs
                        ? (gridModel.isIncognito ? 0 : -geom.size.width) : -geom.size.width)
                )
            }
        }
        .id(generationId)
        .animation(.easeInOut)
        .onChange(of: gridModel.switcherState) { value in
            guard case .spaces = value, !seenSpacesIntro, !gridModel.isLoading else {
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
        .onReceive(
            NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification)
        ) { _ in
            if self.orientation.isLandscape != UIDevice.current.orientation.isLandscape {
                generationId += 1
            }
            self.orientation = UIDevice.current.orientation
        }
    }
}

func getLogCounterAttributesForTabs(selectedTabIndex: Int?) -> [ClientLogCounterAttribute] {
    var attributes = EnvironmentHelper.shared.getAttributes()
    attributes.append(
        ClientLogCounterAttribute(
            key: LogConfig.TabsAttribute.selectedTabIndex,
            value: String(selectedTabIndex ?? 0)))
    return attributes
}

struct RecommendedSpacesView: View {
    static let ID = "Recommended"
    @StateObject private var recommendedSpacesModel = SpaceCardModel(manager: SpaceStore.suggested)
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
