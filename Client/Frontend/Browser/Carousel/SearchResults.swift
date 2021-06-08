//  Copyright © 2021 Neeva. All rights reserved.
//

import Foundation
import Apollo
import Shared

public class SearchResultsController: QueryController<SearchResultsQuery, [URL]> {
    public override class func processData(_ data: SearchResultsQuery.Data) -> [URL] {
        var results = [URL]()
        for group in data.search?.resultGroup ?? [] {
            for result in group?.result ?? [] {
                if let url = result?.actionUrl, !url.isEmpty {
                    results.append(URL(string:url)!)
                }
            }
        }
        return results
    }

    @discardableResult public static func getSearchResults(
        for query: String,
        completion: @escaping (Result<[URL], Error>) -> ()
    ) -> Apollo.Cancellable {
        Self.perform(query: SearchResultsQuery(query: query), completion: completion)
    }
}
