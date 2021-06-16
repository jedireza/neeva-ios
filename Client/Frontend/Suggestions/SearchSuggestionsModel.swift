// Copyright Neeva. All rights reserved.

import Apollo
import Shared
import SFSafeSymbols

/// A type that wraps both query and URL suggestions
public enum Suggestion {
    case query(SuggestionsQuery.Data.Suggest.QuerySuggestion)
    case url(SuggestionsQuery.Data.Suggest.UrlSuggestion)
    case bang(Bang)
    case lens(Lens)

    public struct Bang {
        public let shortcut: String
        public let description: String
        public let domain: String?
    }

    public struct Lens {
        public let shortcut: String
        public let description: String
    }

    public init?(bang: SuggestionsQuery.Data.Suggest.BangSuggestion) {
        if let shortcut = bang.shortcut, let description = bang.description {
            self = .bang(Bang(shortcut: shortcut, description: description, domain: bang.domain))
        } else {
            return nil
        }
    }

    public init?(lens: SuggestionsQuery.Data.Suggest.LenseSuggestion) {
        if let shortcut = lens.shortcut, let description = lens.description {
            self = .lens(Lens(shortcut: shortcut, description: description))
        } else {
            return nil
        }
    }
}

extension Suggestion: Identifiable {
    public var id: String {
        switch self {
        case .query(let query):
            return "query-\(query.suggestedQuery)"
        case .url(let url):
            return "url-\(url.suggestedUrl)"
        case .bang(let bang):
            return "bang-\(bang.shortcut)"
        case .lens(let lens):
            return "lens-\(lens.shortcut)"
        }
    }
}

public typealias ActiveLensBangInfo = SuggestionsQuery.Data.Suggest.ActiveLensBangInfo
public typealias SuggestionsQueryResult = ([Suggestion], ActiveLensBangInfo?)
extension ActiveLensBangInfo: Equatable {
    public static func == (lhs: ActiveLensBangInfo, rhs: ActiveLensBangInfo) -> Bool {
        lhs.description == rhs.description && lhs.domain == rhs.domain && lhs.shortcut == rhs.shortcut && lhs.type == rhs.type
    }
}

extension ActiveLensBangType {
    var sigil: String {
        switch self {
        case .bang: return "!"
        case .lens: return "@"
        case .unknown, .__unknown(_): return ""
        }
    }
    // TODO: use Nicon? / customize to favicon
    var defaultSymbol: SFSymbol {
        switch self {
        case .bang: return .exclamationmarkCircle
        case .lens: return .at
        case .unknown, .__unknown(_): return .questionmarkDiamondFill
        }
    }
}

/// Fetches query and URL suggestions for a given query
public class SuggestionsController: QueryController<SuggestionsQuery, SuggestionsQueryResult> {
    public override class func processData(_ data: SuggestionsQuery.Data) -> SuggestionsQueryResult {
        let querySuggestions = data.suggest?.querySuggestion ?? []
        var urlSuggestions = data.suggest?.urlSuggestion ?? []
        var navSuggestions: [SuggestionsQuery.Data.Suggest.UrlSuggestion] = []
        // TODO: Rely on score to rank and use partition when we have multiple nav suggestions
        if let index = urlSuggestions.firstIndex(where: { !($0.subtitle?.isEmpty ?? true)}) {
            navSuggestions.append(urlSuggestions.remove(at: index))
        }
        let bangSuggestions = data.suggest?.bangSuggestion ?? []
        let lensSuggestions = data.suggest?.lenseSuggestion ?? []
        return (
            navSuggestions.map(Suggestion.url) + querySuggestions.map(Suggestion.query) + urlSuggestions.map(Suggestion.url)
                + bangSuggestions.compactMap(Suggestion.init(bang:)) + lensSuggestions.compactMap(Suggestion.init(lens:)),
            data.suggest?.activeLensBangInfo
        )
    }

    @discardableResult public static func getSuggestions(
        for query: String,
        completion: @escaping (Result<SuggestionsQueryResult, Error>) -> ()
    ) -> Apollo.Cancellable {
        Self.perform(query: SuggestionsQuery(query: query), completion: completion)
    }
}
