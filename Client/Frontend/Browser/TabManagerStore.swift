/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import Foundation
import Storage
import Shared
import XCGLogger

private let log = Logger.browserLogger
class TabManagerStore {
    static let shared = TabManagerStore(imageStore: DiskImageStore(files: getAppDelegateProfile().files, namespace: "TabManagerScreenshots", quality: UIConstants.ScreenshotQuality))

    fileprivate var lockedForReading = false
    public let imageStore: DiskImageStore?
    fileprivate var fileManager = FileManager.default
    fileprivate let serialQueue = DispatchQueue(label: "tab-manager-write-queue")
    fileprivate var writeOperation = DispatchWorkItem {}

    init(imageStore: DiskImageStore?, _ fileManager: FileManager = FileManager.default) {
        self.fileManager = fileManager
        self.imageStore = imageStore
    }

    var isRestoringTabs: Bool {
        return lockedForReading
    }

    fileprivate func getBasePath() -> String? {
        let profilePath: String?

        if  AppConstants.IsRunningTest || AppConstants.IsRunningPerfTest {
            profilePath = (UIApplication.shared.delegate as? TestAppDelegate)?.dirForTestProfile
        } else {
            profilePath = fileManager.containerURL(forSecurityApplicationGroupIdentifier: AppInfo.sharedContainerIdentifier)?.appendingPathComponent("profile.profile").path
        }

        guard let path = profilePath else { return nil }
        return path
    }

    fileprivate func getLegacyTabSavePath() -> String? {
        guard let path = getBasePath() else { return nil }
        return URL(fileURLWithPath: path).appendingPathComponent("tabsState.archive").path
    }

    fileprivate func tabSavePath(withId sceneId: String) -> String? {
        guard let path = getBasePath() else { return nil }
        let url = URL(fileURLWithPath: path).appendingPathComponent("tabsState.archive-\(sceneId)")
        return url.path
    }

    fileprivate func prepareSavedTabs(fromTabs tabs: [Tab], selectedTab: Tab?) -> [SavedTab]? {
        var savedTabs = [SavedTab]()
        var savedUUIDs = Set<String>()
        for tab in tabs {
            tab.tabUUID = tab.tabUUID.isEmpty ? UUID().uuidString : tab.tabUUID
            let savedTab = SavedTab(tab: tab, isSelected: tab == selectedTab, tabIndex: nil)
            savedTabs.append(savedTab)
            
            if let screenshot = tab.screenshot,
                let screenshotUUID = tab.screenshotUUID {
                savedUUIDs.insert(screenshotUUID.uuidString)

                imageStore?.put(screenshotUUID.uuidString, image: screenshot)
            }
        }
        // Clean up any screenshots that are no longer associated with a tab.
        _ = imageStore?.clearExcluding(savedUUIDs)
        return savedTabs.isEmpty ? nil : savedTabs
    }

    // Async write of the tab state. In most cases, code doesn't care about performing an operation
    // after this completes. Deferred completion is called always, regardless of Data.write return value.
    // Write failures (i.e. due to read locks) are considered inconsequential, as preserveTabs will be called frequently.
    @discardableResult func preserveTabs(_ tabs: [Tab], selectedTab: Tab?, for scene: UIScene) -> Success {
        assert(Thread.isMainThread)

        guard let savedTabs = prepareSavedTabs(fromTabs: tabs, selectedTab: selectedTab), let path = tabSavePath(withId: scene.session.persistentIdentifier) else {
            clearArchive(for: scene) 
            return succeed()
        }

        return saveTabsToPath(path: path, savedTabs: savedTabs)
    }

    func saveTabsToPath(path: String, savedTabs: [SavedTab]) -> Success {
        let result = Success()

        writeOperation = DispatchWorkItem {
            do {
                let data = try NSKeyedArchiver.archivedData(withRootObject: savedTabs, requiringSecureCoding: false)
                try data.write(to: URL(fileURLWithPath: path), options: .atomic)
                print("Tabs succesfully saved")
            } catch {
                print("Tab failed to save:", error.localizedDescription)
            }

            result.fill(Maybe(success: ()))
        }

        // Delay by 100ms to debounce repeated calls to preserveTabs in quick succession.
        // Notice above that a repeated 'preserveTabs' call will 'cancel()' a pending write operation.
        serialQueue.asyncAfter(deadline: .now() + 0.100, execute: writeOperation)

        return result
    }

    func restoreStartupTabs(for scene: UIScene, clearPrivateTabs: Bool, tabManager: TabManager) -> Tab? {
        let selectedTab = restoreTabs(savedTabs: getStartupTabs(for: scene), clearPrivateTabs: clearPrivateTabs, tabManager: tabManager)
        return selectedTab
    }

    func restoreTabs(savedTabs: [SavedTab], clearPrivateTabs: Bool, tabManager: TabManager) -> Tab? {
        assertIsMainThread("Restoration is a main-only operation")
        guard !lockedForReading, savedTabs.count > 0 else { return nil }

        lockedForReading = true
        defer {
            lockedForReading = false
        }

        var savedTabs = savedTabs

        // Make sure to wipe the private tabs if the user has the pref turned on
        if clearPrivateTabs {
            savedTabs = savedTabs.filter { !$0.isPrivate }
        }

        var tabToSelect: Tab?
        for savedTab in savedTabs {
            // Provide an empty request to prevent a new tab from loading the home screen
            var tab = tabManager.addTab(flushToDisk: false, zombie: true, isPrivate: savedTab.isPrivate)
            tab = savedTab.configureSavedTabUsing(tab, imageStore: imageStore)

            if savedTab.isSelected {
                tabToSelect = tab
            }
        }

        if tabToSelect == nil {
            tabToSelect = tabManager.tabs.first(where: { $0.isPrivate == false })
        }

        return tabToSelect
    }

    func clearArchive(for scene: UIScene?) {
        var path: String?

        if let scene = scene {
            path = tabSavePath(withId: scene.session.persistentIdentifier)
        } else {
            path = getLegacyTabSavePath()
        }

        if let path = path {
            try? FileManager.default.removeItem(atPath: path)
        }
    }

    func getStartupTabs(for scene: UIScene?) -> [SavedTab] {
        let savedTabsWithOldPath = SiteArchiver.tabsToRestore(tabsStateArchivePath: getLegacyTabSavePath())

        guard let scene = scene else {
            return savedTabsWithOldPath
        }

        let savedTabsWithNewPath = SiteArchiver.tabsToRestore(tabsStateArchivePath: tabSavePath(withId: scene.session.persistentIdentifier))

        if savedTabsWithNewPath.count > 0 {
            return savedTabsWithNewPath
        } else {
            return savedTabsWithOldPath
        }
    }
}

// Functions for testing
extension TabManagerStore {
    func testTabCountOnDisk() -> Int {
        assert(AppConstants.IsRunningTest)
        return SiteArchiver.tabsToRestore(tabsStateArchivePath: tabSavePath(withId: SceneDelegate.getCurrentSceneId())).count
    }
}
