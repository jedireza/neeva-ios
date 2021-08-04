// Copyright Neeva. All rights reserved.

import Apollo
import Combine
import Defaults
import Shared
import Storage
import UIKit

struct SuggestionPositionInfo {
    let positionIndex: Int
    let isChipSuggestion: Bool
    let chipSuggestionIndex: Int?

    init(
        positionIndex: Int,
        isChipSuggestion: Bool = false,
        chipSuggestionIndex: Int? = nil
    ) {
        self.positionIndex = positionIndex
        self.isChipSuggestion = isChipSuggestion
        self.chipSuggestionIndex = chipSuggestionIndex
    }

    public func loggingAttributes() -> [ClientLogCounterAttribute] {
        var clientLogAttributes = [ClientLogCounterAttribute]()

        clientLogAttributes.append(
            ClientLogCounterAttribute(
                key: LogConfig.Attribute.suggestionPosition, value: String(positionIndex)))
        if let chipSuggestionIndex = chipSuggestionIndex {
            clientLogAttributes.append(
                ClientLogCounterAttribute(
                    key: LogConfig.Attribute.chipSuggestionPosition,
                    value: String(chipSuggestionIndex)))
        }
        let bvc = BrowserViewController.foregroundBVC()
        clientLogAttributes.append(
            ClientLogCounterAttribute(
                key: LogConfig.Attribute.urlBarNumOfCharsTyped,
                value: String(bvc.urlBar.shared.queryModel.value.count)))
        return clientLogAttributes
    }
}

class NeevaSuggestionModel: ObservableObject {
    @Published var topSuggestions: [Suggestion] = []
    @Published var chipQuerySuggestions: [Suggestion] = []
    @Published var rowQuerySuggestions: [Suggestion] = []
    @Published var urlSuggestions: [Suggestion] = []
    @Published var navSuggestions: [Suggestion] = []
    @Published var activeLensBang: ActiveLensBangInfo?
    @Published var error: Error?
    @Published var keyboardFocusedSuggestion: Suggestion?
    @Published private var isIncognito: Bool  // TODO: don’t duplicate this source of truth
    func setIncognito(_ isIncognito: Bool) {
        self.isIncognito = isIncognito
    }

    private var chipQueryFirstIndex: Int? {
        let chipSuggestionsCount = chipQuerySuggestions.count
        if chipSuggestionsCount > 0 {
            return topSuggestions.count
        }
        return nil
    }
    private var chipQueryLastIndex: Int? {
        let chipSuggestionsCount = chipQuerySuggestions.count
        if chipSuggestionsCount > 0 {
            return topSuggestions.count + chipQuerySuggestions.count - 1
        }
        return nil

    }
    private var keyboardFocusedSuggestionIndex = -1

    var shouldShowSuggestions: Bool {
        return !isIncognito && !searchQuery.isEmpty && Defaults[.showSearchSuggestions]
            && !searchQuery.looksLikeAURL
    }

    init(
        searchQueryForTesting: String = "", isIncognito: Bool = false,
        previewLensBang: ActiveLensBangInfo?, topSuggestions: [Suggestion] = [],
        chipQuerySuggestions: [Suggestion] = [], rowQuerySuggestions: [Suggestion] = []
    ) {
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
        let bvc = BrowserViewController.foregroundBVC()
        let navSuggestionModel = bvc.searchController?.navModel
        return topSuggestions + chipQuerySuggestions + rowQuerySuggestions + urlSuggestions
            + (navSuggestionModel?.combinedSuggestions ?? [])
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
            case .success(
                let (
                    topSuggestions, chipQuerySuggestions,
                    rowQuerySuggestions, urlSuggestions, navSuggestions, lensOrBang
                )):
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
                    searchQuery.trimmingCharacters(in: .whitespaces) == type.sigil + shortcut
                {
                    switch lensOrBang.type {
                    case .lens:
                        self.rowQuerySuggestions = [
                            .lens(Suggestion.Lens(shortcut: shortcut, description: description))
                        ]
                    case .bang:
                        self.rowQuerySuggestions = [
                            .bang(
                                Suggestion.Bang(
                                    shortcut: shortcut, description: description,
                                    domain: lensOrBang.domain))
                        ]
                    default: fatalError("This should be impossible")
                    }
                } else {
                    self.chipQuerySuggestions = [
                        .query(
                            .init(
                                type: .standard,
                                suggestedQuery: searchQuery,
                                boldSpan: [
                                    .init(startInclusive: 0, endExclusive: searchQuery.count)
                                ],
                                source: .unknown
                            )
                        )
                    ]
                }
            }
        }
    }

    // MARK: - Suggestion Location
    // TODO: https://github.com/neevaco/neeva-ios-phoenix/issues/1165
    private func findSuggestionLocationInfo(_ suggestion: Suggestion) -> SuggestionPositionInfo? {
        if let idx = suggestions.firstIndex(of: suggestion) {
            if let chipQueryFirstIndex = chipQueryFirstIndex {
                if let chipQueryLastIndex = chipQueryLastIndex,
                    idx >= chipQueryFirstIndex && idx <= chipQueryLastIndex
                {
                    return SuggestionPositionInfo(
                        positionIndex: chipQueryFirstIndex,
                        isChipSuggestion: true,
                        chipSuggestionIndex: idx - chipQueryFirstIndex)
                } else if idx > chipQueryFirstIndex {
                    return SuggestionPositionInfo(
                        positionIndex: idx - chipQuerySuggestions.count + 1)
                }
            }
            return SuggestionPositionInfo(positionIndex: idx)
        }
        return nil
    }

    // MARK: - Searching
    public func handleSuggestionSelected(_ suggestion: Suggestion) {
        let bvc = BrowserViewController.foregroundBVC()
        guard let tab = bvc.tabManager.selectedTab, let searchController = bvc.searchController
        else { return }

        let suggestionLocationInfo = findSuggestionLocationInfo(suggestion)

        switch suggestion {
        case .query(let suggestion):
            let interaction: LogConfig.Interaction =
                activeLensBang != nil
                ? .BangSuggestion : .QuerySuggestion
            ClientLogger.shared.logCounter(
                interaction,
                attributes: EnvironmentHelper.shared.getAttributes()
                    + (suggestionLocationInfo?.loggingAttributes() ?? []))

            bvc.urlBar(didSubmitText: suggestion.suggestedQuery)
        case .url(let suggestion):
            let interaction: LogConfig.Interaction =
                suggestion.title?.isEmpty ?? false ? .NavSuggestion : .URLSuggestion
            ClientLogger.shared.logCounter(
                interaction,
                attributes: EnvironmentHelper.shared.getAttributes()
                    + (suggestionLocationInfo?.loggingAttributes() ?? []))

            bvc.finishEditingAndSubmit(
                URL(string: suggestion.suggestedUrl)!, visitType: VisitType.typed, forTab: tab)
        case .lens(let suggestion):
            searchController.searchDelegate?.searchViewController(
                searchController, didAcceptSuggestion: suggestion.shortcut)
        case .bang(let suggestion):
            searchController.searchDelegate?.searchViewController(
                searchController, didAcceptSuggestion: suggestion.shortcut)
        case .navigation(let nav):
            ClientLogger.shared.logCounter(
                LogConfig.Interaction.HistorySuggestion,
                attributes: EnvironmentHelper.shared.getAttributes()
                    + (suggestionLocationInfo?.loggingAttributes() ?? []))
            bvc.finishEditingAndSubmit(nav.url, visitType: VisitType.typed, forTab: tab)
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
                // searches for suggestion
                handleSuggestionSelected(keyboardFocusedSuggestion)
            } else {
                // searches for text in address bar
                let bvc = BrowserViewController.foregroundBVC()
                bvc.urlBar(
                    didSubmitText: bvc.urlBar.shared.queryModel.value
                        + (bvc.urlBar.shared.historySuggestionModel.completion ?? ""))
            }
        default:
            break
        }
    }

    /// Moves the focusedKeyboardShortcut up/down by the input amount
    private func moveFocus(amount: Int) {
        let allSuggestions = suggestions
        let allSuggestionsCount = allSuggestions.count

        guard allSuggestionsCount > 0 else {
            return
        }

        keyboardFocusedSuggestionIndex += amount

        if keyboardFocusedSuggestionIndex >= allSuggestionsCount {
            keyboardFocusedSuggestionIndex = -1
            keyboardFocusedSuggestion = nil
        } else if keyboardFocusedSuggestionIndex < -1 {
            keyboardFocusedSuggestionIndex = allSuggestions.count - 1
            keyboardFocusedSuggestion = allSuggestions[allSuggestions.count - 1]
        } else if keyboardFocusedSuggestionIndex > -1 {
            keyboardFocusedSuggestion = allSuggestions[keyboardFocusedSuggestionIndex]
        } else {
            keyboardFocusedSuggestion = nil
        }
    }

    public func isFocused(_ suggestion: Suggestion) -> Bool {
        return suggestion == keyboardFocusedSuggestion
    }
}
