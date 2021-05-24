//  Copyright © 2021 Neeva. All rights reserved.
//

import Foundation
import Shared
import Storage

class SuggestedSearchesModel: ObservableObject {
    @Published var suggestedQueries = [(String?, Site)]()

    var searchUrlForQuery: String {
        return neevaSearchEngine.searchURLForQuery("blank")!.normalizedHostAndPath!
    }

    func reload(from profile: Profile) {
        guard let deferredHistory = profile.history.getFrecentHistory().getSites(matchingSearchQuery: searchUrlForQuery, limit: 20) as? CancellableDeferred else {
            assertionFailure("FrecentHistory query should be cancellable")
            return
        }

        deferredHistory.uponQueue(.main) { result in
            guard !deferredHistory.cancelled else {
                return
            }

            let deferredHistorySites = result.successValue?.asArray() ?? []
            self.suggestedQueries = deferredHistorySites.map
                {(neevaSearchEngine.queryForSearchURL(URL(string:$0.url)), $0)}
        }


    }
}
