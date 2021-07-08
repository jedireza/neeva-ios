// Copyright Neeva. All rights reserved.

import Combine
import Apollo
import Shared
import Defaults

class NeevaSuggestionModel: ObservableObject {
    @Published var topSuggestions: [Suggestion] = []
    @Published var chipQuerySuggestions: [Suggestion] = []
    @Published var rowQuerySuggestions: [Suggestion] = []
    @Published var urlSuggestions: [Suggestion] = []
    @Published var navSuggestions: [Suggestion] = []
    @Published var activeLensBang: ActiveLensBangInfo?
    @Published var error: Error?
    @Published var isIncognito: Bool // TODO: don’t duplicate this source of truth

    var shouldShowSuggestions: Bool {
        return !isIncognito && !searchQuery.isEmpty && Defaults[.showSearchSuggestions] && !searchQuery.looksLikeAURL
    }

    init(searchQueryForTesting: String = SearchQueryModel.shared.value, isIncognito: Bool = false,
         previewLensBang: ActiveLensBangInfo?, topSuggestions: [Suggestion] = [],
         chipQuerySuggestions: [Suggestion] = [], rowQuerySuggestions: [Suggestion] = []) {
        self.isIncognito = isIncognito
        self.topSuggestions = topSuggestions
        self.chipQuerySuggestions = chipQuerySuggestions
        self.rowQuerySuggestions = rowQuerySuggestions
        self.activeLensBang = previewLensBang
        self.searchQuery = searchQueryForTesting
    }

    init(isIncognito: Bool) {
        self.isIncognito = isIncognito
        subscription = SearchQueryModel.shared.$value.assign(to: \.searchQuery, on: self)
    }

    private var subscription: AnyCancellable?
    fileprivate var suggestionQuery: Apollo.Cancellable?

    private var searchQuery = SearchQueryModel.shared.value {
        didSet {
            if searchQuery != oldValue { reload() }
        }
    }

    var suggestions: [Suggestion] {
        topSuggestions + chipQuerySuggestions + rowQuerySuggestions + urlSuggestions + navSuggestions
    }

    func reload() {
        suggestionQuery?.cancel()

        guard shouldShowSuggestions else {
            topSuggestions = []
            chipQuerySuggestions = []
            rowQuerySuggestions = []
            urlSuggestions = []
            navSuggestions = []
            activeLensBang = nil
            error = nil
            return
        }

        let searchQuery = searchQuery

        suggestionQuery = SuggestionsController.getSuggestions(for: searchQuery) { result in
            self.suggestionQuery = nil
            switch result {
            case .failure(let error):
                let nsError = error as NSError
                if nsError.domain != NSURLErrorDomain || nsError.code != NSURLErrorCancelled {
                    self.error = error
                }
            case .success(let (topSuggestions, chipQuerySuggestions,
                               rowQuerySuggestions, urlSuggestions, navSuggestions, lensOrBang)):
                self.error = nil
                self.topSuggestions = topSuggestions
                self.chipQuerySuggestions = chipQuerySuggestions
                self.rowQuerySuggestions = rowQuerySuggestions
                self.urlSuggestions = urlSuggestions
                self.navSuggestions = navSuggestions
                self.activeLensBang = lensOrBang
            }
            if self.suggestions.isEmpty {
                if let lensOrBang = self.activeLensBang,
                   let shortcut = lensOrBang.shortcut,
                   let description = lensOrBang.description,
                   let type = lensOrBang.type,
                   type == .lens || type == .bang,
                   searchQuery.trimmingCharacters(in: .whitespaces) == type.sigil + shortcut {
                    switch lensOrBang.type {
                    case .lens:
                        self.rowQuerySuggestions = [.lens(Suggestion.Lens(shortcut: shortcut, description: description))]
                    case .bang:
                        self.rowQuerySuggestions = [.bang(Suggestion.Bang(shortcut: shortcut, description: description, domain: lensOrBang.domain))]
                    default: fatalError("This should be impossible")
                    }
                } else {
                    self.chipQuerySuggestions = [
                        .query(
                            .init(
                                type: .standard,
                                suggestedQuery: searchQuery,
                                boldSpan: [.init(startInclusive: 0, endExclusive: searchQuery.count)],
                                source: .unknown
                            )
                        )
                    ]
                }
            }
        }
    }
}
