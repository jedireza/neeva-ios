/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import Foundation
import Shared

// Struct that retrives saved tabs and simple tabs dictionary for WidgetKit
struct SiteArchiver {
    static func tabsToRestore(tabsStateArchivePath: String?) -> ([SavedTab], [String: SimpleTab]) {
        // Get simple tabs for widgetkit
        let simpleTabsDict = SimpleTab.getSimpleTabs()
        
        guard let tabStateArchivePath = tabsStateArchivePath,
              FileManager.default.fileExists(atPath: tabStateArchivePath),
              let tabData = try? Data(contentsOf: URL(fileURLWithPath: tabStateArchivePath)) else {
            print(tabsStateArchivePath ?? "", "path doesn't exist")
            return ([SavedTab](), simpleTabsDict)
        }

        // modern swift way of restoring tabs
        do {
            if let savedTabs = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(tabData) as? [SavedTab], savedTabs.count > 0 {
                return (savedTabs, simpleTabsDict)
            }
        } catch {
            print(error.localizedDescription)
        }

        print("Falling back to old unarchiver format")

        // revert to old way if no tabs exist
        // (maybe just updated and older tabs exist)
        let unarchiver = NSKeyedUnarchiver(forReadingWith: tabData)
        unarchiver.setClass(SavedTab.self, forClassName: "Client.SavedTab")
        unarchiver.setClass(SessionData.self, forClassName: "Client.SessionData")
        unarchiver.decodingFailurePolicy = .setErrorAndReturn

        guard let oldRestoredTabs = unarchiver.decodeObject(forKey: "tabs") as? [SavedTab] else {
            Sentry.shared.send( message: "Failed to restore tabs", tag: .tabManager, severity: .error, description: "\(unarchiver.error ??? "nil")")
            SimpleTab.saveSimpleTab(tabs: nil)
            return ([SavedTab](), simpleTabsDict)
        }

        return (oldRestoredTabs, simpleTabsDict)
    }
}
