// Copyright Neeva. All rights reserved.

import SwiftUI

enum SwitcherViews: String, CaseIterable {
    case spaces = "bookmark"
    case tabs = "square.on.square"
}

struct CardGrid: View {
    @ObservedObject var spacesModel: SpaceCardModel
    @ObservedObject var tabModel: TabCardModel
    @ObservedObject var tabGroupModel: TabGroupCardModel
    @State var switcherState: SwitcherViews = .tabs

    let columns = Array(repeating: GridItem(.fixed(CardUX.CardSize), spacing: 20), count: 2)

    var body: some View {
        VStack {
            Picker("", selection: $switcherState.animation()) {
                ForEach(SwitcherViews.allCases, id: \.rawValue) { view in
                    Image(systemName: view.rawValue).tag(view).frame(width: 64, height: 40)
                }
            }.pickerStyle(SegmentedPickerStyle())
                .background(Color(UIColor.Browser.background))
                .padding().frame(width: 160)
            ScrollView(.vertical, showsIndicators: false) {
                LazyVGrid(columns: columns, spacing: 20) {
                    if case .spaces = switcherState {
                        ForEach(spacesModel.allDetails, id: \.id) { details in
                            Card<SpaceCardDetails>(details: details, config: .grid)
                                .transition(AnyTransition.opacity.combined(
                                                with: .move(edge: .leading)))
                        }
                    } else {
                        ForEach(tabGroupModel.allDetails, id: \.id) { details in
                            Card<TabGroupCardDetails>(details: details, config: .grid)
                                .transition(AnyTransition.opacity.combined(
                                                with: .move(edge: .trailing)))
                        }
                        ForEach(tabModel.allDetails, id: \.id) { details in
                            Card<TabCardDetails>(details: details, config: .grid)
                                .transition(AnyTransition.opacity.combined(
                                                with: .move(edge: .trailing)))
                        }
                    }
                }.padding(.top)
            }.background(Color.white)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .transition(.opacity)
        }
    }
}
