// Copyright Neeva. All rights reserved.

import Defaults
import Shared
import Storage

class SuggestedSitesViewModel: ObservableObject {
    @Published var sites: [Site]

    init(sites: [Site]) {
        self.sites = sites
    }

    #if DEBUG
        static let preview = SuggestedSitesViewModel(
            sites: [
                .init(url: "https://amazon.com", title: "Amazon", id: 1),
                .init(url: "https://youtube.com", title: "YouTube", id: 2),
                .init(url: "https://twitter.com", title: "Twitter", id: 3),
                .init(url: "https://facebook.com", title: "Facebook", id: 4),
                .init(url: "https://facebook.com", title: "Facebook", id: 5),
                .init(url: "https://twitter.com", title: "Twitter", id: 6),
            ]
        )
    #endif
}

class SuggestedSearchesModel: ObservableObject {
    @Published var suggestedQueries = [(query: String, site: Site)]()

    init(suggestedQueries: [(String, Site)]) {
        self.suggestedQueries = suggestedQueries
    }

    var searchUrlForQuery: String {
        return neevaSearchEngine.searchURLForQuery("blank")!.normalizedHostAndPath!
    }

    func reload(from profile: Profile, completion: (() -> Void)? = nil) {
        guard
            let deferredHistory = profile.history.getFrecentHistory().getSites(
                matchingSearchQuery: searchUrlForQuery, limit: 100) as? CancellableDeferred
        else {
            assertionFailure("FrecentHistory query should be cancellable")
            return
        }

        deferredHistory.uponQueue(.main) { result in
            guard !deferredHistory.cancelled else {
                return
            }

            var deferredHistorySites = result.successValue?.asArray().compactMap { $0 } ?? []
            let topFrecentHistorySite = deferredHistorySites[deferredHistorySites.indices]
                .popFirst()
            // TODO: https://github.com/neevaco/neeva-ios-phoenix/issues/1027
            deferredHistorySites.sort { siteA, siteB in
                return siteA.latestVisit?.date ?? 0 > siteB.latestVisit?.date ?? 0
            }

            var queries = Set<String>()
            var topFrecentHistoryQuery: String? = nil
            if let topFrecentHistorySite = topFrecentHistorySite,
                let query = neevaSearchEngine.queryForSearchURL(topFrecentHistorySite.url)
            {
                topFrecentHistoryQuery = query
                queries.insert(query)
            }
            self.suggestedQueries = deferredHistorySites.compactMap { site in
                if let query = neevaSearchEngine.queryForSearchURL(site.url),
                    !queries.contains(query)
                {
                    queries.insert(query)
                    return (query, site)
                } else {
                    return nil
                }
            }
            if let topFrecentHistorySite = topFrecentHistorySite,
                let topFrecentHistoryQuery = topFrecentHistoryQuery
            {
                self.suggestedQueries.insert((topFrecentHistoryQuery, topFrecentHistorySite), at: 0)
            }

            completion?()
        }
    }
}
