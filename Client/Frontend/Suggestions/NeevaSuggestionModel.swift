// Copyright Neeva. All rights reserved.

import Combine
import Apollo
import Shared
import Defaults
import UIKit
import Storage

class NeevaSuggestionModel: ObservableObject {
    @Published var topSuggestions: [Suggestion] = []
    @Published var chipQuerySuggestions: [Suggestion] = []
    @Published var rowQuerySuggestions: [Suggestion] = []
    @Published var urlSuggestions: [Suggestion] = []
    @Published var navSuggestions: [Suggestion] = []
    @Published var activeLensBang: ActiveLensBangInfo?
    @Published var error: Error?
    @Published var isIncognito: Bool // TODO: don’t duplicate this source of truth
    @Published var keyboardFocusedSuggestion: Suggestion?
    private var keyboardFocusedSuggestionIndex = -1

    var shouldShowSuggestions: Bool {
        return !isIncognito && !searchQuery.isEmpty && Defaults[.showSearchSuggestions] && !searchQuery.looksLikeAURL
    }

    init(searchQueryForTesting: String = "", isIncognito: Bool = false,
         previewLensBang: ActiveLensBangInfo?, topSuggestions: [Suggestion] = [],
         chipQuerySuggestions: [Suggestion] = [], rowQuerySuggestions: [Suggestion] = []) {
        self.isIncognito = isIncognito
        self.topSuggestions = topSuggestions
        self.chipQuerySuggestions = chipQuerySuggestions
        self.rowQuerySuggestions = rowQuerySuggestions
        self.activeLensBang = previewLensBang
        self.searchQuery = searchQueryForTesting
    }

    init(isIncognito: Bool, queryModel: SearchQueryModel) {
        self.isIncognito = isIncognito
        self.searchQuery = queryModel.value
        self.subscription = queryModel.$value.assign(to: \.searchQuery, on: self)
    }

    private var subscription: AnyCancellable?
    fileprivate var suggestionQuery: Apollo.Cancellable?

    private var searchQuery: String {
        didSet {
            if searchQuery != oldValue { reload() }
        }
    }

    var suggestions: [Suggestion] {
        topSuggestions + chipQuerySuggestions + rowQuerySuggestions + urlSuggestions + navSuggestions
    }

    func reload() {
        suggestionQuery?.cancel()

        keyboardFocusedSuggestion = nil
        keyboardFocusedSuggestionIndex = -1

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

    // MARK: - Searching
    public func handleSuggestionSelected(_ suggestion: Suggestion) {
        let bvc = BrowserViewController.foregroundBVC()
        guard let tab = bvc.tabManager.selectedTab, let searchController = bvc.searchController else { return }

        switch suggestion {
        case .query(let suggestion):
            let interaction: LogConfig.Interaction = activeLensBang != nil
                ? .BangSuggestion : .QuerySuggestion
            ClientLogger.shared.logCounter(interaction)

            bvc.urlBar(didSubmitText: suggestion.suggestedQuery)
        case .url(let suggestion):
            let interaction: LogConfig.Interaction = suggestion.title?.isEmpty ?? false ?
                .NavSuggestion : .URLSuggestion
            ClientLogger.shared.logCounter(interaction)

            bvc.finishEditingAndSubmit(URL(string: suggestion.suggestedUrl)!, visitType: VisitType.typed, forTab: tab)
        case .lens(let suggestion):
            searchController.searchDelegate?.searchViewController(searchController, didAcceptSuggestion: suggestion.shortcut)
        case .bang(let suggestion):
            searchController.searchDelegate?.searchViewController(searchController, didAcceptSuggestion: suggestion.shortcut)
        }
    }

    // MARK: - Keyboard Shortcut
    public func handleKeyboardShortcut(input: String) {
        switch input {
        case UIKeyCommand.inputUpArrow:
            moveFocus(amount: -1)
        case UIKeyCommand.inputDownArrow:
            moveFocus(amount: 1)
        case "\r":
            if let keyboardFocusedSuggestion = keyboardFocusedSuggestion {
                handleSuggestionSelected(keyboardFocusedSuggestion)
            }
        default:
            break
        }
    }

    /// Moves the focusedKeyboardShortcut up/down by the input amount
    private func moveFocus(amount: Int) {
        let allSuggestions = topSuggestions + chipQuerySuggestions + rowQuerySuggestions + urlSuggestions + navSuggestions
        let allSuggestionsCount = allSuggestions.count

        guard allSuggestionsCount > 0 else {
            return
        }

        keyboardFocusedSuggestionIndex += amount

        if keyboardFocusedSuggestionIndex >= allSuggestionsCount {
            keyboardFocusedSuggestionIndex = 0
            keyboardFocusedSuggestion = allSuggestions[0]
        } else if keyboardFocusedSuggestionIndex < 0 {
            keyboardFocusedSuggestionIndex = allSuggestions.count - 1
            keyboardFocusedSuggestion = allSuggestions[allSuggestions.count - 1]
        } else {
            keyboardFocusedSuggestion = allSuggestions[keyboardFocusedSuggestionIndex]
        }
    }

    public func isFocused(_ suggestion: Suggestion) -> Bool {
        return suggestion == keyboardFocusedSuggestion
    }
}
