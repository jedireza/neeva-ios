// Copyright Neeva. All rights reserved.

import SwiftUI
import Storage
import Shared
import Combine

protocol ThumbnailModel: ObservableObject {
    associatedtype Thumbnail : SelectableThumbnail
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
    var onViewUpdate: () -> () = {}
    var manager: TabManager
    var groupManager: TabGroupManager
    var anyCancellable: AnyCancellable? = nil

    @Published var allDetails: [TabCardDetails] = []
    @Published var allDetailsWithExclusionList: [TabCardDetails] = []

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
        guard let url = tab.url, InternalURL(url)?.isAboutHomeURL ?? false else {
            return
        }
        onDataUpdated()
    }

    func tab(_ tab: Tab, didChangeURL url: URL) {
        guard let selectedTab = self.manager.selectedTab, selectedTab == tab else {
            return
        }

        ScreenshotHelper().takeScreenshot(tab)
        onDataUpdated()
    }

    func onDataUpdated() {
        groupManager.updateTabGroups()
        let childTabs = groupManager.getAll()
            .reduce(into: [Tab]()) { $0.append(contentsOf: $1.children) }
        allDetails = manager.getAll()
            .map {TabCardDetails(tab: $0, manager: manager)}
        allDetailsWithExclusionList = manager.getAll().filter { !childTabs.contains($0) }
            .map {TabCardDetails(tab: $0, manager: manager)}
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
    var onViewUpdate: () -> () = {}
    var anyCancellable: AnyCancellable? = nil

    init() {
        manager.refresh()
        self.anyCancellable = manager.objectWillChange.sink { [weak self] (_) in
            self?.allDetails = self?.manager.getAll().map {SpaceCardDetails(space: $0)} ?? []
            self?.onViewUpdate()
            self?.objectWillChange.send()
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
    var profile: Profile

    init(urls: [URL], profile: Profile) {
        self.profile = profile
        self.allDetails = urls.reduce(into: []) {
            $0.append(SiteCardDetails(url: $1, profile: profile, fetcher: manager))
        }
        self.anyCancellable = manager.objectWillChange.sink { [weak self] (_) in
            self?.objectWillChange.send()
        }
    }

    func refresh(urls: [URL]) {
        self.allDetails = urls.reduce(into: []) {
            $0.append(SiteCardDetails(url: $1, profile: profile, fetcher: manager))
        }
    }

    func onDataUpdated() {}
}

class TabGroupCardModel: CardModel {
    var onViewUpdate: () -> () = {}
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
            .map { TabGroupCardDetails(
                tabGroup: $0,
                tabGroupManager: manager) }
        objectWillChange.send()
    }
}
