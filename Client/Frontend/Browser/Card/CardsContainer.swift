// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

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

struct TabGridContainer: View {
    let isIncognito: Bool
    let geom: GeometryProxy
    let scrollProxy: ScrollViewProxy

    @EnvironmentObject private var tabModel: TabCardModel
    @EnvironmentObject private var tabGroupModel: TabGroupCardModel
    @EnvironmentObject private var gridModel: GridModel
    @EnvironmentObject private var browserModel: BrowserModel

    @Environment(\.columns) private var columns

    var selectedRowId: TabCardModel.Row.ID? {
        tabModel.buildRows(
            incognito: isIncognito, tabGroupModel: tabGroupModel, maxCols: columns.count
        )
        .first { $0.cells.contains(where: \.isSelected) }?.id
    }

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
        Group {
            if FeatureFlag[.tabGroupsNewDesign] {
                LazyVStack(alignment: .leading, spacing: 0) {
                    SingleLevelTabCardsView(containerGeometry: geom, incognito: isIncognito)
                }
            } else {
                LazyVGrid(columns: columns, spacing: CardGridUX.GridSpacing) {
                    TabCardsView(containerGeometry: geom, incognito: isIncognito)
                }
            }
        }
        .environment(\.aspectRatio, CardUX.DefaultTabCardRatio)
        .environment(\.selectionCompletion) {
            if !FeatureFlag[.tabGroupsNewDesign] {
                guard tabGroupModel.detailedTabGroup == nil else {
                    return
                }
            }
            ClientLogger.shared.logCounter(
                .SelectTab,
                attributes: getLogCounterAttributesForTabs(
                    selectedTabIndex: tabModel.allDetails.firstIndex(
                        where: {
                            $0.id == tabModel.selectedTabID
                        })))
            browserModel.hideWithAnimation()
        }
        .padding(.vertical, CardGridUX.GridSpacing)
        .useEffect(deps: gridModel.needsScrollToSelectedTab) { _ in
            if FeatureFlag[.tabGroupsNewDesign] {
                if let selectedRowId = selectedRowId {
                    withAnimation(nil) {
                        scrollProxy.scrollTo(selectedRowId)
                    }
                }
            } else {
                if let selectedCardID = selectedCardID {
                    scrollProxy.scrollTo(selectedCardID)
                }
            }
        }
        .animation(nil)
    }
}

struct CardScrollContainer<Content: View>: View {
    let columns: [GridItem]
    @ViewBuilder var content: (ScrollViewProxy) -> Content

    @EnvironmentObject var spacesModel: SpaceCardModel
    @EnvironmentObject var gridModel: GridModel
    @EnvironmentObject var tabModel: TabCardModel

    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.verticalSizeClass) private var verticalSizeClass

    var landscapeMode: Bool {
        verticalSizeClass == .compact || horizontalSizeClass == .regular
    }

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            ScrollViewReader(content: content)
        }
        .accessibilityIdentifier("CardGrid")
        .accessibilityValue(
            Text(
                "\(tabModel.manager.isIncognito ? tabModel.manager.privateTabs.count : tabModel.manager.normalTabs.count) tabs"
            ))
        .environment(\.columns, columns)
        .introspectScrollView { scrollView in
            // This is to make sure the overlay card bleeds outside the horizontal and bottom
            // area in landscape mode. Clipping should be kept in portrait mode because
            // bottom tool bar needs to be shown.
            if landscapeMode {
                scrollView.clipsToBounds = false
            }
        }
    }
}

struct CardsContainer: View {
    @Default(.seenSpacesIntro) var seenSpacesIntro: Bool

    @EnvironmentObject var tabModel: TabCardModel
    @EnvironmentObject var tabGroupModel: TabGroupCardModel
    @EnvironmentObject var spacesModel: SpaceCardModel
    @EnvironmentObject var browserModel: BrowserModel
    @EnvironmentObject var gridModel: GridModel

    // Used to rebuild the scene when switching between portrait and landscape.
    @State var orientation: UIDeviceOrientation = .unknown
    @State var generationId: Int = 0
    @State var switchingState = false

    let columns: [GridItem]

    var body: some View {
        GeometryReader { geom in
            ZStack {
                // Spaces
                CardScrollContainer(columns: columns) { scrollProxy in
                    VStack(alignment: .leading) {
                        LazyVGrid(columns: columns, spacing: CardGridUX.GridSpacing) {
                            SpaceCardsView()
                                .environment(\.columns, columns)
                        }.animation(nil)
                    }
                    .padding(.vertical, CardGridUX.GridSpacing)
                    .useEffect(deps: browserModel.showGrid) { _ in
                        scrollProxy.scrollTo(
                            spacesModel.allDetails.first?.id ?? ""
                        )
                    }
                }
                .offset(x: (gridModel.switcherState == .spaces ? 0 : geom.size.width))
                .accessibilityElement(children: .contain)
                .accessibilityLabel("Spaces")
                .accessibilityHidden(gridModel.switcherState != .spaces)

                // Normal Tabs
                ZStack {
                    EmptyCardGrid(isIncognito: false)
                        .opacity(tabModel.normalDetails.isEmpty ? 1 : 0)

                    CardScrollContainer(columns: columns) { scrollProxy in
                        TabGridContainer(isIncognito: false, geom: geom, scrollProxy: scrollProxy)
                    }.onAppear {
                        gridModel.scrollToSelectedTab()
                    }
                }
                .offset(
                    x: (gridModel.switcherState == .tabs
                        ? (gridModel.isIncognito ? geom.size.width : 0) : -geom.size.width)
                )
                .accessibilityElement(children: .contain)
                .accessibilityLabel("Tabs")
                .accessibilityHidden(gridModel.switcherState != .tabs || gridModel.isIncognito)

                // Incognito Tabs
                ZStack {
                    EmptyCardGrid(isIncognito: true)
                        .opacity(tabModel.incognitoDetails.isEmpty ? 1 : 0)

                    CardScrollContainer(columns: columns) { scrollProxy in
                        TabGridContainer(isIncognito: true, geom: geom, scrollProxy: scrollProxy)
                    }.onAppear {
                        gridModel.scrollToSelectedTab()
                    }
                }
                .offset(
                    x: (gridModel.switcherState == .tabs
                        ? (gridModel.isIncognito ? 0 : -geom.size.width) : -geom.size.width)
                )
                .accessibilityElement(children: .contain)
                .accessibilityLabel("Incognito Tabs")
                .accessibilityHidden(gridModel.switcherState != .tabs || !gridModel.isIncognito)
            }
        }
        .id(generationId)
        .animation(
            .interactiveSpring(), value: "\(gridModel.switcherState) \(gridModel.isIncognito)"
        )
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
                    browserModel.showSpaces()
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
