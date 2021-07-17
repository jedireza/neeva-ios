// Copyright Neeva. All rights reserved.

import SwiftUI
import Shared

enum SwitcherViews: String, CaseIterable {
    case spaces = "bookmark"
    case tabs = "square.on.square"
}

enum CardGridUX {
    static let PickerPadding: CGFloat = 20
    static let PickerHeight: CGFloat = 50
    static let GridSpacing: CGFloat = 20
    static let YStaticOffset: CGFloat =
        (FeatureFlag[.groupsInSwitcher] ? PickerHeight + 2 * PickerPadding : 0)
        + GridSpacing
}

struct CardGrid: View {
    @EnvironmentObject var tabModel: TabCardModel
    @EnvironmentObject var tabGroupModel: TabGroupCardModel
    @EnvironmentObject var gridModel: GridModel

    @State private var switcherState: SwitcherViews = .tabs
    @State private var cardSize: CGFloat = CardUX.DefaultCardSize
    @State private var columnCount = 2
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    var indexInsideTabGroupModel: Int? {
        guard FeatureFlag[.groupsInSwitcher] else {
            return nil
        }

        let selectedTab = tabModel.manager.selectedTab!
        return tabGroupModel.allDetails
            .firstIndex(where: { $0.id == selectedTab.rootUUID })
    }

    var indexInsideTabModel: Int? {
        if FeatureFlag[.groupsInSwitcher] {
            return tabModel.allDetailsWithExclusionList.firstIndex(where: \.isSelected)
        } else {
            return tabModel.allDetails.firstIndex(where: \.isSelected)
        }
    }

    var indexInGrid: Int {
        indexInsideTabGroupModel ??
            (FeatureFlag[.groupsInSwitcher] ? tabGroupModel.allDetails.count : 0)
            + indexInsideTabModel!
    }

    var selectedCardDetails: TabCardDetails? {
        if FeatureFlag[.groupsInSwitcher] {
            return tabModel.allDetailsWithExclusionList.first(where: \.isSelected)
                ?? tabGroupModel.allDetails
                .compactMap { $0.allDetails.first(where: \.isSelected) }
                .first
        } else {
            return tabModel.allDetails.first(where: \.isSelected)
        }
    }

    @ViewBuilder func transitionAnimator(size: CGSize) -> some View {
        if gridModel.animationThumbnailState != .hidden, let selectedCardDetails = selectedCardDetails {
            CardTransitionAnimator(
                selectedCardDetails: selectedCardDetails,
                cardSize: cardSize,
                offset: CGPoint(
                    x: CardGridUX.GridSpacing +
                        (CardGridUX.GridSpacing + cardSize) * CGFloat(indexInGrid % columnCount),
                    y: (CardUX.CardHeight + CardGridUX.GridSpacing) * floor(CGFloat(indexInGrid) / CGFloat(columnCount))
                        + CardGridUX.YStaticOffset + gridModel.scrollOffset
                ),
                containerSize: size
            )
        }
    }

    func updateCardSize(width: CGFloat, horizontalSizeClass: UserInterfaceSizeClass?) {
        if width > 1000 {
            columnCount = 4
        } else {
            switch horizontalSizeClass {
            case .regular: columnCount = 3
            default: columnCount = 2
            }
        }
        self.cardSize = (width - CGFloat(columnCount + 1) * CardGridUX.GridSpacing) / CGFloat(columnCount)
    }

    var body: some View {
        GeometryReader { geom in
            VStack(spacing: 0) {
                if FeatureFlag[.groupsInSwitcher] {
                    GridPicker(switcherState: $switcherState)
                }
                CardsContainer(switcherState: $switcherState,
                               columns: Array(repeating:
                                                GridItem(.fixed(cardSize),
                                                         spacing: CardGridUX.GridSpacing),
                                              count: columnCount))
                    .environment(\.cardSize, cardSize)
                Spacer(minLength: 0)
            }
            .overlay(transitionAnimator(size: geom.size), alignment: .topLeading)
            .useEffect(deps: geom.size.width, horizontalSizeClass, perform: updateCardSize)
            .clipped()
        }
    }
}

struct GridPicker: View {
    @Binding var switcherState: SwitcherViews

    var body: some View {
        Picker("", selection: $switcherState) {
            ForEach(SwitcherViews.allCases, id: \.rawValue) { view in
                Image(systemName: view.rawValue).tag(view).frame(width: 64)
            }
        }.pickerStyle(SegmentedPickerStyle())
            .background(Color.DefaultBackground)
            .padding(CardGridUX.PickerPadding)
            .frame(width: 160, height: CardGridUX.PickerHeight)
    }
}

struct ScrollViewOffsetPreferenceKey: PreferenceKey {
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value += nextValue()
    }

    typealias Value = CGFloat
    static var defaultValue = CGFloat.zero
}
