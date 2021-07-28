// Copyright Neeva. All rights reserved.

import Apollo
import SFSafeSymbols
import Shared

/// A type that wraps both query and URL suggestions
public enum Suggestion {
    case query(SuggestionsQuery.Data.Suggest.QuerySuggestion)
    case url(SuggestionsQuery.Data.Suggest.UrlSuggestion)
    case bang(Bang)
    case lens(Lens)
    case navigation(NavSuggestion)

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

extension Suggestion: Identifiable, Equatable {
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
        case .navigation(let nav):
            return "nav-\(nav.url)"
        }
    }

    public static func == (lhs: Suggestion, rhs: Suggestion) -> Bool {
        return lhs.id == rhs.id
    }
}

public typealias ActiveLensBangInfo = SuggestionsQuery.Data.Suggest.ActiveLensBangInfo
public typealias SuggestionsQueryResult = (
    [Suggestion], [Suggestion], [Suggestion], [Suggestion], [Suggestion], ActiveLensBangInfo?
)
extension ActiveLensBangInfo: Equatable {
    static let previewBang = ActiveLensBangInfo(
        domain: "google.com", shortcut: "g", description: "Google", type: .bang)
    static let previewLens = ActiveLensBangInfo(
        shortcut: "my", description: "Search my connections", type: .lens)

    public static func == (lhs: ActiveLensBangInfo, rhs: ActiveLensBangInfo) -> Bool {
        lhs.description == rhs.description && lhs.domain == rhs.domain
            && lhs.shortcut == rhs.shortcut && lhs.type == rhs.type
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

extension SuggestionsQuery.Data.Suggest.QuerySuggestion {
    public func suggestedCalculatorQuery() -> String? {
        if AnnotationType(annotation: self.annotation) == .calculator {
            return self.suggestedQuery + " ="
        } else {
            return nil
        }
    }
}

/// Fetches query and URL suggestions for a given query
public class SuggestionsController: QueryController<SuggestionsQuery, SuggestionsQueryResult> {
    public override class func processData(_ data: SuggestionsQuery.Data) -> SuggestionsQueryResult
    {
        let querySuggestions = data.suggest?.querySuggestion ?? []
        // Split queries into standard queries that doesnt have annotations and everything else.
        let chipQuerySuggestions =
            querySuggestions.filter { $0.type == .standard && $0.annotation?.description == nil }
        var rowQuerySuggestions =
            querySuggestions.filter { $0.type != .standard || $0.annotation?.description != nil }
        var urlSuggestions = data.suggest?.urlSuggestion ?? []
        // Move all nav suggestions out of url suggestions.
        var navSuggestions = urlSuggestions.filter { !($0.subtitle?.isEmpty ?? true) }
        urlSuggestions.removeAll(where: { !($0.subtitle?.isEmpty ?? true) })
        // Top suggestion is either the first memorized suggestion or the first query shown in rows.
        let topSuggestions =
            navSuggestions.isEmpty
            ? (rowQuerySuggestions.isEmpty
                ? [] : [rowQuerySuggestions.removeFirst()].map(Suggestion.query))
            : [navSuggestions.removeFirst()].map(Suggestion.url)
        let bangSuggestions = data.suggest?.bangSuggestion ?? []
        let lensSuggestions = data.suggest?.lenseSuggestion ?? []
        return (
            topSuggestions, chipQuerySuggestions.map(Suggestion.query),
            rowQuerySuggestions.map(Suggestion.query)
                + bangSuggestions.compactMap(Suggestion.init(bang:))
                + lensSuggestions.compactMap(Suggestion.init(lens:)),
            urlSuggestions.map(Suggestion.url),
            navSuggestions.map(Suggestion.url),
            data.suggest?.activeLensBangInfo
        )
    }

    @discardableResult public static func getSuggestions(
        for query: String,
        completion: @escaping (Result<SuggestionsQueryResult, Error>) -> Void
    ) -> Apollo.Cancellable {
        Self.perform(query: SuggestionsQuery(query: query), completion: completion)
    }
}
