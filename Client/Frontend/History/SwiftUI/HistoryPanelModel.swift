// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Foundation
import Combine
import Shared
import Storage
import WebKit
import XCGLogger
import SwiftUI

class HistoryPanelModel {
    private let profile: Profile
    private let tabManager: TabManager
    
    private let queryFetchLimit = 0
    private var currentFetchOffset = 0
    private var isFetchInProgress = false
    
    @Published var groupedSites = DateGroupedTableData<Site>()
    
    // MARK: - Data
    func reloadData() {
        guard !isFetchInProgress, !profile.isShutdown else { return }
        
        groupedSites = DateGroupedTableData<Site>()

        currentFetchOffset = 0
        fetchData().uponQueue(.main) { result in
            if let sites = result.successValue {
                for site in sites.compactMap({ $0 }) {
                    if let site = site, let latestVisit = site.latestVisit {
                        self.groupedSites.add(
                            site, timestamp: TimeInterval.fromMicrosecondTimestamp(latestVisit.date)
                        )
                    }
                }
            }
        }
    }

    func fetchData() -> Deferred<Maybe<Cursor<Site?>>> {
        guard !isFetchInProgress else {
            return deferMaybe(FetchInProgressError())
        }

        isFetchInProgress = true

        return profile.history.getSitesByLastVisit(
            limit: queryFetchLimit, offset: currentFetchOffset) >>== { result in
                // Force 100ms delay between resolution of the last batch of results
                // and the next time `fetchData()` can be called.
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    self.currentFetchOffset += self.QueryLimitPerFetch
                    self.isFetchInProgress = false
                }

                return deferMaybe(result)
            }
    }
    
    // MARK: - init
    init(tabManager: TabManager) {
        self.profile = tabManager.profile
        self.tabManager = tabManager
    }
}
