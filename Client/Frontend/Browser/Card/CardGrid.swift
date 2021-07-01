// Copyright Neeva. All rights reserved.

import SwiftUI

enum SwitcherViews: String, CaseIterable {
    case spaces = "bookmark"
    case tabs = "square.on.square"
}

enum CardGridUX {
    static let PickerPadding: CGFloat = 20
    static let PickerHeight: CGFloat = 50
    static let GridTopPadding: CGFloat = 20
    static let GridSpacing: CGFloat = 20
    static let YStaticOffset: CGFloat = PickerHeight + PickerPadding * 2 + GridTopPadding
        + 0.25 * CardUX.CardSize + CardUX.HeaderSize
}

fileprivate struct CompletionForAnimation: AnimatableModifier {
    var targetValue: Double

    var animatableData: Double {
        didSet {
            maybeRunCompletion()
        }
    }

    var afterTrueToFalse: () -> ()
    var afterFalseToTrue: () -> ()

    init(toggleValue: Bool,
         afterTrueToFalse: @escaping () -> (), afterFalseToTrue: @escaping () -> ()) {
        self.afterTrueToFalse = afterTrueToFalse
        self.afterFalseToTrue = afterFalseToTrue

        self.animatableData = toggleValue ? 1 : 0
        self.targetValue = toggleValue ? 1 : 0
    }

    func maybeRunCompletion() {
        if (animatableData == targetValue) {
            DispatchQueue.main.async {
                targetValue == 1 ? self.afterFalseToTrue() : self.afterTrueToFalse()
            }
        }
    }

    func body(content: Content) -> some View {
        content
    }
}

private extension View {
    func runAfter(toggling: Bool,
                  fromTrueToFalse: @escaping () -> () = {},
                  fromFalseToTrue: @escaping () -> () = {}) -> some View {
        self.modifier(CompletionForAnimation(toggleValue: toggling,
                                             afterTrueToFalse: fromTrueToFalse,
                                             afterFalseToTrue: fromFalseToTrue))
    }
}

class GridModel: ObservableObject {
    @Published var fullscreen = true
    @Published var showAnimationThumbnail = true
    var changeVisibility: ((Bool) -> ())!
    var scrollOffset: CGFloat = CGFloat.zero

    func show() {
        fullscreen = false
        changeVisibility(true)
    }
}

struct CardGrid: View {
    @EnvironmentObject var tabModel: TabCardModel
    @EnvironmentObject var tabGroupModel: TabGroupCardModel
    @EnvironmentObject var gridModel: GridModel

    @State var switcherState: SwitcherViews = .tabs

    var indexInsideTabGroupModel: Int? {
        let selectedTab = tabModel.manager.selectedTab!
        return tabGroupModel.allDetails
            .firstIndex(where: { $0.id == selectedTab.rootUUID })
    }

    var indexInsideTabModel: Int? {
        let selectedTab = tabModel.manager.selectedTab!
        return tabModel.allDetailsWithExclusionList
            .firstIndex(where: { $0.id == selectedTab.tabUUID })
    }

    var indexInGrid: Int {
        indexInsideTabGroupModel ?? tabGroupModel.allDetails.count + indexInsideTabModel!
    }

    var xOffset: CGFloat {
        let offset = (indexInGrid % 2) == 0 ?
            -CardGridUX.GridSpacing / 2 - CardUX.CardSize / 2 :
            CardGridUX.GridSpacing / 2 + CardUX.CardSize / 2
        return offset
    }

    var yOffset: CGFloat {
        let rows = floor(CGFloat(indexInGrid) / 2.0)
        return  (CardUX.HeaderSize + CardUX.CardSize + CardGridUX.GridSpacing) * rows
            + CardGridUX.YStaticOffset + gridModel.scrollOffset
    }

    var selectedThumbnail: some View {
        let selectedTab = tabModel.manager.selectedTab!
        var details: TabCardDetails? = nil
        tabGroupModel.allDetails.forEach { groupDetail in
            groupDetail.allDetails.forEach { tabDetail in
                if tabDetail.id == selectedTab.tabUUID {
                    details = tabDetail
                }
            }
        }
        tabModel.allDetailsWithExclusionList.forEach { tabDetail in
            if tabDetail.id == selectedTab.tabUUID {
                details = tabDetail
            }
        }
        return details?.thumbnail
    }

    var body: some View {
        GeometryReader { geom in
            ZStack {
                VStack(spacing: 0) {
                    GridPicker(switcherState: $switcherState)
                    CardsContainer(switcherState: $switcherState)
                    Spacer(minLength: 0)
                }
                if gridModel.showAnimationThumbnail {
                    selectedThumbnail.runAfter(toggling: gridModel.fullscreen, fromTrueToFalse: {
                        gridModel.showAnimationThumbnail = false
                    }, fromFalseToTrue: {
                        gridModel.changeVisibility(false)
                    }).frame(width: gridModel.fullscreen ? geom.size.width : CardUX.CardSize,
                             height: gridModel.fullscreen ? geom.size.height : CardUX.CardSize)
                    .cornerRadius(CardUX.CornerRadius).clipped()
                    .offset(x: gridModel.fullscreen ? 0 : xOffset,
                            y: gridModel.fullscreen ? 0: yOffset - geom.size.height / 2)
                    .animation(.spring()).onAppear {
                        if !gridModel.fullscreen {
                                gridModel.fullscreen.toggle()
                        }
                    }
                }
            }
        }
    }
}

struct CardsContainer: View {
    @EnvironmentObject var tabModel: TabCardModel
    @EnvironmentObject var tabGroupModel: TabGroupCardModel
    @EnvironmentObject var gridModel: GridModel
    @Binding var switcherState: SwitcherViews

    let columns = Array(repeating: GridItem(.fixed(CardUX.CardSize),
                                            spacing: CardGridUX.GridSpacing), count: 2)

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
                                gridModel.changeVisibility(false)
                                gridModel.showAnimationThumbnail = true
                                gridModel.fullscreen = true
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
                            gridModel.showAnimationThumbnail = true
                        }
                    }
                }.padding(.top, 20).onAppear() {
                    value.scrollTo(
                        indexInsideTabGroupModel != nil ?
                            tabModel.manager.selectedTab?.rootUUID :
                            tabModel.manager.selectedTab?.tabUUID)
                }.background(GeometryReader { proxy in
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

struct SpaceCardsView: View {
    @EnvironmentObject var spacesModel: SpaceCardModel

    var body: some View {
        ForEach(spacesModel.allDetails, id: \.id) { details in
            Card(details: details, config: .grid)
                .id(details.id)
        }
    }
}

struct TabCardsView: View {
    @EnvironmentObject var tabModel: TabCardModel
    @EnvironmentObject var tabGroupModel: TabGroupCardModel

    var body: some View {
        Group {
            ForEach(tabGroupModel.allDetails, id: \.id) { details in
                Card(details: details, config: .grid)
                    .id(details.id)
            }
            ForEach(tabModel.allDetailsWithExclusionList, id: \.id) { details in
                Card(details: details, config: .grid)
                    .id(details.id)
            }
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
            .background(Color(UIColor.Browser.background))
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
