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

    static let columns = 2
}

struct CardGrid: View {
    @EnvironmentObject var tabModel: TabCardModel
    @EnvironmentObject var tabGroupModel: TabGroupCardModel
    @EnvironmentObject var gridModel: GridModel

    @State var switcherState: SwitcherViews = .tabs
    @State var cardSize: CGFloat = CardUX.DefaultCardSize

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
                                              count: 2)).environment(\.cardSize, cardSize)
                Spacer(minLength: 0)
            }.overlay(Group {
                if gridModel.animationThumbnailState != .hidden, let selectedCardDetails = selectedCardDetails {
                    CardTransitionAnimator(
                        selectedCardDetails: selectedCardDetails,
                        cardSize: cardSize,
                        offset: CGPoint(
                            x: (indexInGrid % CardGridUX.columns) == 0 ?
                                CardGridUX.GridSpacing :
                                CardGridUX.GridSpacing * 2 + cardSize,
                            y: (CardUX.HeaderSize + cardSize + CardGridUX.GridSpacing) * floor(CGFloat(indexInGrid) / CGFloat(CardGridUX.columns))
                                + CardGridUX.YStaticOffset + gridModel.scrollOffset
                        ),
                        containerSize: geom.size
                    )
                }
            }, alignment: .topLeading)
            .onChange(of: geom.size.width) { _ in
                self.cardSize = (geom.size.width - 3 * CardGridUX.GridSpacing) / 2
            }
            .onAppear {
                self.cardSize = (geom.size.width - 3 * CardGridUX.GridSpacing) / 2
            }
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
