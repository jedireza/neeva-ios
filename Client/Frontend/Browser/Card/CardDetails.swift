// Copyright Neeva. All rights reserved.

import Foundation
import Storage
import SDWebImageSwiftUI
import SwiftUI
import Shared

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
    var primitiveUrl: URL? { get }
    var displayTitle: String { get }
    var displayFavicon: Favicon? { get }
    var image: UIImage? { get }
    var pageMetadata: PageMetadata? { get }
}

protocol CardDetails: ObservableObject, DropDelegate {
    associatedtype Item: BrowserPrimitive
    associatedtype Thumbnail: View

    var id:String { get }
    var closeButtonImage: UIImage? { get }
    var title: String { get }
    var favicon: WebImage? { get }
    var thumbnail: Thumbnail { get }
    var pageImage: WebImage? { get }

    func onSelect()
    func onClose()
}

extension CardDetails {
    func performDrop(info: DropInfo) -> Bool {
        return false
    }
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

    var thumbnail: some View {
        guard let image = manager.get(for: id)?.image else {
            return Image(systemName: "folder.fill").resizable().aspectRatio(contentMode: .fill)
        }
        return Image(uiImage: image).resizable().aspectRatio(contentMode: .fill)
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

    var primitiveUrl: URL? {
        url
    }

    var image: UIImage? {
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

class TabCardDetails: CardDetails, AccessingManagerProvider,
                      ClosingManagerProvider, SelectingManagerProvider {
    typealias Item = Tab
    typealias Manager = TabManager

    var id: String
    var manager: TabManager

    init(id: String, manager: TabManager) {
        self.id = id
        self.manager = manager
    }

    // Avoiding keeping a reference to classes both to minimize surface area these Card classes have
    // access to, but also to not worry about reference copying while using CardDetails for View updates.
    init(tab: Tab, manager: TabManager) {
        self.id = tab.tabUUID
        self.manager = manager
    }

    func performDrop(info: DropInfo) -> Bool {
        guard info.hasItemsConforming(to: ["public.url"]) else {
            return false
        }

        let items = info.itemProviders(for: ["public.url"])
        for item in items {
            _ = item.loadObject(ofClass: URL.self) { url, _ in
                if let url = url {
                    DispatchQueue.main.async {
                        self.manager.get(for: self.id)?.loadRequest(URLRequest(url: url))
                    }
                }
            }
        }

        return true
    }
}

extension Space: BrowserPrimitive {
    var primitiveUrl: URL? {
        url
    }

    var displayTitle: String {
        name
    }

    var displayFavicon: Favicon? {
        nil
    }

    var image: UIImage? {
        if let thumbnail = thumbnail?.dataURIBody {
            return UIImage(data: thumbnail)
        }
        return nil
    }

    var pageMetadata: PageMetadata? {
        return nil
    }
}

extension SpaceStore: AccessingManager {
    func get(for id: String) -> Space? {
        allSpaces.first(where: { $0.id.id == id })
    }

    func getAll() -> [Space] {
        allSpaces
    }

    typealias Item = Space
}

class SpaceCardDetails: CardDetails, AccessingManagerProvider {
    static let Spacing : CGFloat = 5

    var id: String
    var closeButtonImage: UIImage? = nil

    init(id: String) {
        self.id = id
    }

    init(space: Space) {
        self.id = space.id.id
    }

    var thumbnail: some View {
        let thumbnails = manager.get(for: id)?.contentThumbnails?.compactMap{ $0?.dataURIBody }
            .prefix(4) ?? []
        let size: CGFloat = thumbnails.count == 1 ?
            CardUX.CardSize - 2 * SpaceCardDetails.Spacing
            : CardUX.CardSize / 2 - 2 * SpaceCardDetails.Spacing
        let rows = Array(repeating: GridItem(.fixed(size),
                                             spacing: SpaceCardDetails.Spacing),
                         count: thumbnails.count > 2 ? 2 : 1)
        return LazyHGrid(rows: rows, alignment: .center, spacing: 0) {
            ForEach(thumbnails, id: \.self) { data in
                Image(uiImage: UIImage(data: data)!).resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: size, height: size)
                    .clipShape(RoundedRectangle(cornerRadius: CardUX.CornerRadius))
                    .overlay(RoundedRectangle(cornerRadius: CardUX.CornerRadius)
                                .stroke(Color(UIColor.tertiaryLabel)))
                    .padding(4)
            }
        }.frame(maxWidth: .infinity, maxHeight: .infinity).background(Color.white)
    }

    func performDrop(info: DropInfo) -> Bool {
        guard info.hasItemsConforming(to: ["public.text", "public.url"]) else {
            return false
        }

        var items = info.itemProviders(for: ["public.url"])
        let foundUrl = !items.isEmpty
        for item in items {
            _ = item.loadObject(ofClass: URL.self) { url, _ in
                if let url = url, let space = self.manager.get(for: self.id) {
                    DispatchQueue.main.async {
                        let bvc = BrowserViewController.foregroundBVC()
                        let request = AddToSpaceRequest(
                            title: "Link from \(url.baseDomain ?? "page")",
                            description: "", url: url)
                        request.addToExistingSpace(id:space.id.id, name: space.name)
                        bvc.show(toast: AddToSpaceToast(request: request, onOpenSpace: { spaceID in
                            bvc.openURLInNewTab(NeevaConstants.appSpacesURL / spaceID)
                        }))
                    }
                }
            }
        }

        guard !foundUrl else {
            return true
        }

        items = info.itemProviders(for: ["public.text"])
        for item in items {
            _ = item.loadObject(ofClass: String.self) { text, _ in
                if let text = text, let space = self.manager.get(for: self.id) {
                    DispatchQueue.main.async {
                        let bvc = BrowserViewController.foregroundBVC()
                        let request = AddToSpaceRequest(title: "Selected snippets",
                                                        description: text,
                                                        url: (bvc.tabManager.selectedTab?.url)!)
                        request.addToExistingSpace(id:space.id.id, name: space.name)
                        bvc.show(toast: AddToSpaceToast(request: request, onOpenSpace: { spaceID in
                            bvc.openURLInNewTab(NeevaConstants.appSpacesURL / spaceID)
                        }))
                    }
                }
            }
        }

        return true
    }

    func onSelect() {
        guard let url = manager.get(for: id)?.primitiveUrl else {
            return
        }

        BrowserViewController.foregroundBVC().openURLInNewTab(url)
    }

    func onClose() { }

    var manager: SpaceStore = {
        SpaceStore.shared
    }()

    typealias Item = Space
    typealias Manager = SpaceStore
}
