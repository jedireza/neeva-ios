// Copyright Neeva. All rights reserved.

import Combine
import Apollo
import Shared
import Defaults

class NeevaSuggestionModel: ObservableObject {
    @Published var suggestions: [Suggestion] = []
    @Published var activeLensBang: ActiveLensBangInfo?
    @Published var error: Error?
    @Published var isIncognito: Bool // TODO: don’t duplicate this source of truth

    var shouldShowSuggestions: Bool {
        if let searchQuery = searchQuery {
            return !isIncognito && !searchQuery.isEmpty && Defaults[.showSearchSuggestions] && !searchQuery.looksLikeAURL()
        }
        return false
    }

    init(previewLensBang: ActiveLensBangInfo?, suggestions: [Suggestion]) {
        self.isIncognito = false
        self.suggestions = suggestions
        self.activeLensBang = previewLensBang
    }

    init(isIncognito: Bool) {
        self.isIncognito = isIncognito
        subscription = SearchQueryModel.shared.$value.assign(to: \.searchQuery, on: self)
    }

    private var subscription: AnyCancellable?
    fileprivate var suggestionQuery: Apollo.Cancellable?

    private var searchQuery: String? {
        didSet {
            if searchQuery != oldValue { reload() }
        }
    }

    func reload() {
        suggestionQuery?.cancel()

        guard let searchQuery = searchQuery,
              shouldShowSuggestions
        else {
            suggestions = []
            activeLensBang = nil
            error = nil
            return
        }

        suggestionQuery = SuggestionsController.getSuggestions(for: searchQuery) { result in
            self.suggestionQuery = nil
            switch result {
            case .failure(let error):
                let nsError = error as NSError
                if nsError.domain != NSURLErrorDomain || nsError.code != NSURLErrorCancelled {
                    self.error = error
                }
            case .success(let (suggestions, lensOrBang)):
                self.error = nil
                self.suggestions = suggestions
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

fileprivate extension String {
    func looksLikeAURL() -> Bool {
        // The assumption here is that if the user is typing in a forward slash and there are no spaces
        // involved, it's going to be a URL. If we type a space, any url would be invalid.
        // See https://bugzilla.mozilla.org/show_bug.cgi?id=1192155 for additional details.
        return self.contains("/") && !self.contains(" ")
    }
}
