// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Combine
import Foundation
import Shared
import SwiftUI

public class CheatsheetMenuViewModel: ObservableObject {
    @Published private(set) var cheatsheetInfo: CheatsheetQueryController.CheatsheetInfo?
    @Published private(set) var searchRichResults: [SearchController.RichResult]?
    @Published private(set) var currentPageURL: URL?
    @Published private(set) var cheatsheetDataLoading: Bool
    @Published private(set) var currentCheatsheetQuery: String?

    private var subscriptions: Set<AnyCancellable> = []

    init(tabManager: TabManager) {
        self.cheatsheetInfo = tabManager.selectedTab?.cheatsheetData
        self.searchRichResults = tabManager.selectedTab?.searchRichResults
        self.currentPageURL = tabManager.selectedTab?.webView?.url
        self.cheatsheetDataLoading = tabManager.selectedTab?.cheatsheetDataLoading ?? false
        self.currentCheatsheetQuery = tabManager.selectedTab?.currentCheatsheetQuery

        tabManager.selectedTab?.$cheatsheetDataLoading.assign(to: \.cheatsheetDataLoading, on: self)
            .store(in: &subscriptions)

        tabManager.selectedTab?.$currentCheatsheetQuery.assign(
            to: \.currentCheatsheetQuery, on: self
        )
        .store(in: &subscriptions)

        tabManager.selectedTab?.$cheatsheetData.assign(to: \.cheatsheetInfo, on: self).store(
            in: &subscriptions)

        tabManager.selectedTab?.$searchRichResults.assign(to: \.searchRichResults, on: self).store(
            in: &subscriptions)

        tabManager.selectedTab?.$url.assign(to: \.currentPageURL, on: self).store(
            in: &subscriptions)
    }
}
