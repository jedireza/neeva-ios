/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import Foundation
import Shared
import Storage
import XCGLogger

private let log = Logger.storage

public class TabManagerStore {
    static let shared = TabManagerStore(
        imageStore: DiskImageStore(
            files: getAppDelegate().profile.files, namespace: "TabManagerScreenshots",
            quality: UIConstants.ScreenshotQuality))

    fileprivate var lockedForReading = false
    public let imageStore: DiskImageStore?
    fileprivate var fileManager = FileManager.default
    private var backgroundFileWriters: [String: BackgroundFileWriter] = [:]

    init(imageStore: DiskImageStore?, _ fileManager: FileManager = FileManager.default) {
        self.fileManager = fileManager
        self.imageStore = imageStore
    }

    var isRestoringTabs: Bool {
        return lockedForReading
    }

    fileprivate func getBasePath() -> String? {
        let profilePath: String?

        if AppConstants.IsRunningTest || AppConstants.IsRunningPerfTest {
            profilePath = (UIApplication.shared.delegate as? TestAppDelegate)?.dirForTestProfile
        } else {
            profilePath =
                fileManager.containerURL(
                    forSecurityApplicationGroupIdentifier: AppInfo.sharedContainerIdentifier)?
                .appendingPathComponent("profile.profile").path
        }

        guard let path = profilePath else { return nil }
        return path
    }

    fileprivate func fallbackTabsPath() -> String? {
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
                let screenshotUUID = tab.screenshotUUID
            {
                savedUUIDs.insert(screenshotUUID.uuidString)

                imageStore?.put(screenshotUUID.uuidString, image: screenshot)
            }
        }
        // Clean up any screenshots that are no longer associated with a tab.
        _ = imageStore?.clearExcluding(savedUUIDs)
        return savedTabs.isEmpty ? nil : savedTabs
    }

    private func backgroundFileWriter(for path: String) -> BackgroundFileWriter {
        if let backgroundFileWriter = backgroundFileWriters[path] {
            return backgroundFileWriter
        }
        let writer = BackgroundFileWriter(label: "tabs", path: path)
        backgroundFileWriters[path] = writer
        return writer
    }

    // Async write of the tab state. In most cases, code doesn't care about performing an operation
    // after this completes. Deferred completion is called always, regardless of Data.write return value.
    // Write failures (i.e. due to read locks) are considered inconsequential, as preserveTabs will be called frequently.
    func preserveTabs(_ tabs: [Tab], selectedTab: Tab?, for scene: UIScene) {
        log.info("Preserve tabs for scene: \(scene.session.persistentIdentifier)")

        assert(Thread.isMainThread)

        guard let savedTabs = prepareSavedTabs(fromTabs: tabs, selectedTab: selectedTab),
            let path = tabSavePath(withId: scene.session.persistentIdentifier)
        else {
            clearArchive(for: scene)
            return
        }

        // Save a fallback copy in case the scene persistanceID changes
        // Prevents the loss of user's tabs
        if let fallbackTabsPath = fallbackTabsPath() {
            saveTabsToPath(path: fallbackTabsPath, savedTabs: savedTabs)
        }

        saveTabsToPath(path: path, savedTabs: savedTabs)
    }

    func saveTabsToPath(path: String, savedTabs: [SavedTab]) {
        log.info("Saving to \(path), number of tabs: \(savedTabs.count)")

        let data: Data
        do {
            data = try NSKeyedArchiver.archivedData(
                withRootObject: savedTabs, requiringSecureCoding: false)
        } catch {
            log.error("Failed to create data archive for tabs: \(error.localizedDescription)")
            return
        }

        backgroundFileWriter(for: path).writeData(data: data)
    }

    func restoreStartupTabs(for scene: UIScene, clearPrivateTabs: Bool, tabManager: TabManager)
        -> Tab?
    {
        let selectedTab = restoreTabs(
            savedTabs: getStartupTabs(for: scene), clearPrivateTabs: clearPrivateTabs,
            tabManager: tabManager)
        return selectedTab
    }

    func restoreTabs(savedTabs: [SavedTab], clearPrivateTabs: Bool, tabManager: TabManager) -> Tab?
    {
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
            var tab = tabManager.addTab(
                flushToDisk: false, zombie: true, isPrivate: savedTab.isPrivate)
            tab = savedTab.configureSavedTabUsing(tab, imageStore: imageStore)

            if savedTab.isSelected {
                tabToSelect = tab
            }
        }

        if tabToSelect == nil {
            if !tabManager.normalTabs.isEmpty {
                tabToSelect = tabManager.tabs.first(where: { $0.isIncognito == false })
            } else {
                SceneDelegate.getBVC(with: tabManager.scene).showTabTray()
            }
        }

        return tabToSelect
    }

    func clearArchive(for scene: UIScene) {
        var path: String?

        log.info("Clearing archive for scene: \(scene.session.persistentIdentifier)")
        path = tabSavePath(withId: scene.session.persistentIdentifier)

        if let path = path {
            log.info("Removing \(path)")
            try? FileManager.default.removeItem(atPath: path)
        }

        if let fallbackTabsPath = fallbackTabsPath() {
            log.info("Removing \(fallbackTabsPath)")
            try? FileManager.default.removeItem(atPath: fallbackTabsPath)
        }
    }

    func getStartupTabs(for scene: UIScene) -> [SavedTab] {
        log.info("Getting startup tabs for scene: \(scene.session.persistentIdentifier)")

        let path = tabSavePath(withId: scene.session.persistentIdentifier)
        log.info("Restoring tabs from \(path ?? "")")

        let savedTabsWithNewPath = SiteArchiver.tabsToRestore(tabsStateArchivePath: path)
        let fallbackTabs = SiteArchiver.tabsToRestore(
            tabsStateArchivePath: fallbackTabsPath())

        if let savedTabsWithNewPath = savedTabsWithNewPath {
            return savedTabsWithNewPath
        } else if let fallbackTabs = fallbackTabs {
            return fallbackTabs
        } else {
            return [SavedTab]()
        }
    }
}

// Functions for testing
extension TabManagerStore {
    func testTabCountOnDisk(sceneId: String) -> Int {
        assert(AppConstants.IsRunningTest)
        return
            SiteArchiver.tabsToRestore(
                tabsStateArchivePath: tabSavePath(withId: sceneId)
            )?.count ?? 0
    }
}
