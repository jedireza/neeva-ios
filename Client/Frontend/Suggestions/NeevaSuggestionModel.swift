// Copyright Neeva. All rights reserved.

import Combine
import Apollo
import Shared
import Defaults

class NeevaSuggestionModel: ObservableObject {
    @Published var suggestions: [Suggestion] = []
    @Published var rowSuggestions: [Suggestion] = []
    @Published var activeLensBang: ActiveLensBangInfo?
    @Published var error: Error?
    @Published var isIncognito: Bool // TODO: don’t duplicate this source of truth

    var shouldShowSuggestions: Bool {
        return !isIncognito && !searchQuery.isEmpty && Defaults[.showSearchSuggestions] && !searchQuery.looksLikeAURL
    }

    init(searchQueryForTesting: String = SearchQueryModel.shared.value, isIncognito: Bool = false,
         previewLensBang: ActiveLensBangInfo?, suggestions: [Suggestion]) {
        self.isIncognito = isIncognito
        self.suggestions = suggestions
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

    func reload() {
        suggestionQuery?.cancel()

        guard shouldShowSuggestions else {
            suggestions = []
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
            case .success(let (suggestions, navSuggestions, lensOrBang)):
                self.error = nil
                self.suggestions = suggestions
                self.rowSuggestions = navSuggestions
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
                        self.suggestions = [.lens(Suggestion.Lens(shortcut: shortcut, description: description))]
                    case .bang:
                        self.suggestions = [.bang(Suggestion.Bang(shortcut: shortcut, description: description, domain: lensOrBang.domain))]
                    default: fatalError("This should be impossible")
                    }
                } else {
                    self.suggestions = [
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
