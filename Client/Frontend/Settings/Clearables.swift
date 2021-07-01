/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import Foundation
import Shared
import WebKit
import SDWebImage
import CoreSpotlight

private let log = Logger.browserLogger

// A base protocol for something that can be cleared.
protocol Clearable {
    func clear() -> Success
    var label: String { get }
}

// Clears our browsing history, including favicons and thumbnails.
class HistoryClearable: Clearable {
    let profile: Profile
    init(profile: Profile) {
        self.profile = profile
    }

    var label: String { .ClearableHistory }

    func clear() -> Success {

        // Treat desktop sites as part of browsing history.
        Tab.ChangeUserAgent.clear()
        BrowserViewController.foregroundBVC().tabManager.recentlyClosedTabs.removeAll()

        return profile.history.clearHistory().bindQueue(.main) { success in
            SDImageCache.shared.clearDisk()
            SDImageCache.shared.clearMemory()
            CSSearchableIndex.default().deleteAllSearchableItems()
            NotificationCenter.default.post(name: .PrivateDataClearedHistory, object: nil)
            log.debug("HistoryClearable succeeded: \(success).")
            return Deferred(value: success)
        }
    }
}

// Clear the web cache. Note, this has to close all open tabs in order to ensure the data
// cached in them isn't flushed to disk.
class CacheClearable: Clearable {
    let tabManager: TabManager
    init(tabManager: TabManager) {
        self.tabManager = tabManager
    }

    var label: String { .ClearableCache }

    func clear() -> Success {
        let dataTypes = Set([WKWebsiteDataTypeFetchCache, WKWebsiteDataTypeDiskCache, WKWebsiteDataTypeMemoryCache, WKWebsiteDataTypeOfflineWebApplicationCache, WKWebsiteDataTypeServiceWorkerRegistrations])
        WKWebsiteDataStore.default().removeData(ofTypes: dataTypes, modifiedSince: .distantPast, completionHandler: {})

        MemoryReaderModeCache.sharedInstance.clear()
        DiskReaderModeCache.sharedInstance.clear()

        log.debug("CacheClearable succeeded.")
        return succeed()
    }
}

// Remove all cookies stored by the site. This includes localStorage, sessionStorage, and WebSQL/IndexedDB.
class CookiesClearable: Clearable {
    let tabManager: TabManager
    init(tabManager: TabManager) {
        self.tabManager = tabManager
    }

    var label: String { .ClearableCookies }

    func clear() -> Success {
        let dataTypes = Set([WKWebsiteDataTypeCookies, WKWebsiteDataTypeLocalStorage, WKWebsiteDataTypeSessionStorage, WKWebsiteDataTypeWebSQLDatabases, WKWebsiteDataTypeIndexedDBDatabases])
        WKWebsiteDataStore.default().removeData(ofTypes: dataTypes, modifiedSince: .distantPast, completionHandler: {})

        log.debug("CookiesClearable succeeded.")
        return succeed()
    }
}

class TrackingProtectionClearable: Clearable {
    //@TODO: re-using string because we are too late in cycle to change strings
    var label: String {
        return Strings.SettingsTrackingProtectionSectionName
    }

    func clear() -> Success {
        let result = Success()
        ContentBlocker.shared.clearSafelist() {
            result.fill(Maybe(success: ()))
        }
        return result
    }
}

// Clears our downloaded files in the `~/Documents/Downloads` folder.
class DownloadedFilesClearable: Clearable {
    var label: String { .ClearableDownloads }

    func clear() -> Success {
        if let downloadsPath = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent("Downloads"),
            let files = try? FileManager.default.contentsOfDirectory(at: downloadsPath, includingPropertiesForKeys: nil, options: [.skipsHiddenFiles, .skipsPackageDescendants, .skipsSubdirectoryDescendants]) {
            for file in files {
                try? FileManager.default.removeItem(at: file)
            }
        }

        NotificationCenter.default.post(name: .PrivateDataClearedDownloadedFiles, object: nil)

        return succeed()
    }
}
