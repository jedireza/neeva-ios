// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Shared
import SwiftUI

enum SwitcherViews: String, CaseIterable {
    case tabs = "Tabs"
    case spaces = "Spaces"
}

enum CardGridUX {
    static let PickerPadding: CGFloat = 20
    static let GridSpacing: CGFloat = 20
}

struct CardGrid: View {
    @EnvironmentObject var browserModel: BrowserModel
    @EnvironmentObject var tabModel: TabCardModel
    @EnvironmentObject var tabGroupModel: TabGroupCardModel
    @EnvironmentObject var spaceModel: SpaceCardModel
    @EnvironmentObject var gridModel: GridModel
    @EnvironmentObject var web3Model: Web3Model

    @State private var cardSize: CGFloat = CardUX.DefaultCardSize
    @State private var columnCount = 2
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.verticalSizeClass) private var verticalSizeClass

    @State var detailDragOffset: CGFloat = 0

    var topToolbar: Bool {
        verticalSizeClass == .compact || horizontalSizeClass == .regular
    }

    var columns: [GridItem] {
        return Array(
            repeating:
                GridItem(
                    .fixed(cardSize),
                    spacing: CardGridUX.GridSpacing, alignment: .leading),
            count: columnCount)
    }

    var cardContainerBackground: some View {
        Color.background.ignoresSafeArea()
    }

    @ViewBuilder var cardContainer: some View {
        VStack(spacing: 0) {
            CardsContainer(
                columns: columns
            )
            .environment(\.cardSize, cardSize)
            Spacer(minLength: 0)
        }
        .background(cardContainerBackground)
    }

    @ViewBuilder var grid: some View {
        cardContainer
    }

    @ViewBuilder
    var loadingIndicator: some View {
        ZStack {
            Color.TrayBackground
                .opacity(0.5)

            RoundedRectangle(cornerRadius: 8)
                .foregroundColor(Color(UIColor.DefaultBackground))
                .shadow(color: .black.opacity(0.1), radius: 12)
                .frame(width: 50, height: 50)

            ProgressView()
        }
    }

    func updateCardSize(width: CGFloat, topToolbar: Bool) {
        if width > 1000 {
            columnCount = 4
        } else {
            columnCount = topToolbar ? 3 : 2
        }
        self.cardSize = (width - (columnCount + 1) * CardGridUX.GridSpacing) / columnCount
    }

    var body: some View {
        GeometryReader { geom in
            ZStack {
                grid
                    .offset(
                        x: (spaceModel.detailedSpace == nil
                            && tabGroupModel.detailedTabGroup == nil
                            && !web3Model.showingWalletDetails
                            || FeatureFlag[.tabGroupsNewDesign])
                            ? 0 : -(geom.size.width - detailDragOffset) / 5, y: 0
                    )
                    .background(
                        browserModel.cardTransition == .hidden
                            ? Color.TrayBackground : Color.clear
                    )
                    .modifier(
                        SwipeToSwitchToSpacesGesture(gridModel: gridModel, tabModel: tabModel))

                if gridModel.isLoading {
                    loadingIndicator
                        .ignoresSafeArea()
                }

                Group {
                    if let spaceDetails = spaceModel.detailedSpace {
                        DetailView(primitive: spaceDetails) {
                            withAnimation(.easeInOut(duration: 0.4)) {
                                gridModel.showingDetailView = false
                                detailDragOffset = geom.size.width
                                spaceModel.detailedSpace = nil
                            }
                        }
                        .frame(width: geom.size.width, height: geom.size.height)
                        .background(
                            Color.groupedBackground.edgesIgnoringSafeArea([
                                .bottom, .horizontal,
                            ])
                        )
                        .transition(gridModel.animateDetailTransitions ? .flipFromRight : .identity)
                    }
                    if !FeatureFlag[.tabGroupsNewDesign] {
                        if let tabGroupDetails = tabGroupModel.detailedTabGroup {
                            DetailView(primitive: tabGroupDetails) {
                                gridModel.showingDetailView = false
                                withAnimation(.easeInOut(duration: 0.4)) {
                                    detailDragOffset = geom.size.width
                                    tabGroupModel.detailedTabGroup = nil
                                }
                            }
                            .frame(width: geom.size.width, height: geom.size.height)
                            .background(
                                Color.groupedBackground.edgesIgnoringSafeArea([
                                    .bottom, .horizontal,
                                ])
                            )
                            .transition(
                                gridModel.animateDetailTransitions ? .flipFromRight : .identity
                            )
                            .environment(\.cardSize, cardSize)
                            .environment(\.columns, columns)
                        }
                    }
                    if web3Model.showingWalletDetails {
                        WalletDetailView()
                            .frame(width: geom.size.width, height: geom.size.height)
                            .background(
                                Color.groupedBackground.edgesIgnoringSafeArea([
                                    .bottom, .horizontal,
                                ])
                            )
                            .transition(
                                gridModel.animateDetailTransitions ? .flipFromRight : .identity
                            )
                            .environment(\.cardSize, cardSize)
                            .environment(\.aspectRatio, CardUX.DefaultTabCardRatio)
                    }
                }.modifier(
                    DraggableDetail(
                        detailDragOffset: $detailDragOffset,
                        width: geom.size.width))
            }
            .useEffect(
                deps: geom.size.width, topToolbar, perform: updateCardSize
            )
            .useEffect(deps: spaceModel.detailedSpace) { value in
                gridModel.showingDetailView = value != nil
            }
            .useEffect(deps: tabGroupModel.detailedTabGroup) { value in
                gridModel.showingDetailView = value != nil
            }
        }
        .ignoresSafeArea(.keyboard)
        .accessibilityAction(.escape) {
            browserModel.hideWithAnimation()
        }
        .onAnimationCompleted(
            for: browserModel.showGrid,
            completion: browserModel.onCompletedCardTransition
        )
        .useEffect(deps: browserModel.cardTransition) { _ in
            // Ensure that the `Card` for the selected tab is visible. This way its
            // `CardTransitionModifier` will be visible and run the animation.
            if browserModel.cardTransition != .hidden {
                if !tabModel.allDetails.isEmpty {
                    gridModel.scrollToSelectedTab()
                }
                // Allow some time for the `Card` to get created if it was previously
                // not visible.
                DispatchQueue.main.async {
                    if browserModel.cardTransition != .hidden {
                        withAnimation(CardTransitionUX.animation) {
                            browserModel.showGrid =
                                (browserModel.cardTransition == .visibleForTrayShow)
                        }
                    }
                }
            }
        }
    }
}

private struct DraggableDetail: ViewModifier {
    static let Threshold: CGFloat = 100
    static let DraggableWidth: CGFloat = 50
    @Binding var detailDragOffset: CGFloat
    let width: CGFloat

    @EnvironmentObject var gridModel: GridModel
    @EnvironmentObject var spaceModel: SpaceCardModel
    @EnvironmentObject var tabGroupModel: TabGroupCardModel
    @EnvironmentObject var web3Model: Web3Model

    func body(content: Content) -> some View {
        content
            .offset(x: detailDragOffset, y: 0)
            .onAnimationCompleted(for: detailDragOffset) {
                if detailDragOffset == width {
                    spaceModel.detailedSpace = nil
                    tabGroupModel.detailedTabGroup = nil
                    web3Model.showingWalletDetails = false
                    detailDragOffset = 0
                    gridModel.showingDetailView = false
                }
            }
            .simultaneousGesture(
                DragGesture(minimumDistance: DraggableDetail.DraggableWidth)
                    .onChanged { value in
                        if detailDragOffset != 0
                            || (value.startLocation.x < DraggableDetail.DraggableWidth
                                && value.translation.width > 0
                                && abs(value.translation.width)
                                    > abs(value.translation.height))
                        {
                            detailDragOffset = value.translation.width
                        }
                    }
                    .onEnded { value in
                        withAnimation(.easeInOut(duration: 0.4)) {
                            if abs(detailDragOffset) > DraggableDetail.Threshold {
                                detailDragOffset = width
                            } else {
                                detailDragOffset = 0
                            }
                        }
                    }
            )
    }
}

struct GridPicker: View {
    var isInToolbar = false

    @EnvironmentObject var gridModel: GridModel
    @EnvironmentObject var switcherToolbarModel: SwitcherToolbarModel
    @EnvironmentObject var browserModel: BrowserModel

    @State var selectedIndex: Int = 1

    @ViewBuilder
    var picker: some View {
        HStack {
            Spacer()

            SegmentedPicker(
                segments: [
                    Segment(
                        symbol: Symbol(.incognito, weight: .medium, label: "Incognito Tabs"),
                        selectedIconColor: .background,
                        selectedColor: .label,
                        selectedAction: { gridModel.switchToTabs(incognito: true) }),
                    Segment(
                        symbol: Symbol(.squareOnSquare, weight: .medium, label: "Normal Tabs"),
                        selectedIconColor: .white,
                        selectedColor: Color.ui.adaptive.blue,
                        selectedAction: { gridModel.switchToTabs(incognito: false) }),
                    Segment(
                        symbol: Symbol(.bookmarkOnBookmark, label: "Spaces"),
                        selectedIconColor: .white, selectedColor: Color.ui.adaptive.blue,
                        selectedAction: gridModel.switchToSpaces),
                ], selectedSegmentIndex: $selectedIndex, dragOffset: switcherToolbarModel.dragOffset
            )
            .useEffect(deps: gridModel.switcherState) { _ in
                switch gridModel.switcherState {
                case .tabs:
                    if switcherToolbarModel.dragOffset == nil {
                        selectedIndex = 1
                    }
                case .spaces:
                    if switcherToolbarModel.dragOffset == nil {
                        selectedIndex = 2
                    }

                    if gridModel.isIncognito {
                        gridModel.tabCardModel.manager.toggleIncognitoMode(
                            fromTabTray: true, openLazyTab: false)
                    }
                }
            }
            .useEffect(deps: gridModel.isIncognito) { isIncognito in
                if gridModel.switcherState == .tabs && switcherToolbarModel.dragOffset == nil {
                    selectedIndex = isIncognito ? 0 : 1
                }
            }

            Spacer()
        }
    }

    var body: some View {
        picker
            .frame(height: gridModel.pickerHeight)
            .background(
                (!isInToolbar
                    ? Color.background : Color.clear)
                    .ignoresSafeArea()
            )
            .opacity(browserModel.showGrid ? 1 : 0)
            .animation(.easeOut)
    }
}

struct SwipeToSwitchToSpacesGesture: ViewModifier {
    let gridModel: GridModel
    let tabModel: TabCardModel
    var fromPicker: Bool = false

    @EnvironmentObject var switcherToolbarModel: SwitcherToolbarModel

    private var gesture: some Gesture {
        DragGesture()
            .onChanged({ value in
                let horizontalAmount = value.translation.width as CGFloat

                // Divide by 2.5 to follow drag more accurately
                horizontalOffsetChanged(
                    fromPicker ? horizontalAmount : (-horizontalAmount / 2.5))
            })
            .onEnded { value in
                horizontalOffsetChanged(nil)
            }
    }

    private func horizontalOffsetChanged(_ offset: CGFloat?) {
        switcherToolbarModel.dragOffset = offset
    }

    func body(content: Content) -> some View {
        if fromPicker {
            content.simultaneousGesture(gesture)
        } else {
            content.gesture(gesture)
        }
    }
}
