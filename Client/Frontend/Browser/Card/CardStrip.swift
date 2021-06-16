// Copyright Neeva. All rights reserved.

import SwiftUI
import Storage
import Shared

protocol CardModel: ObservableObject {
    associatedtype Manager: AccessingManager
    associatedtype Details: CardDetails where Details.Item == Manager.Item
    var manager: Manager {get}
    var allDetails: [Details] {get set}

    func onDataUpdated()
    func onItemUpdated(with id: String)
}

class TabCardModel: CardModel, TabEventHandler {
    var onViewUpdate: () -> () = {}
    var manager: TabManager {
        didSet {
            onDataUpdated()
        }
    }

    @Published var allDetails: [TabCardDetails] = []

    init(manager: TabManager) {
        self.manager = manager
        register(self, forTabEvents: .didClose, .didChangeURL, .didGainFocus)
        onDataUpdated()
    }

    func tabDidClose(_ tab: Tab) {
        onDataUpdated()
    }

    func tabDidGainFocus(_ tab: Tab) {
        guard let url = tab.url, InternalURL(url)?.isAboutHomeURL ?? false else {
            return
        }

        onViewUpdate()
        onDataUpdated()
    }

    func tab(_ tab: Tab, didChangeURL url: URL) {
        guard let selectedTab = self.manager.selectedTab, selectedTab == tab else {
            return
        }

        ScreenshotHelper().takeScreenshot(tab)
    }

    func onDataUpdated() {
        allDetails = manager.getAll().map {TabCardDetails(tab: $0, manager: manager)}
        onViewUpdate()
    }

    func onItemUpdated(with id: String) {
        if let index = allDetails.firstIndex(where: {$0.id == id}), let tab = manager.get(for: id) {
            allDetails[index] = TabCardDetails(tab: tab, manager: manager)
        }
    }

    typealias Manager = TabManager
    typealias Details = TabCardDetails
}

class SpaceCardModel: CardModel {
    var onViewUpdate: () -> () = {}

    func onDataUpdated() {
        allDetails = manager.getAll().map {SpaceCardDetails(space: $0)}
        onViewUpdate()
    }

    func onItemUpdated(with id: String) {}

    @Published var manager = SpaceStore.shared

    @Published var allDetails: [SpaceCardDetails] = []
}

struct CardStrip<Model: CardModel>: View {
    typealias Details = Model.Details
    @ObservedObject var model: Model

    var body: some View {
            LazyHStack(spacing: 32) {
                ForEach(model.allDetails.indices, id: \.self) { index in
                    let details = model.allDetails[index]
                    Card<Details>(details: details)
                }
            }.padding().frame(height: 275)
    }
}

struct TabsAndSpacesView: View {
    @ObservedObject var tabModel: TabCardModel
    @ObservedObject var spaceModel: SpaceCardModel
    @State var showingSpaces: Bool = false

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                Button(action: {
                    spaceModel.onDataUpdated()
                    withAnimation {
                        showingSpaces.toggle()
                    }
                }, label: {
                    Symbol(.bookmark, size: 24, weight: .semibold, label: "Show Spaces")
                        .foregroundColor(
                            Color(showingSpaces ? UIColor.Browser.background : UIColor.label))
                        .aspectRatio(contentMode: .fit)
                }).frame(width: 44, height: 44)
                .background(Color(showingSpaces ? UIColor.label : UIColor.Browser.background))
                .clipShape(Circle()).animation(.spring())
                .frame(width: CardUX.CardSize / 2, height: CardUX.CardSize)
                .background(Color(UIColor.Browser.background))
                .clipShape(RoundedRectangle(cornerRadius: CardUX.CornerRadius))
                .shadow(radius: CardUX.ShadowRadius).padding(.leading, 20)
                if showingSpaces {
                    CardStrip(model: spaceModel)
                }
                CardStrip(model: tabModel)
            }
        }.onAppear {
            tabModel.onDataUpdated()
            spaceModel.manager.refresh()
        }.frame(maxWidth:.infinity)
        .background(LinearGradient(gradient: Gradient(colors:
                                                        [.clear, .label.opacity(0.3), .clear]),
                                                        startPoint: .top, endPoint: .bottom))
    }
}
