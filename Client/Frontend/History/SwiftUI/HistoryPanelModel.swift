// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Foundation
import Shared
import Storage

class HistoryPanelModel: ObservableObject {
    private let profile: Profile
    private let tabManager: TabManager

    private let queryFetchLimit = 100
    private var currentFetchOffset = 0
    private var isFetchInProgress = false

    @Published var groupedSites = DateGroupedTableData<Site>()

    // MARK: - Data
    func reloadData() {
        guard !isFetchInProgress, !profile.isShutdown else { return }

        groupedSites = DateGroupedTableData<Site>()
        currentFetchOffset = 0

        loadSiteData().uponQueue(.main) { result in
            self.addSiteDataToGroupedSites(result)
        }
    }

    func loadSiteData() -> Deferred<Maybe<Cursor<Site?>>> {
        guard !isFetchInProgress else {
            return deferMaybe(FetchInProgressError())
        }

        isFetchInProgress = true

        return profile.history.getSitesByLastVisit(
            limit: queryFetchLimit, offset: currentFetchOffset) >>== { result in
                // Force 100ms delay between resolution of the last batch of results
                // and the next time `fetchData()` can be called.
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    self.currentFetchOffset += self.queryFetchLimit
                    self.isFetchInProgress = false
                }

                return deferMaybe(result)
            }
    }
    
    func addSiteDataToGroupedSites(_ result: Maybe<Cursor<Site?>>) {
        if let sites = result.successValue {
            for site in sites {
                guard let site = site as? Site, let latestVisit = site.latestVisit else {
                    return
                }

                self.groupedSites.add(
                    site, timestamp: TimeInterval.fromMicrosecondTimestamp(latestVisit.date))
            }
        }
    }
    
    func loadNextItemsIfNeeded(from index: Int) {
        guard index >= currentFetchOffset - 1 else {
            print("unnessecary to load more sites", index, currentFetchOffset)
            return
        }
        
        print("load more sites")
        
        loadSiteData().uponQueue(.main) { result in
            self.addSiteDataToGroupedSites(result)
        }
    }

    // MARK: - init
    init(tabManager: TabManager) {
        self.profile = tabManager.profile
        self.tabManager = tabManager
    }
}
