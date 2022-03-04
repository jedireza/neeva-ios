// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Shared
import Storage

extension TabManager {
    enum CreateOrSwitchToTabResult {
        case createdNewTab
        case switchedToExistingTab
    }

    @discardableResult func createOrSwitchToTab(
        for url: URL,
        query: String? = nil, suggestedQuery: String? = nil,
        visitType: VisitType? = nil
    )
        -> CreateOrSwitchToTabResult
    {
        if let existingTab = getTabFor(url) {
            select(existingTab)
            existingTab.browserViewController?
                .postLocationChangeNotificationForTab(existingTab, visitType: visitType)
            return .switchedToExistingTab
        } else {
            select(
                addTab(
                    URLRequest(url: url),
                    flushToDisk: true,
                    zombie: false,
                    isIncognito: isIncognito,
                    query: query,
                    suggestedQuery: suggestedQuery,
                    visitType: visitType
                )
            )
            return .createdNewTab
        }
    }

    @discardableResult func createOrSwitchToTabForSpace(for url: URL, spaceID: String)
        -> CreateOrSwitchToTabResult
    {
        if let tab = selectedTab {
            ScreenshotHelper(controller: SceneDelegate.getBVC(with: scene)).takeScreenshot(tab)
        }

        if let existingTab = getTabFor(url) {
            existingTab.parentSpaceID = spaceID
            existingTab.rootUUID = spaceID
            select(existingTab)
            return .switchedToExistingTab
        } else {
            let newTab = addTab(
                URLRequest(url: url), flushToDisk: true, zombie: false, isIncognito: isIncognito)
            newTab.parentSpaceID = spaceID
            newTab.rootUUID = spaceID
            select(newTab)
            return .createdNewTab
        }
    }
}
