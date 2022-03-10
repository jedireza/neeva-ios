// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Shared
import XCGLogger

private let log = Logger.browser

extension TabManager {
    func removeTab(_ tab: Tab, showToast: Bool = false, updateSelectedTab: Bool = true) {
        guard let index = tabs.firstIndex(where: { $0 === tab }) else { return }
        addTabsToRecentlyClosed([tab], showToast: showToast)
        removeTab(tab, flushToDisk: true, notify: true)

        if updateSelectedTab {
            updateSelectedTabAfterRemovalOf(tab, deletedIndex: index)
        }
    }

    func removeTabs(
        _ tabsToBeRemoved: [Tab], showToast: Bool = true,
        updateSelectedTab: Bool = true
    ) {
        guard tabsToBeRemoved.count > 0 else {
            return
        }

        addTabsToRecentlyClosed(tabsToBeRemoved, showToast: showToast)

        let lastTab = tabsToBeRemoved[tabsToBeRemoved.count - 1]
        let lastTabIndex = tabs.firstIndex(of: lastTab)
        let tabsToKeep = self.tabs.filter { !tabsToBeRemoved.contains($0) }
        self.tabs = tabsToKeep

        if let lastTabIndex = lastTabIndex, updateSelectedTab {
            updateSelectedTabAfterRemovalOf(lastTab, deletedIndex: lastTabIndex)
        }

        tabsToBeRemoved.forEach { tab in
            tab.close()
            TabEvent.post(.didClose, for: tab)
        }

        tabsUpdatedPublisher.send()
        storeChanges()
    }

    /// Removes the tab from TabManager, alerts delegates, and stores data.
    /// - Parameter notify: if set to true, will call the delegate after the tab
    ///   is removed.
    private func removeTab(_ tab: Tab, flushToDisk: Bool, notify: Bool) {
        guard let removalIndex = tabs.firstIndex(where: { $0 === tab }) else {
            log.error("Could not find index of tab to remove, tab count: \(count)")
            return
        }

        tabs.remove(at: removalIndex)
        tab.close()

        if tab.isIncognito && incognitoTabs.count < 1 {
            incognitoConfiguration = TabManager.makeWebViewConfig(isIncognito: true)
        }

        if notify {
            TabEvent.post(.didClose, for: tab)
            tabsUpdatedPublisher.send()
        }

        if flushToDisk {
            storeChanges()
        }
    }

    private func updateSelectedTabAfterRemovalOf(_ tab: Tab, deletedIndex: Int) {
        let closedLastNormalTab = !tab.isIncognito && normalTabs.isEmpty
        let closedLastIncognitoTab = tab.isIncognito && incognitoTabs.isEmpty
        let viableTabs: [Tab] = tab.isIncognito ? incognitoTabs : normalTabs
        let bvc = SceneDelegate.getBVC(with: scene)

        if closedLastNormalTab || closedLastIncognitoTab {
            DispatchQueue.main.async {
                bvc.showTabTray()
            }
        } else if tab == selectedTab {
            if !selectParentTab(afterRemoving: tab) {
                if let rightOrLeftTab = viableTabs[safe: deletedIndex]
                    ?? viableTabs[safe: deletedIndex - 1]
                {
                    selectTab(rightOrLeftTab, previous: tab)
                } else {
                    selectTab(mostRecentTab(inTabs: viableTabs) ?? viableTabs.last, previous: tab)
                }
            }
        }
    }

    // MARK: - Remove All Tabs
    func removeAllTabs() {
        removeTabs(tabs, showToast: false)
    }

    func removeAllIncognitoTabs() {
        removeTabs(incognitoTabs, updateSelectedTab: true)
        incognitoConfiguration = TabManager.makeWebViewConfig(isIncognito: true)
    }

    // MARK: - Recently Closed Tabs
    func getRecentlyClosedTabForURL(_ url: URL) -> SavedTab? {
        assert(Thread.isMainThread)
        return recentlyClosedTabs.joined().filter({ $0.url == url }).first
    }

    func addTabsToRecentlyClosed(_ tabs: [Tab], showToast: Bool) {
        // Avoid remembering incognito tabs.
        let tabs = tabs.filter { !$0.isIncognito }
        if tabs.isEmpty {
            return
        }

        let savedTabs = tabs.map {
            SavedTab(
                tab: $0, isSelected: selectedTab === $0, tabIndex: self.tabs.firstIndex(of: $0))
        }
        recentlyClosedTabs.insert(savedTabs, at: 0)

        if showToast {
            closedTabsToShowToastFor.append(contentsOf: savedTabs)

            timerToTabsToast?.invalidate()
            timerToTabsToast = Timer.scheduledTimer(
                withTimeInterval: toastGroupTimerInterval, repeats: false,
                block: { _ in
                    ToastDefaults().showToastForClosedTabs(
                        self.closedTabsToShowToastFor, tabManager: self)
                    self.closedTabsToShowToastFor.removeAll()
                })
        }
    }
}
