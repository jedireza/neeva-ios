// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Combine
import Defaults
import Shared

struct HallOfShameDomain {
    let domain: TrackingEntity
    let count: Int
}

class TrackingMenuModel: ObservableObject {
    // MARK: - Properties
    @Published private(set) var numDomains = 0
    @Published private(set) var hallOfShameDomains = [HallOfShameDomain]()
    @Published var preventTrackersForCurrentPage: Bool {
        didSet {
            setTrackingProtectionAllowedForCurrentPage(preventTrackersForCurrentPage)
        }
    }

    var viewVisible: Bool = false
    var numTrackers: Int {
        if let numTrackersTesting = numTrackersTesting {
            return numTrackersTesting
        } else {
            return selectedTab?.contentBlocker?.stats.domains.count ?? 0
        }
    }

    private var subscriptions: Set<AnyCancellable> = []
    private var statsSubscription: AnyCancellable? = nil
    private var selectedTab: Tab? = nil {
        didSet {
            statsSubscription = nil

            guard let domain = selectedTab?.currentURL()?.host else {
                preventTrackersForCurrentPage = false
                return
            }

            preventTrackersForCurrentPage = TrackingPreventionConfig.trackersAllowedFor(domain)
        }
    }

    // MARK: - Test Properties
    private(set) var numTrackersTesting: Int?
    private(set) var trackers: [TrackingEntity] {
        didSet {
            onDataUpdated()
        }
    }

    // MARK: - Methods
    func refreshStats() {
        guard let tab = selectedTab else {
            return
        }

        let trackingData = TrackingEntity.getTrackingDataForCurrentTab(
            stats: tab.contentBlocker?.stats)
        self.numDomains = trackingData.numDomains
        self.trackers = trackingData.trackingEntities
        onDataUpdated()
        statsSubscription = selectedTab?.contentBlocker?.$stats
            .filter { [weak self] _ in self?.viewVisible ?? false }
            .map { TrackingEntity.getTrackingDataForCurrentTab(stats: $0) }
            .sink { [weak self] data in
                guard let self = self else { return }
                self.numDomains = data.numDomains
                self.trackers = data.trackingEntities
                self.onDataUpdated()
            }
    }

    private func onDataUpdated() {
        hallOfShameDomains =
            trackers
            .reduce(into: [:]) { dict, tracker in dict[tracker] = (dict[tracker] ?? 0) + 1 }
            .map { HallOfShameDomain(domain: $0.key, count: $0.value) }
            .sorted(by: { $0.count > $1.count })
            .prefix(3)
            .toArray()
    }

    public func setTrackingProtectionAllowedForCurrentPage(_ allowed: Bool) {
        let trackersAllowed = !allowed

        guard let domain = selectedTab?.currentURL()?.host,
            TrackingPreventionConfig.trackersAllowedFor(domain) != trackersAllowed
        else {
            return
        }

        ClientLogger.shared.logCounter(
            preventTrackersForCurrentPage ? .TurnOnBlockTracking : .TurnOffBlockTracking,
            attributes: EnvironmentHelper.shared.getAttributes() + [
                ClientLogCounterAttribute(
                    key: LogConfig.TrackingProtectionAttribute.toggleProtectionForURL,
                    value: selectedTab?.currentURL()?.absoluteString)
            ]
        )

        TrackingPreventionConfig.updateAllowList(
            with: domain, allowed: trackersAllowed
        ) {
            self.selectedTab?.contentBlocker?.notifiedTabSetupRequired()
            self.selectedTab?.reload()
            self.refreshStats()
        }
    }

    // MARK: - init
    init(tabManager: TabManager) {
        self.selectedTab = tabManager.selectedTab
        self.preventTrackersForCurrentPage =
            !Defaults[.unblockedDomains].contains(selectedTab?.currentURL()?.host ?? "")
        let trackingData = TrackingEntity.getTrackingDataForCurrentTab(
            stats: selectedTab?.contentBlocker?.stats)
        self.numDomains = trackingData.numDomains
        self.trackers = trackingData.trackingEntities
        tabManager.selectedTabPublisher.assign(to: \.selectedTab, on: self).store(
            in: &subscriptions)
        onDataUpdated()
    }

    /// For usage with static data and testing only
    init(testingData: TrackingData) {
        self.preventTrackersForCurrentPage = true
        self.numDomains = testingData.numDomains
        self.trackers = testingData.trackingEntities
        self.numTrackersTesting = testingData.numTrackers
        onDataUpdated()
    }
}
