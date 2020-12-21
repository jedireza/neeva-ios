import Apollo
import SwiftUI
import Combine

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

public class SuggestionsController: QueryController<SuggestionsQuery, [Suggestion]> {
    @Published public var query = ""

    var subscription: AnyCancellable?

    public override init() {
        super.init()
        subscription = $query
            .debounce(for: .milliseconds(500), scheduler: RunLoop.main)
            .sink(receiveValue: { self.perform(query: SuggestionsQuery(query: $0)) })
    }

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
