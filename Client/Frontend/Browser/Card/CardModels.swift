// Copyright Neeva. All rights reserved.

import Combine
import Shared
import Storage
import SwiftUI

protocol ThumbnailModel: ObservableObject {
    associatedtype Thumbnail: SelectableThumbnail
    var allDetails: [Thumbnail] { get set }
}

protocol CardModel: ThumbnailModel {
    associatedtype Manager: AccessingManager
    associatedtype Details: CardDetails where Details.Item == Manager.Item
    var manager: Manager { get }
    var allDetails: [Details] { get set }
    var allDetailsWithExclusionList: [Details] { get set }

    func onDataUpdated()
}

class TabCardModel: CardModel, TabEventHandler {
    var onViewUpdate: () -> Void = {}
    var manager: TabManager
    var groupManager: TabGroupManager
    var anyCancellable: AnyCancellable? = nil

    @Published var allDetails: [TabCardDetails] = []
    @Published var allDetailsWithExclusionList: [TabCardDetails] = []
    @Published var selectedTabID: String? = nil

    var isCardGridEmpty: Bool {
        allDetails.isEmpty && allDetailsWithExclusionList.isEmpty
    }

    init(manager: TabManager, groupManager: TabGroupManager) {
        self.manager = manager
        self.groupManager = groupManager
        register(self, forTabEvents: .didClose, .didChangeURL)
        onDataUpdated()
        self.anyCancellable = manager.objectWillChange.sink { [weak self] (_) in
            self?.onDataUpdated()
            self?.objectWillChange.send()
        }
    }

    func tabDidClose(_ tab: Tab) {
        onDataUpdated()
    }

    func onDataUpdated() {
        groupManager.updateTabGroups()
        let childTabs = groupManager.getAll()
            .reduce(into: [Tab]()) { $0.append(contentsOf: $1.children) }
        allDetails = manager.getAll()
            .map { TabCardDetails(tab: $0, manager: manager) }
        allDetailsWithExclusionList = manager.getAll().filter { !childTabs.contains($0) }
            .map { TabCardDetails(tab: $0, manager: manager) }
        selectedTabID = manager.selectedTab?.tabUUID ?? ""
        onViewUpdate()
    }
}

func getLogCounterAttributesForSpaces(details: SpaceCardDetails?) -> [ClientLogCounterAttribute] {
    var attributes = EnvironmentHelper.shared.getAttributes()
    attributes.append(
        ClientLogCounterAttribute(
            key: LogConfig.SpacesAttribute.isPublic,
            value: String(details?.isSharedPublic ?? false)))
    attributes.append(
        ClientLogCounterAttribute(
            key: LogConfig.SpacesAttribute.isShared,
            value: String(details?.isSharedWithGroup ?? false)))
    attributes.append(
        ClientLogCounterAttribute(
            key: LogConfig.SpacesAttribute.numberOfSpaceEntities,
            value: String(details?.allDetails.count ?? 1)
        )
    )
    return attributes
}

class SpaceCardModel: CardModel {
    @Published var manager = SpaceStore.shared
    @Published var allDetails: [SpaceCardDetails] = [] {
        didSet {
            allDetailsWithExclusionList = allDetails
        }
    }
    @Published var allDetailsWithExclusionList: [SpaceCardDetails] = []
    @Published var detailedSpace: SpaceCardDetails? {
        willSet {
            guard let space = detailedSpace, newValue == nil else {
                return
            }
            space.isShowingDetails = false
        }

        didSet {
            guard detailedSpace == nil else {
                ClientLogger.shared.logCounter(
                    .SpacesDetailUIVisited,
                    attributes:
                        getLogCounterAttributesForSpaces(details: detailedSpace!))
                return
            }

            if stateNeedsRefresh {
                manager.refresh()
                stateNeedsRefresh = false
            }
        }
    }

    var onViewUpdate: () -> Void = {}
    private var anyCancellable: AnyCancellable? = nil
    private var recommendationSubscription: AnyCancellable? = nil
    private var editingSubscription: AnyCancellable? = nil
    private var detailsSubscriptions: Set<AnyCancellable> = Set()
    private var stateNeedsRefresh = false

    init(manager: SpaceStore = SpaceStore.shared) {
        self.manager = manager
        self.manager.refresh()

        self.anyCancellable = manager.objectWillChange.sink { [unowned self] (_) in
            if detailedSpace != nil {
                return
            }

            DispatchQueue.main.async {
                allDetails = manager.getAll().map {
                    SpaceCardDetails(space: $0, manager: manager)
                }
                allDetails.forEach { details in
                    let detailID = details.id
                    details.$isShowingDetails.sink { [weak self] showingDetails in
                        if showingDetails {
                            withAnimation {
                                self?.detailedSpace =
                                    self?.allDetails.first(where: { $0.id == detailID })
                            }
                        }
                    }.store(in: &detailsSubscriptions)
                }

                onViewUpdate()
                detailedSpace = allDetails.first { $0.isShowingDetails }
                objectWillChange.send()
            }
        }
    }

    func onDataUpdated() {}

    func add(spaceID: String, url: String, title: String, description: String? = nil) {
        DispatchQueue.main.async {
            let request = AddToSpaceWithURLRequest(spaceID: spaceID, url: url, title: title, description: description)
            request.$state.sink { state in
                self.stateNeedsRefresh = true
            }.cancel()
        }
    }

    func updateSpaceEntity(spaceID: String, entityID: String, title: String, snippet: String) {
        DispatchQueue.main.async {
            let request = UpdateSpaceEntityRequest(
                spaceID: spaceID, entityID: entityID, title: title, snippet: snippet)
            request.$state.sink { state in
                self.stateNeedsRefresh = true
            }.cancel()
        }
    }

    func delete(
        space spaceID: String, entities: [SpaceEntityThumbnail], from scene: UIScene,
        undoDeletion: @escaping () -> Void
    ) {
        DispatchQueue.main.async {
            let request = DeleteSpaceItemsRequest(spaceID: spaceID, ids: entities.map { $0.id })
            request.$state.sink { state in
                self.stateNeedsRefresh = true
            }.cancel()

            ToastDefaults().showToastForRemoveFromSpace(
                bvc: SceneDelegate.getBVC(with: scene), request: request
            ) {
                undoDeletion()

                // Undo deletion of Space item
                entities.forEach { entity in
                    self.add(
                        spaceID: spaceID, url: entity.data.url?.absoluteString ?? "",
                        title: entity.title, description: entity.description)
                }
            } retryDeletion: { [unowned self] in
                delete(space: spaceID, entities: entities, from: scene, undoDeletion: undoDeletion)
            }
        }
    }

    func reorder(space spaceID: String, entities: [String]) {
        DispatchQueue.main.async {
            let request = ReorderSpaceRequest(spaceID: spaceID, ids: entities)
            request.$state.sink { state in
                self.stateNeedsRefresh = true
            }.cancel()
        }
    }

    func changePublicACL(space: Space, add: Bool) {
        DispatchQueue.main.async {
            if add {
                let request = AddPublicACLRequest(spaceID: space.id.id)
                request.$state.sink { state in
                    self.stateNeedsRefresh = true
                    space.isPublic = true
                    self.objectWillChange.send()
                }.cancel()
            } else {
                let request = DeletePublicACLRequest(spaceID: space.id.id)
                request.$state.sink { state in
                    self.stateNeedsRefresh = true
                    space.isPublic = false
                    self.objectWillChange.send()
                }.cancel()
            }
        }
    }

    func addSoloACLs(space: Space, emails: [String], acl: SpaceACLLevel, note: String) {
        DispatchQueue.main.async {
            let request = AddSoloACLsRequest(
                spaceID: space.id.id, emails: emails, acl: acl, note: note)
            request.$state.sink { state in
                self.stateNeedsRefresh = true
                space.isShared = true
                self.objectWillChange.send()
            }.cancel()
        }
    }

    func updateSpaceName(space: Space, newTitle: String) {
        DispatchQueue.main.async {
            let request = UpdateSpaceRequest(spaceID: space.id.id, name: newTitle)
            request.$state.sink { state in
                self.stateNeedsRefresh = true
                space.name = newTitle
                self.objectWillChange.send()
            }.cancel()
        }
    }

    func removeSpace(spaceID: String, isOwner: Bool) {

        if isOwner {
            let request = DeleteSpaceRequest(spaceID: spaceID)
            editingSubscription = request.$state.sink { state in
                switch state {
                case .success:
                    self.editingSubscription?.cancel()
                    self.stateNeedsRefresh = true
                    self.detailedSpace = nil
                case .failure:
                    self.editingSubscription?.cancel()
                case .initial:
                    Logger.browser.info("Waiting for success or failure")
                }
            }
        } else {
            let request = UnfollowSpaceRequest(spaceID: spaceID)
            editingSubscription = request.$state.sink { state in
                switch state {
                case .success:
                    self.editingSubscription?.cancel()
                    self.stateNeedsRefresh = true
                    self.detailedSpace = nil
                case .failure:
                    self.editingSubscription?.cancel()
                case .initial:
                    Logger.browser.info("Waiting for success or failure")
                }
            }
        }
    }

    func recommendedSpaceSelected(details: SpaceCardDetails) {
        let space = SpaceStore.suggested.allSpaces.first(where: {
            details.id == $0.id.id
        })
        SpaceStore.onRecommendedSpaceSelected(space: space!)
        SpaceStore.shared.objectWillChange.send()
        recommendationSubscription = objectWillChange.sink {
            let newDetails = self.allDetails.first(where: {
                $0.id == details.id
            })
            DispatchQueue.main.async {
                newDetails?.isShowingDetails = true
                self.stateNeedsRefresh = true
                self.recommendationSubscription?.cancel()
            }
        }
    }
}

class SiteCardModel: CardModel {
    typealias Manager = SiteFetcher
    typealias Details = SiteCardDetails

    @Published var manager = SiteFetcher()
    @Published var allDetails: [SiteCardDetails] = [] {
        didSet {
            allDetailsWithExclusionList = allDetails
        }
    }
    @Published var allDetailsWithExclusionList: [SiteCardDetails] = []
    var anyCancellable: AnyCancellable? = nil
    let tabManager: TabManager

    init(urls: [URL], tabManager: TabManager) {
        self.tabManager = tabManager

        self.allDetails = urls.reduce(into: []) {
            $0.append(SiteCardDetails(url: $1, fetcher: manager, tabManager: tabManager))
        }
        self.anyCancellable = manager.objectWillChange.sink { [weak self] (_) in
            self?.objectWillChange.send()
        }
    }

    func refresh(urls: [URL]) {
        self.allDetails = urls.reduce(into: []) {
            $0.append(SiteCardDetails(url: $1, fetcher: manager, tabManager: tabManager))
        }
    }

    func onDataUpdated() {}
}

class TabGroupCardModel: CardModel {
    var onViewUpdate: () -> Void = {}
    var manager: TabGroupManager
    var anyCancellable: AnyCancellable? = nil
    private var detailsSubscriptions: Set<AnyCancellable> = Set()
    private var stateNeedsRefresh = false

    var allDetails: [TabGroupCardDetails] = [] {
        didSet {
            allDetailsWithExclusionList = allDetails
        }
    }
    @Published var allDetailsWithExclusionList: [TabGroupCardDetails] = []
    @Published var detailedTabGroup: TabGroupCardDetails? {
        willSet {
            guard let tabgroup = detailedTabGroup, newValue == nil else {
                return
            }
            tabgroup.isShowingDetails = false
        }
    }
    @Published var representativeTabs: [Tab] = []

    init(manager: TabGroupManager) {
        self.manager = manager
        onDataUpdated()
        self.anyCancellable = self.manager.objectWillChange.sink { [unowned self] (_) in
            DispatchQueue.main.async {
                allDetails = manager.getAll().map {
                    TabGroupCardDetails(tabGroup: $0, tabGroupManager: manager)
                }
                if detailedTabGroup != nil {
                    detailedTabGroup = allDetails.first {
                        $0.id == detailedTabGroup?.id
                    }
                    detailedTabGroup?.isShowingDetails = true
                }
                representativeTabs = manager.getAll()
                    .reduce(into: [Tab]()) { $0.append($1.children.first!) }
                allDetails.forEach { details in
                    let detailID = details.id
                    details.$isShowingDetails.sink { [weak self] showingDetails in
                        if showingDetails {
                            withAnimation {
                                self?.detailedTabGroup =
                                    self?.allDetails.first(where: { $0.id == detailID })
                            }
                        }
                    }.store(in: &detailsSubscriptions)
                }
            }
        }
    }

    func onDataUpdated() {
        onViewUpdate()
        representativeTabs = manager.getAll()
            .reduce(into: [Tab]()) { $0.append($1.children.first!) }
        allDetails = manager.getAll()
            .map {
                TabGroupCardDetails(
                    tabGroup: $0,
                    tabGroupManager: manager)
            }
        objectWillChange.send()
    }
}
