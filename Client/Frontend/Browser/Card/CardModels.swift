// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Combine
import Defaults
import Shared
import Storage
import SwiftUI

protocol ThumbnailModel: ObservableObject {
    associatedtype Thumbnail: SelectableThumbnail
    var allDetails: [Thumbnail] { get }
}

protocol CardModel: ThumbnailModel {
    associatedtype Manager: AccessingManager
    associatedtype Details: CardDetails where Details.Item == Manager.Item
    var manager: Manager { get }
    var allDetails: [Details] { get set }
    var allDetailsWithExclusionList: [Details] { get }

    func onDataUpdated()
}

class TabCardModel: CardModel, TabEventHandler {
    private var onViewUpdate: () -> Void = {}
    var manager: TabManager
    private var groupManager: TabGroupManager
    private var anyCancellable: AnyCancellable? = nil

    @Published var allDetails: [TabCardDetails] = []
    @Published private(set) var allDetailsWithExclusionList: [TabCardDetails] = []
    @Published private(set) var selectedTabID: String? = nil

    var isCardGridEmpty: Bool {
        return allDetailsMatchingIncognitoState.isEmpty
    }

    var allDetailsMatchingIncognitoState: [TabCardDetails] {
        allDetails.filter {
            manager.get(for: $0.id)?.isIncognito ?? false == manager.isIncognito
        }
    }

    var normalDetails: [TabCardDetails] {
        allDetails.filter {
            manager.get(for: $0.id)?.isIncognito == false
        }
    }

    var incognitoDetails: [TabCardDetails] {
        allDetails.filter {
            manager.get(for: $0.id)?.isIncognito == true
        }
    }

    init(manager: TabManager, groupManager: TabGroupManager) {
        self.manager = manager
        self.groupManager = groupManager
        register(self, forTabEvents: .didClose, .didChangeURL)
        onDataUpdated()
        self.anyCancellable = manager.objectWillChange.sink { [weak self] (_) in
            if manager.didRestoreAllTabs {
                self?.onDataUpdated()
                self?.objectWillChange.send()
            }
        }
    }

    func tabDidClose(_ tab: Tab) {
        onDataUpdated()
    }

    struct Row: Identifiable {
        var id: Set<String> { Set(cells.map(\.id)) }
        enum Cell: Identifiable {
            case tab(TabCardDetails)
            case tabGroup(TabGroupCardDetails)

            var id: String {
                switch self {
                case .tab(let details):
                    return details.id
                case .tabGroup(let details):
                    return details.id
                }
            }
        }
        var cells: [Cell]
    }

    func buildRows(incognito: Bool, tabGroupModel: TabGroupCardModel, maxCols: Int) -> [Row] {
        allDetails.filter { tabCard in
            let tab = tabCard.manager.get(for: tabCard.id)!
            return
                (tabGroupModel.representativeTabs.contains(tab)
                || allDetailsWithExclusionList.contains { $0.id == tabCard.id })
                && tab.isIncognito == incognito
        }.reduce(into: []) { partialResult, details in
            let tabGroup = tabGroupModel.allDetails.first(where: { $0.id == details.rootID })
            if partialResult.isEmpty || partialResult.last?.cells.count == maxCols
                || tabGroup != nil
            {
                partialResult.append(Row(cells: [tabGroup.map(Row.Cell.tabGroup) ?? .tab(details)]))
                if tabGroup != nil {
                    partialResult.append(Row(cells: []))
                }
            } else {
                partialResult[partialResult.endIndex - 1].cells.append(.tab(details))
            }
        }.filter { !$0.cells.isEmpty }
    }

    func onDataUpdated() {
        groupManager.updateTabGroups()
        allDetails = manager.getAll()
            .map { TabCardDetails(tab: $0, manager: manager) }

        if FeatureFlag[.tabGroupsNewDesign] {
            modifyAllDetailsAvoidingSingleTabs(groupManager.childTabs)
        }

        allDetailsWithExclusionList = manager.getAll().filter {
            !groupManager.childTabs.contains($0)
        }
        .map { TabCardDetails(tab: $0, manager: manager) }
        selectedTabID = manager.selectedTab?.tabUUID ?? ""
        onViewUpdate()
    }

    private func modifyAllDetailsAvoidingSingleTabs(_ childTabs: [Tab]) {
        let tabGroupsFilter = manager.getAll().reduce(into: [Int]()) {
            let numToAppend = !childTabs.contains($1) ? (($0.last ?? 0) + 1) : 0
            $0.append(numToAppend)
        }

        var singleTabFilter = tabGroupsFilter.reduce(into: [Int]()) {
            if $1 == 0 && ($0.last ?? 0) % 2 == 1 {
                $0.append(-1)
            } else {
                $0.append($1)
            }
        }.map { $0 == -1 }.dropFirst()
        singleTabFilter.append(false)

        var index: Int = singleTabFilter.startIndex
        while !singleTabFilter.isEmpty && index < allDetails.count {
            guard var singleTabIndex = singleTabFilter[index...].firstIndex(where: { $0 }) else {
                break
            }

            singleTabIndex = singleTabIndex - 1

            let afterGroupIndex = tabGroupsFilter[(singleTabIndex + 1)...].firstIndex(where: {
                $0 > 0
            })

            guard let afterGroupIndex = afterGroupIndex else {
                let detail = allDetails.remove(at: singleTabIndex)
                allDetails.append(detail)
                break
            }

            let detail = allDetails.remove(at: singleTabIndex)
            allDetails.insert(detail, at: afterGroupIndex - 1)

            index = afterGroupIndex

            let closestSingleTab = singleTabFilter[index...].firstIndex(where: { $0 })
            let closestTabGroup = tabGroupsFilter[index...].firstIndex(where: { $0 == 0 })
            if let closestTabGroup = closestTabGroup {
                if closestTabGroup == closestSingleTab {
                    index = closestTabGroup + 1
                } else {
                    index = closestTabGroup
                    singleTabFilter[closestTabGroup] = true
                }
            }
        }
    }

    func getAllDetails(matchingIncognitoState: Bool?) -> [TabCardDetails] {
        if let matchingIncognitoState = matchingIncognitoState {
            return matchingIncognitoState ? incognitoDetails : normalDetails
        } else {
            return allDetails
        }
    }
}

func getLogCounterAttributesForSpaces(details: SpaceCardDetails?) -> [ClientLogCounterAttribute] {
    var attributes = EnvironmentHelper.shared.getAttributes()
    attributes.append(
        ClientLogCounterAttribute(
            key: LogConfig.SpacesAttribute.isPublic,
            value: String(details?.isSharedPublic ?? false)))
    if details?.isSharedPublic == true {
        attributes.append(
            ClientLogCounterAttribute(
                key: LogConfig.SpacesAttribute.spaceID,
                value: String(details?.id ?? "")))
    }
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
    @Published private(set) var manager = SpaceStore.shared
    @Published var allDetails: [SpaceCardDetails] = [] {
        didSet {
            allDetailsWithExclusionList = allDetails
        }
    }
    @Published private(set) var allDetailsWithExclusionList: [SpaceCardDetails] = []
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
                // Collect separately. View definition depends on aggregate stats policy
                ClientLogger.shared.logCounter(
                    .space_app_view,
                    attributes:
                        getLogCounterAttributesForSpaces(details: detailedSpace!))
                return
            }

            if let id = spaceNeedsRefresh {
                manager.refreshSpace(spaceID: id)
                spaceNeedsRefresh = nil
            }
        }
    }
    @Published var updatedItemIDs = [String]()
    @Published var filterState: SpaceFilterState = .allSpaces

    var detailsMatchingFilter: [SpaceCardDetails] {
        switch filterState {
        case .allSpaces:
            return allDetails
        case .ownedByMe:
            return allDetails.filter { $0.space?.userACL == .owner }
        }
    }

    private var onViewUpdate: () -> Void = {}
    var thumbnailURLCandidates = [URL: [URL]]()
    private var anyCancellable: AnyCancellable? = nil
    private var recommendationSubscription: AnyCancellable? = nil
    private var editingSubscription: AnyCancellable? = nil
    private var detailsSubscriptions: Set<AnyCancellable> = Set()
    private var spaceNeedsRefresh: String? = nil

    init(manager: SpaceStore = SpaceStore.shared) {
        self.manager = manager

        NeevaUserInfo.shared.$isUserLoggedIn.sink { isLoggedIn in
            DispatchQueue.main.async {
                // Refresh to get spaces for logged in users and to clear cache for logged out users
                SpaceStore.shared.refresh()
            }

            if !isLoggedIn {
                self.allDetails = []
            }
        }.store(in: &detailsSubscriptions)

        self.anyCancellable = manager.$state.sink { [weak self] state in
            guard let self = self, self.detailedSpace == nil, case .ready = state,
                manager.updatedSpacesFromLastRefresh.count > 0
            else {
                return
            }

            if manager.updatedSpacesFromLastRefresh.count == 1,
                let id = manager.updatedSpacesFromLastRefresh.first?.id.id,
                let indexInStore = manager.allSpaces.firstIndex(where: { $0.id.id == id }),
                let indexInDetails = self.allDetails.firstIndex(where: { $0.id == id })
            {
                // If only one space is updated and it exists inside the current details, then just
                // update its contents and move it to the right place, instead of resetting all.
                self.allDetails.first(where: { $0.id == id })?.updateDetails()
                if indexInStore != indexInDetails {
                    let indices: IndexSet = [indexInDetails]
                    self.allDetails.move(fromOffsets: indices, toOffset: indexInStore)
                }
                return
            }

            DispatchQueue.main.async {
                self.allDetails = manager.getAll().map {
                    SpaceCardDetails(space: $0, manager: manager)
                }
                self.allDetails.forEach { details in
                    let detailID = details.id
                    details.$isShowingDetails.sink { [weak self] showingDetails in
                        if showingDetails {
                            withAnimation {
                                self?.detailedSpace =
                                    self?.allDetails.first(where: { $0.id == detailID })
                            }
                        }
                    }.store(in: &self.detailsSubscriptions)
                }

                self.onViewUpdate()
                self.detailedSpace = self.allDetails.first { $0.isShowingDetails }
                self.objectWillChange.send()
            }
        }
    }

    func onDataUpdated() {
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
    }

    func add(spaceID: String, url: String, title: String, description: String? = nil) {
        DispatchQueue.main.async {
            let request = AddToSpaceWithURLRequest(
                spaceID: spaceID, url: url, title: title, description: description)
            request.$state.sink { state in
                self.spaceNeedsRefresh = spaceID
            }.cancel()
        }
    }

    func updateSpaceEntity(
        spaceID: String, entityID: String, title: String, snippet: String, thumbnail: String? = nil
    ) {
        DispatchQueue.main.async {
            let request = UpdateSpaceEntityRequest(
                spaceID: spaceID, entityID: entityID, title: title, snippet: snippet,
                thumbnail: thumbnail)
            request.$state.sink { state in
                self.spaceNeedsRefresh = spaceID
            }.cancel()
        }
    }

    func claimGeneratedItem(spaceID: String, entityID: String) {
        DispatchQueue.main.async {
            let request = ClaimGeneratedItem(spaceID: spaceID, entityID: entityID)
            request.$state.sink { state in
                self.spaceNeedsRefresh = spaceID
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
                self.spaceNeedsRefresh = spaceID
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
            } retryDeletion: { [weak self] in
                guard let self = self else { return }
                self.delete(
                    space: spaceID, entities: entities, from: scene, undoDeletion: undoDeletion)
            }
        }
    }

    func reorder(space spaceID: String, entities: [String]) {
        DispatchQueue.main.async {
            let request = ReorderSpaceRequest(spaceID: spaceID, ids: entities)
            request.$state.sink { state in
                self.spaceNeedsRefresh = spaceID
            }.cancel()
        }
    }

    func changePublicACL(space: Space, add: Bool) {
        DispatchQueue.main.async {
            if add {
                let request = AddPublicACLRequest(spaceID: space.id.id)
                request.$state.sink { state in
                    self.spaceNeedsRefresh = space.id.id
                    space.isPublic = true
                    self.objectWillChange.send()
                }.cancel()
            } else {
                let request = DeletePublicACLRequest(spaceID: space.id.id)
                request.$state.sink { state in
                    self.spaceNeedsRefresh = space.id.id
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
                self.spaceNeedsRefresh = space.id.id
                space.isShared = true
                self.objectWillChange.send()
            }.cancel()
        }
    }

    func updateSpaceHeader(
        space: Space, title: String,
        description: String? = nil, thumbnail: String? = nil
    ) {
        DispatchQueue.main.async {
            let request = UpdateSpaceRequest(
                spaceID: space.id.id, title: title,
                description: description, thumbnail: thumbnail)
            request.$state.sink { state in
                self.spaceNeedsRefresh = space.id.id
                space.name = title
                space.description = description
                space.thumbnail = thumbnail
                self.objectWillChange.send()
            }.cancel()
        }
    }

    func deleteGeneratorFromSpace(spaceID: String, generatorID: String) {
        DispatchQueue.main.async {
            let request = DeleteGeneratorRequest(spaceID: spaceID, generatorID: generatorID)
            request.$state.sink { state in
                self.spaceNeedsRefresh = spaceID
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
                    self.detailedSpace = nil
                    self.manager.refresh()
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
                    self.detailedSpace = nil
                    self.manager.refresh()
                case .failure:
                    self.editingSubscription?.cancel()
                case .initial:
                    Logger.browser.info("Waiting for success or failure")
                }
            }
        }
    }

    func recommendedSpaceSelected(details: SpaceCardDetails) {
        let spaceID = details.id
        let space = SpaceStore.suggested.allSpaces.first(where: {
            $0.id.id == spaceID
        })
        SpaceStore.onRecommendedSpaceSelected(space: space!)
        SpaceStore.shared.objectWillChange.send()
        recommendationSubscription = objectWillChange.sink {
            let newDetails = self.allDetails.first(where: {
                $0.id == spaceID
            })
            DispatchQueue.main.async {
                newDetails?.isShowingDetails = true
                self.spaceNeedsRefresh = spaceID
                self.recommendationSubscription?.cancel()
            }
        }
    }

    func promoCard() -> PromoCardType {
        return .blackFridayNotifyPromo(
            action: {
                ClientLogger.shared.logCounter(
                    .BlackFridayNotifyPromo)
                NotificationPermissionHelper.shared.requestPermissionIfNeeded(
                    completion: { authorized in
                        Defaults[.seenBlackFridayNotifyPromo] = true
                    },
                    callSite: .blackFriday
                )
            },
            onClose: {
                ClientLogger.shared.logCounter(
                    .CloseBlackFridayNotifyPromo)
                Defaults[.seenBlackFridayNotifyPromo] = true
            })
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
    @Default(.tabGroupNames) var tabGroupDict: [String: String]
    private var detailsSubscriptions: Set<AnyCancellable> = Set()
    private var screenshotsSubscriptions: Set<AnyCancellable> = Set()

    private var stateNeedsRefresh = false

    var allDetails: [TabGroupCardDetails] = [] {
        didSet {
            allDetailsWithExclusionList = allDetails
        }
    }
    @Published var allDetailsWithExclusionList: [TabGroupCardDetails] = []
    @Published var detailedTabGroup: TabGroupCardDetails? {
        willSet {
            if !FeatureFlag[.tabGroupsNewDesign] {
                guard let tabgroup = detailedTabGroup, newValue == nil else {
                    return
                }
                tabgroup.isShowingDetails = false
            }
        }
    }
    @Published var representativeTabs: [Tab] = []

    init(manager: TabGroupManager) {
        self.manager = manager

        onDataUpdated()
        setupDetailsListener()

        self.anyCancellable = self.manager.objectWillChange.sink {
            guard manager.tabManager.didRestoreAllTabs else {
                return
            }

            self.setupDetailsListener()
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
                    tabGroupManager: manager
                )
            }
        objectWillChange.send()
    }

    private func createIsShowingDetailsSink(
        details: TabGroupCardDetails?, storeIn: inout Set<AnyCancellable>
    ) {
        let id = details?.id
        details?.$isShowingDetails.sink { [weak self] showingDetails in
            if showingDetails {
                withAnimation {
                    self?.detailedTabGroup =
                        self?.allDetails.first(where: { $0.id == id })
                }
            } else {
                if FeatureFlag[.tabGroupsNewDesign] {
                    self?.detailedTabGroup = nil
                }
            }
        }.store(in: &storeIn)
    }

    func setupDetailsListener() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else {
                return
            }

            self.allDetails = self.manager.getAll().map {
                TabGroupCardDetails(tabGroup: $0, tabGroupManager: self.manager)
            }
            if self.detailedTabGroup != nil {
                self.detailedTabGroup = self.allDetails.first {
                    $0.id == self.detailedTabGroup?.id
                }
                self.detailedTabGroup?.isShowingDetails = true
            }
            self.manager.cleanUpTabGroupNames()
            self.representativeTabs = self.manager.getAll()
                .reduce(into: [Tab]()) { $0.append($1.children.first!) }
            self.allDetails.forEach { details in
                self.createIsShowingDetailsSink(
                    details: details, storeIn: &self.detailsSubscriptions)
            }
            self.manager.getAll().forEach { tabgroup in
                tabgroup.children.forEach { tab in
                    tab.$screenshotUUID.sink { [unowned self] (_) in
                        if let index = self.allDetails.firstIndex(where: {
                            $0.id == tab.rootUUID
                        }), let tabGroup = self.manager.tabGroups[tab.rootUUID] {
                            self.allDetails[index] = TabGroupCardDetails(
                                tabGroup: tabGroup, tabGroupManager: self.manager)
                            self.createIsShowingDetailsSink(
                                details: self.allDetails[index],
                                storeIn: &self.screenshotsSubscriptions)
                        }
                    }.store(in: &self.screenshotsSubscriptions)
                }
            }
        }
    }
}
