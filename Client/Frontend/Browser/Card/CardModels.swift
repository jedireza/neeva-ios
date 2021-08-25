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
        // Tab tray cannot be empty in incognito mode
        FeatureFlag[.emptyTabTray] && !manager.isIncognito && manager.normalTabs.count == 0
    }

    init(manager: TabManager, groupManager: TabGroupManager) {
        self.manager = manager
        self.groupManager = groupManager
        register(self, forTabEvents: .didClose, .didChangeURL, .didGainFocus)
        onDataUpdated()
        self.anyCancellable = manager.objectWillChange.sink { [weak self] (_) in
            self?.onDataUpdated()
            self?.objectWillChange.send()
        }
    }

    func tabDidClose(_ tab: Tab) {
        onDataUpdated()
    }

    func tabDidGainFocus(_ tab: Tab) {
        guard let url = tab.url, InternalURL(url)?.isZeroQueryURL ?? false else {
            return
        }

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
    }

    var onViewUpdate: () -> Void = {}
    var anyCancellable: AnyCancellable? = nil
    var detailsSubscriptions: Set<AnyCancellable> = Set()

    init(bvc: BrowserViewController) {
        manager.refresh()

        self.anyCancellable = manager.objectWillChange.receive(on: DispatchQueue.main).sink { [unowned self] (_) in
            allDetails = manager.getAll().map { SpaceCardDetails(space: $0, bvc: bvc) }
            allDetails.forEach { details in
                details.$isShowingDetails.sink { [weak self] showingDetails in
                    if showingDetails {
                        withAnimation {
                            self?.detailedSpace = details
                        }
                    }
                }.store(in: &detailsSubscriptions)
            }

            onViewUpdate()
            detailedSpace = allDetails.first { $0.isShowingDetails }
            objectWillChange.send()
        }
    }

    func onDataUpdated() {}
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

    var allDetails: [TabGroupCardDetails] = [] {
        didSet {
            allDetailsWithExclusionList = allDetails
        }
    }
    var allDetailsWithExclusionList: [TabGroupCardDetails] = []

    init(manager: TabGroupManager) {
        self.manager = manager
        onDataUpdated()
        self.anyCancellable = self.manager.objectWillChange.sink { [weak self] (_) in
            self?.onDataUpdated()
            self?.objectWillChange.send()
        }
    }

    func onDataUpdated() {
        onViewUpdate()
        allDetails = manager.getAll()
            .map {
                TabGroupCardDetails(
                    tabGroup: $0,
                    tabGroupManager: manager)
            }
        objectWillChange.send()
    }
}
