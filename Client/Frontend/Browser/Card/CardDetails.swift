//  Copyright © 2021 Neeva. All rights reserved.
//

import Foundation
import Storage
import SDWebImageSwiftUI
import SwiftUI

// The intention for a browser primitive is to represent any metadata or entity tied to a url
// with a card in a heterogenous UI. Tabs are the canonical browser primitive, but Spaces, a single
// entry in a Space, a History entry, a product in a web page can be a browser primitive as well.
// The framework here tries to establish rules around how these primitives should be represented
// and how they can interact with the user and each other. Ex: Dragging a product on top of a tab
// card should save that product as metadata in the tab, or clicking on a History item should
// navigate to that url in the current tab (SelectingManager is TabManager), but swiping it away
// should delete it from history (ClosingManager is History DB), links within a page can be cards
// and dragging them to a space card should add them to the Space.

protocol BrowserPrimitive {
    var url: URL? { get }
    var displayTitle: String { get }
    var displayFavicon: Favicon? { get }
    var thumbnail: UIImage? { get }
    var pageMetadata: PageMetadata? { get }
}

protocol CardDetails: ObservableObject {
    associatedtype Item: BrowserPrimitive

    var id:String { get }
    var closeButtonImage: UIImage? { get }
    var title: String { get }
    var favicon: WebImage? { get }
    var thumbnail: UIImage? { get }
    var pageImage: WebImage? { get }

    func onSelect()
    func onClose()
}

protocol Closeable {
    associatedtype Manager: ClosingManager where Manager.Item == Self

    func close(with manager: Manager)
}

protocol Selectable {
    associatedtype Manager: SelectingManager where Manager.Item == Self

    func select(with manager: Manager)
}

protocol AccessingManagerProvider {
    associatedtype Manager : AccessingManager
    var manager: Manager { get set }
}

protocol AccessingManager {
    associatedtype Item
    func get(for id: String) -> Item?
    func getAll() -> [Item]
}

protocol ClosingManagerProvider {
    associatedtype Manager : ClosingManager
    var manager: Manager { get set }
}

protocol ClosingManager {
    associatedtype Item
    func close(_ item: Item)
}

protocol SelectingManagerProvider {
    associatedtype Manager : SelectingManager
    var manager: Manager { get set }
}

protocol SelectingManager {
    associatedtype Item
    func select(_ item: Item)
}

extension TabManager: ClosingManager, SelectingManager, AccessingManager {
    typealias Item = Tab

    func close(_ tab: Tab) {
        removeTabAndUpdateSelectedIndex(tab)
    }

    func select(_ tab: Tab) {
        selectTab(tab)
    }

    func get(for id: String) -> Tab? {
        getTabForUUID(uuid: id)
    }

    func getAll() -> [Tab] {
        let isPrivate = selectedTab?.isPrivate ?? false
        return tabs.filter{$0.isPrivate == isPrivate}
    }
}

extension Tab: Closeable, Selectable, BrowserPrimitive {
    var thumbnail: UIImage? {
        screenshot
    }

    typealias Manager = TabManager

    func close(with manager: TabManager) {
        manager.close(self)
    }

    func select(with manager: TabManager) {
        manager.select(self)
    }
}

extension CardDetails where Item: Selectable, Self: SelectingManagerProvider, Self.Manager.Item == Item, Manager: AccessingManager {

    func onSelect() {
        if let item = manager.get(for: id) {
            manager.select(item)
        }
    }
}

extension CardDetails where Item: Closeable, Self: ClosingManagerProvider, Self.Manager.Item == Item, Manager: AccessingManager {

    var closeButtonImage: UIImage? {
        UIImage(systemName: "xmark.circle.fill")
    }

    func onClose() {
        if let item = manager.get(for: id) {
            manager.close(item)
        }
    }
}

extension CardDetails where Self: AccessingManagerProvider, Self.Manager.Item == Item {
    var title: String {
        manager.get(for: id)?.displayTitle ?? ""
    }

    var thumbnail: UIImage? {
        manager.get(for: id)?.thumbnail
    }

    var favicon: WebImage? {
        if let item = manager.get(for: id) {
            if let favIcon = item.displayFavicon {
                return WebImage(url: URL(string: favIcon.url))
            }
        }
        return nil
    }

    var pageImage: WebImage? {
        guard let url: String = manager.get(for: id)?.pageMetadata?.mediaURL else {
            return nil
        }
        return WebImage(url: URL(string: url))

    }
}

class TabCardDetails: CardDetails, AccessingManagerProvider, ClosingManagerProvider, SelectingManagerProvider {
    typealias Item = Tab
    typealias Manager = TabManager

    var id: String
    var manager: TabManager

    init(id: String, manager: TabManager) {
        self.id = id
        self.manager = manager
    }

    init(tab: Tab, manager: TabManager) {
        self.id = tab.tabUUID
        self.manager = manager
    }
}
