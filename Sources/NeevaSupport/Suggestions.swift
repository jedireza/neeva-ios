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

public class SuggestionsController: ObservableObject {
    @Published public var suggestions: [Suggestion] = []
    @Published public var running = false
    @Published public var error: Error?
    @Published public var query = ""
    var subscription: AnyCancellable?

    public init() {
        subscription = $query
            .debounce(for: .milliseconds(500), scheduler: RunLoop.main)
            .sink(receiveValue: self.search(for:))
    }

    func search(for query: String) {
        error = nil
        running = true
        suggestions.removeAll()
        Self.getSuggestions(for: query) { results in
            switch results {
            case .failure(let error):
                self.error = error
            case .success(let suggestions):
                self.suggestions = suggestions
            }
        }
    }

    public static func getSuggestions(for query: String, completion: @escaping (Result<[Suggestion], Error>) -> ()) {
        GraphQLAPI.fetch(query: SuggestionsQuery(query: query)) { result in
            switch result {
            case .success(let result):
                let querySuggestions = result.data?.suggest?.querySuggestion ?? []
                let urlSuggestions = result.data?.suggest?.urlSuggestion ?? []
                completion(.success(querySuggestions.map(Suggestion.query) + urlSuggestions.map(Suggestion.url)))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
