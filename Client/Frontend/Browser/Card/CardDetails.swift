// Copyright Neeva. All rights reserved.

import Combine
import Foundation
import SDWebImageSwiftUI
import Shared
import Storage
import SwiftUI

protocol SelectableThumbnail {
    associatedtype ThumbnailView: View

    var thumbnail: ThumbnailView { get }
    func onSelect()
}

protocol CardDetails: ObservableObject, DropDelegate, SelectableThumbnail {
    associatedtype Item: BrowserPrimitive
    associatedtype FaviconViewType: View

    var id: String { get }
    var closeButtonImage: UIImage? { get }
    var title: String { get }
    var description: String? { get }
    var accessibilityLabel: String { get }
    var favicon: FaviconViewType { get }
    var isSelected: Bool { get }
    var thumbnailDrawsHeader: Bool { get }
    var isSharedWithGroup: Bool { get }
    var isSharedPublic: Bool { get }
    var ACL: SpaceACLLevel { get }

    func onClose()
}

extension CardDetails {
    var isSelected: Bool {
        false
    }

    func validateDrop(info: DropInfo) -> Bool {
        return false
    }

    func performDrop(info: DropInfo) -> Bool {
        return false
    }

    var thumbnailDrawsHeader: Bool {
        true
    }
}

extension CardDetails
where
    Item: Selectable, Self: SelectingManagerProvider, Self.Manager.Item == Item,
    Manager: AccessingManager
{
    func onSelect() {
        if let item = manager.get(for: id) {
            manager.select(item)
        }
    }
}

extension CardDetails
where
    Item: Closeable, Self: ClosingManagerProvider, Self.Manager.Item == Item,
    Manager: AccessingManager
{

    var closeButtonImage: UIImage? {
        UIImage(systemName: "xmark")
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

    var description: String? {
        return manager.get(for: id)?.pageMetadata?.description
    }

    var isSharedWithGroup: Bool { manager.get(for: id)?.isSharedWithGroup ?? false }
    var isSharedPublic: Bool { manager.get(for: id)?.isSharedPublic ?? false }
    var ACL: SpaceACLLevel { manager.get(for: id)?.ACL ?? .owner }

    @ViewBuilder var thumbnail: some View {
        if let image = manager.get(for: id)?.image {
            Image(uiImage: image).resizable().aspectRatio(contentMode: .fill)
        } else {
            Color.white
        }
    }

    @ViewBuilder var favicon: some View {
        if let item = manager.get(for: id) {
            if let favIcon = item.displayFavicon {
                WebImage(url: favIcon.url)
                    .resizable()
                    .transition(.fade(duration: 0.5))
                    .background(Color.white)
                    .scaledToFit()
            } else if let url = item.primitiveUrl {
                FaviconView(url: url, size: SuggestionViewUX.FaviconSize, bordered: false)
            }
        }
    }
}

public class TabCardDetails: CardDetails, AccessingManagerProvider,
    ClosingManagerProvider, SelectingManagerProvider
{
    typealias Item = Tab
    typealias Manager = TabManager

    var id: String
    var manager: TabManager

    var url: URL? {
        manager.get(for: id)?.url
    }

    var isSelected: Bool {
        self.manager.selectedTab?.tabUUID == id
    }

    var accessibilityLabel: String {
        "\(title), Tab"
    }

    var thumbnailDrawsHeader: Bool {
        false
    }

    // Avoiding keeping a reference to classes both to minimize surface area these Card classes have
    // access to, but also to not worry about reference copying while using CardDetails for View updates.
    init(tab: Tab, manager: TabManager) {
        self.id = tab.id
        self.manager = manager
    }

    public func validateDrop(info: DropInfo) -> Bool {
        return info.hasItemsConforming(to: [.url])
    }

    public func performDrop(info: DropInfo) -> Bool {
        guard validateDrop(info: info) else {
            return false
        }

        let items = info.itemProviders(for: [.url])
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

class SpaceEntityThumbnail: CardDetails, AccessingManagerProvider {
    typealias Item = SpaceEntityData
    typealias Manager = Space

    var manager: Space {
        SpaceStore.shared.get(for: spaceID)!
    }

    let spaceID: String
    let data: SpaceEntityData

    var id: String
    var closeButtonImage: UIImage? = nil
    var accessibilityLabel: String = "Space Item"

    var ACL: SpaceACLLevel {
        manager.ACL
    }

    private var imageThumbnailModel: ImageThumbnailModel?

    init(data: SpaceEntityData, spaceID: String) {
        self.spaceID = spaceID
        self.data = data
        self.id = data.id
        if let thumbnailData = data.thumbnail?.dataURIBody {
            self.imageThumbnailModel = .init(imageData: thumbnailData)
        }
    }

    @ViewBuilder var thumbnail: some View {
        if let imageThumbnailModel = imageThumbnailModel {
            ImageThumbnailView(model: imageThumbnailModel)
        } else {
            Symbol(decorative: .bookmarkOnBookmark)
                .foregroundColor(Color.white)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.spaceIconBackground)
        }
    }

    func onClose() {}
    func onSelect() {}

}

class SpaceCardDetails: CardDetails, AccessingManagerProvider, ThumbnailModel {
    typealias Item = Space
    typealias Manager = SpaceStore
    typealias Thumbnail = SpaceEntityThumbnail

    @Published var manager: SpaceStore
    @Published var isShowingDetails = false

    var id: String
    var closeButtonImage: UIImage? = nil
    @Published var allDetails: [SpaceEntityThumbnail] = []

    var accessibilityLabel: String {
        "\(title), Space"
    }

    var space: Space? {
        manager.get(for: id)
    }

    private init(id: String, manager: SpaceStore) {
        self.id = id
        self.manager = manager

        updateDetails()
    }

    convenience init(space: Space, manager: SpaceStore) {
        self.init(id: space.id.id, manager: manager)
    }

    var thumbnail: some View {
        VStack(spacing: 0) {
            ThumbnailGroupView(model: self)
            HStack {
                Spacer(minLength: 12)
                Text(title)
                    .withFont(.labelMedium)
                    .lineLimit(1)
                    .foregroundColor(Color.label)
                    .frame(height: CardUX.HeaderSize)
                if let space = space, space.isPublic {
                    Symbol(decorative: .link, style: .labelMedium)
                        .foregroundColor(.secondaryLabel)
                } else if let space = space, space.isShared {
                    Symbol(decorative: .person2Fill, style: .labelMedium)
                        .foregroundColor(.secondaryLabel)
                }
                Spacer(minLength: 12)
            }
        }.shadow(radius: 0)
    }

    func updateDetails() {
        allDetails =
            manager.get(for: id)?.contentData?
            .map { SpaceEntityThumbnail(data: $0, spaceID: id) } ?? []
    }

    func onSelect() {
        isShowingDetails = true
    }

    func onClose() {}

    func validateDrop(info: DropInfo) -> Bool {
        return info.hasItemsConforming(to: ["public.text", "public.url"])
    }

    func performDrop(info: DropInfo) -> Bool {
        guard validateDrop(info: info) else {
            return false
        }

        let items = info.itemProviders(for: ["public.url"])
        for item in items {
            _ = item.loadObject(ofClass: URL.self) { url, _ in
                if let url = url, let space = self.manager.get(for: self.id) {
                    DispatchQueue.main.async {
                        let request = AddToSpaceRequest(
                            title: "Link from \(url.baseDomain ?? "page")",
                            description: "", url: url)
                        request.addToExistingSpace(id: space.id.id, name: space.name)
                    }
                }
            }
        }

        return true
    }
}

class SiteCardDetails: CardDetails, AccessingManagerProvider {
    typealias Item = Site
    typealias Manager = SiteFetcher

    @Published var manager: SiteFetcher
    var anyCancellable: AnyCancellable? = nil
    var id: String
    var closeButtonImage: UIImage?
    var tabManager: TabManager

    var accessibilityLabel: String {
        "\(title), Link"
    }

    init(url: URL, fetcher: SiteFetcher, tabManager: TabManager) {
        self.id = url.absoluteString
        self.manager = fetcher
        self.tabManager = tabManager

        self.anyCancellable = fetcher.objectWillChange.sink { [weak self] (_) in
            self?.objectWillChange.send()
        }

        fetcher.load(url: url, profile: tabManager.profile)
    }

    func thumbnail(size: CGFloat) -> some View {
        return WebImage(
            url:
                URL(string: manager.get(for: id)?.pageMetadata?.mediaURL ?? "")
        )
        .resizable().aspectRatio(contentMode: .fill)
    }

    func onSelect() {
        guard let site = manager.get(for: id) else {
            return
        }

        tabManager.selectedTab?.select(site)
    }

    func onClose() {}
}

class TabGroupCardDetails: CardDetails, AccessingManagerProvider, ClosingManagerProvider,
    ThumbnailModel
{
    typealias Item = TabGroup
    typealias Manager = TabGroupManager

    var manager: TabGroupManager
    var id: String
    var isSelected: Bool {
        manager.tabManager.selectedTab?.rootUUID == id
    }
    @Published var allDetails: [TabCardDetails] = []

    var accessibilityLabel: String {
        "\(title), Tab Group"
    }

    init(tabGroup: TabGroup, tabGroupManager: TabGroupManager) {
        self.id = tabGroup.id
        self.manager = tabGroupManager
        allDetails =
            manager.get(for: id)?.children
            .map({ TabCardDetails(tab: $0, manager: manager.tabManager) }) ?? []
    }

    var thumbnail: some View {
        return ThumbnailGroupView(model: self)
    }

    func onSelect() {}
}
