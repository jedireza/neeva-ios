//  Copyright © 2021 Neeva. All rights reserved.
//

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
        register(self, forTabEvents: .didClose)
        onDataUpdated()
    }

    func tabDidClose(_ tab: Tab) {
        onDataUpdated()
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

struct CardStrip<Model: CardModel>: View {
    typealias Details = Model.Details
    @ObservedObject var model: Model

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(spacing: 32) {
                ForEach(model.allDetails.indices, id: \.self) { index in
                    let details = model.allDetails[index]
                    Card<Details>(details: details)
                }
            }.padding().frame(height: 275)

        }.onAppear {
            model.onDataUpdated()
        }.frame(maxWidth:.infinity)
        .background(LinearGradient(gradient: Gradient(colors:
                                                        [.clear, .label.opacity(0.3), .clear]),
                                                        startPoint: .top, endPoint: .bottom))
    }
}
