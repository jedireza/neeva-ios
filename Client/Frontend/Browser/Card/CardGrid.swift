// Copyright Neeva. All rights reserved.

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
    @EnvironmentObject var tabModel: TabCardModel
    @EnvironmentObject var tabGroupModel: TabGroupCardModel
    @EnvironmentObject var spaceModel: SpaceCardModel
    @EnvironmentObject var gridModel: GridModel

    @State private var cardSize: CGFloat = CardUX.DefaultCardSize
    @State private var columnCount = 2
    @State private var geom: (size: CGSize, safeAreaInsets: EdgeInsets)?
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.verticalSizeClass) private var verticalSizeClass

    var topToolbar: Bool {
        verticalSizeClass == .compact || horizontalSizeClass == .regular
    }

    var columns: [GridItem] {
        return Array(
            repeating:
                GridItem(
                    .fixed(cardSize),
                    spacing: CardGridUX.GridSpacing),
            count: columnCount)
    }

    @ViewBuilder var transitionAnimator: some View {
        if gridModel.animationThumbnailState != .hidden || gridModel.isHidden,
            let geom = geom
        {
            CardTransitionAnimator(
                cardSize: cardSize,
                columnCount: columnCount,
                containerSize: geom.size,
                safeAreaInsets: geom.safeAreaInsets,
                topToolbar: topToolbar
            )
        }
    }

    @ViewBuilder var cardContainerBackground: some View {
        if tabModel.isCardGridEmpty, case .tabs = gridModel.switcherState {
            EmptyCardGrid()
        } else {
            Color(UIColor.TrayBackground).ignoresSafeArea()
        }
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

    @ViewBuilder var topBar: some View {
        if topToolbar {
            SwitcherToolbarView(top: true, isEmpty: tabModel.isCardGridEmpty)
        } else {
            GridPicker()
        }
    }

    @ViewBuilder var grid: some View {
        VStack(spacing: 0) {
            topBar
            cardContainer
            if !topToolbar {
                SwitcherToolbarView(top: false, isEmpty: tabModel.isCardGridEmpty)
                    .frame(height: UIConstants.ToolbarHeight)
            }
        }
    }

    func updateCardSize(width: CGFloat, isHidden: Bool, topToolbar: Bool) {
        if width > 1000 {
            columnCount = 4
        } else {
            switch horizontalSizeClass {
            case .regular:
                columnCount = 3
            default: columnCount = topToolbar ? 3 : 2
            }
        }
        self.cardSize = (width - (columnCount + 1) * CardGridUX.GridSpacing) / columnCount
    }

    var body: some View {
        GeometryReader { geom in
            ZStack {
                grid

                if let spaceDetails = spaceModel.detailedSpace {
                    DetailView(primitive: spaceDetails)
                        .frame(width: geom.size.width, height: geom.size.height)
                        .background(
                            Color.groupedBackground.edgesIgnoringSafeArea([.bottom, .horizontal])
                        )
                        .transition(.flipFromRight)
                }

                if let tabGroupDetails = tabGroupModel.detailedTabGroup {
                    DetailView(primitive: tabGroupDetails)
                        .frame(width: geom.size.width, height: geom.size.height)
                        .background(
                            Color.groupedBackground.edgesIgnoringSafeArea([.bottom, .horizontal])
                        )
                        .transition(.flipFromRight)
                        .opacity(gridModel.isHidden ? 0 : 1)
                        .animation(
                            gridModel.animationThumbnailState == .visibleForTrayShow
                                ? nil : .easeInOut
                        )
                        .environment(\.cardSize, cardSize)
                        .environment(\.columns, columns)
                }
            }
            .useEffect(
                deps: geom.size.width, gridModel.isHidden, topToolbar, perform: updateCardSize
            )
            .useEffect(deps: geom.size, geom.safeAreaInsets) { self.geom = ($0, $1) }
            .onReceive(NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification)) { _ in
                self.geom = (geom.size, geom.safeAreaInsets)
            }
        }
        .overlay(transitionAnimator, alignment: .top)
        .ignoresSafeArea(.keyboard)
        .accessibilityAction(.escape) {
            gridModel.hideWithAnimation()
        }
    }
}

struct GridPicker: View {
    @EnvironmentObject var gridModel: GridModel
    @EnvironmentObject var tabModel: TabCardModel

    var body: some View {
        Picker("", selection: $gridModel.switcherState) {
            ForEach(SwitcherViews.allCases, id: \.rawValue) { view in
                Text(view.rawValue).tag(view)
            }
        }.pickerStyle(SegmentedPickerStyle())
            .padding(CardGridUX.PickerPadding)
            .disabled(tabModel.manager.isIncognito)
            .frame(height: gridModel.pickerHeight)
            .background(Color.DefaultBackground)
            .opacity(gridModel.isHidden ? 0 : 1)
            .animation(.easeOut)
    }
}

struct ScrollViewOffsetPreferenceKey: PreferenceKey {
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value += nextValue()
    }

    typealias Value = CGFloat
    static var defaultValue = CGFloat.zero
}
