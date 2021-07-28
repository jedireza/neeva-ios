// Copyright Neeva. All rights reserved.

import Apollo
import Foundation
import Shared

public class SearchResultsController: QueryController<SearchResultsQuery, [URL]> {
    public override class func processData(_ data: SearchResultsQuery.Data) -> [URL] {
        var results = [URL]()
        for group in data.search?.resultGroup ?? [] {
            for result in group?.result ?? [] {
                if let url = result?.actionUrl, !url.isEmpty {
                    results.append(URL(string: url)!)
                }
            }
        }
        return results
    }

    @discardableResult public static func getSearchResults(
        for query: String,
        completion: @escaping (Result<[URL], Error>) -> Void
    ) -> Apollo.Cancellable {
        Self.perform(query: SearchResultsQuery(query: query), completion: completion)
    }
}
