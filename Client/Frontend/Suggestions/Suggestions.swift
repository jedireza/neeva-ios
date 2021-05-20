// Copyright Neeva. All rights reserved.

import Apollo
import Shared

/// A type that wraps both query and URL suggestions
public enum Suggestion {
    case query(SuggestionsQuery.Data.Suggest.QuerySuggestion)
    case url(SuggestionsQuery.Data.Suggest.UrlSuggestion)
}

extension Suggestion: Identifiable {
    public var id: String {
        switch self {
        case .query(let query):
            return query.suggestedQuery
        case .url(let url):
            return url.suggestedUrl
        }
    }
}

/// Fetches query and URL suggestions for a given query
public class SuggestionsController: QueryController<SuggestionsQuery, [Suggestion]> {
    public override class func processData(_ data: SuggestionsQuery.Data) -> [Suggestion] {
        let querySuggestions = data.suggest?.querySuggestion ?? []
        let urlSuggestions = data.suggest?.urlSuggestion ?? []
        return querySuggestions.map(Suggestion.query) + urlSuggestions.map(Suggestion.url)
    }

    @discardableResult public static func getSuggestions(
        for query: String,
        completion: @escaping (Result<[Suggestion], Error>) -> ()
    ) -> Apollo.Cancellable {
        Self.perform(query: SuggestionsQuery(query: query), completion: completion)
    }
}
