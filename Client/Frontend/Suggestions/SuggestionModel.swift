// Copyright Neeva. All rights reserved.

import Apollo
import Combine
import Defaults
import Shared
import Storage

private let log = Logger.browser
private let URLBeforePathRegex = try! NSRegularExpression(
    pattern: "^https?://([^/]+)/", options: [])
private let defaultRecencyDuration: UInt64 = 2 * OneDayInMilliseconds * 1000
private let numSuggestionsToFetch: Int = 40

class SuggestionModel: ObservableObject {
    let bvc: BrowserViewController
    var getKeyboardHeight: () -> CGFloat = { 0 }

    public var queryModel: SearchQueryModel
    private var searchQueryListener: AnyCancellable?

    private var searchQuery: String = "" {
        didSet {
            if searchQuery != oldValue { reload() }
        }
    }

    // MARK: Neeva Suggestions
    // Displayed in linear order
    @Published var tabSuggestions: [Suggestion] = []
    @Published var topSuggestions: [Suggestion] = []
    @Published var chipQuerySuggestions: [Suggestion] = []
    @Published var rowQuerySuggestions: [Suggestion] = []
    @Published var urlSuggestions: [Suggestion] = []
    @Published var navSuggestions: [Suggestion] = []
    @Published var findInPageSuggestion: Suggestion?
    @Published var activeLensBang: ActiveLensBangInfo?
    @Published var error: Error?
    @Published var keyboardFocusedSuggestion: Suggestion?
    private var keyboardFocusedSuggestionIndex = -1

    private var isIncognito: Bool {
        bvc.tabManager.isIncognito
    }

    private var chipQueryRange: ClosedRange<Int>?

    var shouldShowSuggestions: Bool {
        !isIncognito && !searchQuery.isEmpty && Defaults[.showSearchSuggestions]
            && !searchQuery.looksLikeAURL
    }

    fileprivate var suggestionQuery: Apollo.Cancellable?

    var suggestions: [Suggestion] {
        let top = tabSuggestions + topSuggestions
        if !chipQuerySuggestions.isEmpty {
            chipQueryRange = top.count...top.count + chipQuerySuggestions.count - 1
        }
        let mid = chipQuerySuggestions + rowQuerySuggestions + urlSuggestions
        return top + mid + navCombinedSuggestions
    }

    var shouldShowPlaceholderSuggestions: Bool {
        [topSuggestions, chipQuerySuggestions, rowQuerySuggestions].allSatisfy {
            $0?.isEmpty == true
        } && shouldShowSuggestions
    }

    // MARK: - History Suggestions
    @Published private(set) var completion: String?
    @Published private(set) var sites: [Site]?
    @Published private(set) var recentSites: [Site]?

    private var shouldSkipNextAutocomplete = false
    private let frecentHistory: FrecentHistory

    // `weak` usage here allows deferred queue to be the owner. The deferred is always filled and this set to nil,
    // this is defensive against any changes to queue (or cancellation) behaviour in future.
    private weak var currentDeferredHistoryQuery: CancellableDeferred<Maybe<Cursor<Site?>>>?
    private var searchTextSubscription: AnyCancellable?

    fileprivate lazy var topDomains: [String] = {
        let filePath = Bundle.main.path(forResource: "topdomains", ofType: "txt")
        return try! String(contentsOfFile: filePath!).components(separatedBy: "\n")
    }()

    // MARK: - Nav Suggestions
    static let numOfDisplayNavSuggestions = 5

    var navCombinedSuggestions: [Suggestion] {
        let recentSites = recentSites?.compactMap { NavSuggestion(site: $0) } ?? []
        let sites = sites?.compactMap { NavSuggestion(site: $0) } ?? []

        var convertedNavSuggestions = [NavSuggestion]()
        for suggestion in navSuggestions {
            switch suggestion {
            case .url(let suggestion):
                convertedNavSuggestions.append(NavSuggestion(suggestion: suggestion)!)
            default:
                break
            }
        }

        let navSuggestions = Array(
            (recentSites + convertedNavSuggestions + sites).removeDuplicates().prefix(
                SuggestionModel.numOfDisplayNavSuggestions))
        return navSuggestions.compactMap { Suggestion.navigation($0) }
    }

    // MARK: - Loading Suggestions
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
            findInPageSuggestion = nil
            activeLensBang = nil
            error = nil
            return
        }

        bvc.findInPageViewController.model.searchValue = searchQuery

        // Delay gives time to search the page.
        // The model that is passed is not updated by the @Published varible, this is a fix for that.
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) { [self] in
            findInPageSuggestion = .findInPage(bvc.findInPageViewController.model)
        }

        let searchQuery = searchQuery
        suggestionQuery = SuggestionsController.getSuggestions(for: searchQuery) { [self] result in
            self.suggestionQuery = nil
            switch result {
            case .failure(let error):
                ClientLogger.shared.logCounter(
                    .SuggestionErrorLoginViewImpression,
                    attributes: EnvironmentHelper.shared.getFirstRunAttributes())
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
                    default:
                        print("Unexpected lens/bang type \(lensOrBang.type?.rawValue ?? "(nil)")")
                        self.rowQuerySuggestions = []
                    }
                } else {
                    let emptyQuerySuggestion: Suggestion = .query(
                        .init(
                            type: .standard,
                            suggestedQuery: searchQuery,
                            boldSpan: [
                                .init(startInclusive: 0, endExclusive: searchQuery.count)
                            ],
                            source: .unknown
                        )
                    )
                    if FeatureFlag[.enableChipQuery] {
                        self.chipQuerySuggestions = [emptyQuerySuggestion]
                    } else {
                        self.rowQuerySuggestions = [emptyQuerySuggestion]
                    }
                }
            }
        }
    }

    private func subscribe() {
        searchTextSubscription = queryModel.$value.withPrevious().sink {
            [unowned self] oldQuery, query in
            currentDeferredHistoryQuery?.cancel()

            if query.isEmpty {
                sites = []
                completion = nil
                shouldSkipNextAutocomplete = false
                return
            }

            guard
                let deferredHistory = frecentHistory.getSites(
                    matchingSearchQuery: query, limit: numSuggestionsToFetch)
                    as? CancellableDeferred
            else {
                assertionFailure("FrecentHistory query should be cancellable")
                return
            }

            currentDeferredHistoryQuery = deferredHistory

            deferredHistory.uponQueue(.main) { result in
                defer {
                    self.currentDeferredHistoryQuery = nil
                }

                guard !deferredHistory.cancelled else {
                    return
                }

                // Exclude Neeva search url suggestions from history suggest, since they should
                // readily be coming as query suggestions.
                let deferredHistorySites = (result.successValue?.asArray() ?? [])
                    .compactMap { $0 }
                    .filter {
                        !($0.url.absoluteString.hasPrefix(
                            NeevaConstants.appSearchURL.absoluteString))
                    }

                // Split the data to frequent visits from recent history and everything else
                self.recentSites =
                    deferredHistorySites
                    .filter {
                        $0.latestVisit != nil
                            && $0.latestVisit!.date
                                > (Date.nowMicroseconds() - defaultRecencyDuration)
                    }
                self.sites =
                    deferredHistorySites
                    .filter {
                        $0.latestVisit == nil
                            || $0.latestVisit!.date
                                <= (Date.nowMicroseconds() - defaultRecencyDuration)
                    }

                // If we should skip the next autocomplete, reset
                // the flag and bail out here.
                guard !self.shouldSkipNextAutocomplete else {
                    self.shouldSkipNextAutocomplete = false
                    return
                }

                let query = query.stringByTrimmingLeadingCharactersInSet(.whitespaces)

                // First, see if the query matches any URLs from the user's search history.
                for site in deferredHistorySites {
                    if setCompletion(to: completionForURL(site.url, from: query), from: query) {
                        return
                    }
                }

                // If there are no search history matches, try matching one of the Alexa top domains.
                for domain in self.topDomains {
                    if setCompletion(to: completionForDomain(domain, from: query), from: query) {
                        return
                    }
                }

                if self.completion != nil {
                    self.completion = nil
                }
            }
        }
    }

    // MARK: - Autocomplete
    @discardableResult func clearCompletion() -> Bool {
        let cleared = completion != nil
        completion = nil
        return cleared
    }

    func skipNextAutocomplete() {
        shouldSkipNextAutocomplete = true
    }

    private func setCompletion(to completion: String?, from query: String) -> Bool {
        if let completion = completion, completion != query {
            precondition(
                completion.lowercased().starts(with: query.lowercased()),
                "Expected completion '\(completion)' to start with '\(query)'")
            self.completion = String(completion.dropFirst(query.count))
            return true
        }

        return false
    }

    fileprivate func completionForURL(_ url: URL, from query: String) -> String? {
        let url = url.absoluteString as NSString
        // Extract the pre-path substring from the URL. This should be more efficient than parsing via
        // NSURL since we need to only look at the beginning of the string.
        // Note that we won't match non-HTTP(S) URLs.
        guard
            let match = URLBeforePathRegex.firstMatch(
                in: url as String, options: [], range: NSRange(location: 0, length: url.length))
        else {
            return nil
        }

        // If the pre-path component (including the scheme) starts with the query, just use it as is.
        var prePathURL = url.substring(with: match.range(at: 0))
        if prePathURL.hasPrefix(query) {
            // Trailing slashes in the autocompleteTextField cause issues with Swype keyboard. Bug 1194714
            if prePathURL.hasSuffix("/"), !query.hasSuffix("/") {
                prePathURL.remove(at: prePathURL.index(before: prePathURL.endIndex))
            }
            return prePathURL
        }

        // Otherwise, find and use any matching domain.
        // To simplify the search, prepend a ".", and search the string for ".query".
        // For example, for http://en.m.wikipedia.org, domainWithDotPrefix will be ".en.m.wikipedia.org".
        // This allows us to use the "." as a separator, so we can match "en", "m", "wikipedia", and "org",
        let domain = (url as NSString).substring(with: match.range(at: 1))
        return completionForDomain(domain, from: query)
    }

    fileprivate func completionForDomain(_ domain: String, from query: String) -> String? {
        let domainWithDotPrefix: String = ".\(domain)"
        if let range = domainWithDotPrefix.range(
            of: ".\(query)", options: .caseInsensitive, range: nil, locale: nil)
        {
            let matchedDomain = String(
                domainWithDotPrefix[domainWithDotPrefix.index(range.lowerBound, offsetBy: 1)...])
            // We don't actually want to match the top-level domain ("com", "org", etc.) by itself, so
            // so make sure the result includes at least one ".".
            if matchedDomain.contains(".") {
                return matchedDomain
            }
        }

        return nil
    }

    // MARK: - Suggestion Location Logging Attributes
    private func findSuggestionLocationInfo(_ suggestion: Suggestion) -> SuggestionPositionInfo? {
        if let idx = suggestions.firstIndex(of: suggestion) {
            if let chipQueryRange = chipQueryRange {
                if chipQueryRange.contains(idx) {
                    return SuggestionPositionInfo(
                        positionIndex: chipQueryRange.lowerBound,
                        chipSuggestionIndex: idx - chipQueryRange.lowerBound)
                } else if idx > chipQueryRange.lowerBound {
                    return SuggestionPositionInfo(positionIndex: idx - chipQueryRange.count)
                }
            }
            return SuggestionPositionInfo(positionIndex: idx)
        }

        return nil
    }

    private func annotationTypeAttribute(
        suggestion: Suggestion,
        suggestionIdx: Int
    ) -> ClientLogCounterAttribute? {
        switch suggestion {
        case .query(let suggestion):
            if let annotationType = suggestion.annotation?.annotationType {
                return
                    ClientLogCounterAttribute(
                        key:
                            "\(LogConfig.SuggestionAttribute.annotationTypeAtPosition)\(suggestionIdx)",
                        value: annotationType
                    )
            }
        default:
            break
        }
        return nil
    }

    private func finishEditingAndSubmit(url: URL) {
        bvc.finishEditingAndSubmit(
            url,
            visitType: VisitType.typed,
            forTab: bvc.tabManager.selectedTab)
    }

    // MARK: - Suggestion Handling
    public func handleSuggestionSelected(_ suggestion: Suggestion) {
        let suggestionLocationAttributes =
            findSuggestionLocationInfo(suggestion)?.loggingAttributes() ?? []
        var hideZeroQuery = true
        var hideFindInPage = true

        var interaction: LogConfig.Interaction?

        switch suggestion {
        case .query(let suggestion):
            interaction =
                activeLensBang != nil
                ? .BangSuggestion : .QuerySuggestion
            bvc.urlBar(didSubmitText: suggestion.suggestedQuery)
        case .url(let suggestion):
            interaction =
                suggestion.title?.isEmpty ?? false ? .PersonalSuggestion : .MemorizedSuggestion
            finishEditingAndSubmit(url: URL(string: suggestion.suggestedUrl)!)
        case .lens(let suggestion):
            interaction = .LensSuggestion
            finishEditingAndSubmit(url: URL(string: suggestion.shortcut)!)
        case .bang(let suggestion):
            interaction = .BangSuggestion
            finishEditingAndSubmit(url: URL(string: suggestion.shortcut)!)
        case .navigation(let nav):
            interaction =
                nav.isMemorizedNav
                ? LogConfig.Interaction.MemorizedSuggestion
                : LogConfig.Interaction.HistorySuggestion
            finishEditingAndSubmit(url: nav.url)
        case .editCurrentURL(let tab):
            hideZeroQuery = false

            let tabURL = tab.url
            let url =
                InternalURL.isValid(url: tabURL)
                ? InternalURL(tabURL)?.originalURLFromErrorPage : tabURL
            bvc.searchQueryModel.value = url?.absoluteString ?? ""
            bvc.zeroQueryModel.targetTab = .currentTab
        case .tabSuggestion(let selectedTab):
            if let tab = selectedTab.manager.get(for: selectedTab.id) {
                selectedTab.manager.select(tab)
            }
        case .findInPage(let model):
            interaction = .FindOnPageSuggestion
            hideFindInPage = false

            self.bvc.updateFindInPageVisibility(visible: true, query: model.searchValue)
        case .editCurrentQuery(let query, let url):
            hideZeroQuery = false

            let components = URLComponents(url: url, resolvingAgainstBaseURL: false)
            bvc.searchQueryModel.value = query
            bvc.searchQueryModel.queryItems = components?.queryItems
            bvc.zeroQueryModel.targetTab = .currentTab
        }

        if let interaction = interaction {
            ClientLogger.shared.logCounter(
                interaction,
                attributes: EnvironmentHelper.shared.getAttributes()
                    + suggestionLocationAttributes
                    + suggestionSnapshotAttributes())
        }

        if hideZeroQuery {
            bvc.hideZeroQuery()
        }

        if hideFindInPage {
            bvc.updateFindInPageVisibility(visible: false)
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
                bvc.urlBar(
                    didSubmitText: bvc.searchQueryModel.value
                        + (bvc.suggestionModel.completion ?? ""))
            }
        default:
            break
        }
    }

    /// Moves the focusedKeyboardShortcut up/down by the input amount
    private func moveFocus(amount: Int) {
        let allSuggestionsCount = suggestions.count

        guard allSuggestionsCount > 0 else {
            return
        }

        keyboardFocusedSuggestionIndex += amount

        if keyboardFocusedSuggestionIndex >= allSuggestionsCount {
            keyboardFocusedSuggestionIndex = -1
            keyboardFocusedSuggestion = nil
        } else if keyboardFocusedSuggestionIndex < -1 {
            keyboardFocusedSuggestionIndex = allSuggestionsCount - 1
            keyboardFocusedSuggestion = suggestions[allSuggestionsCount - 1]
        } else if keyboardFocusedSuggestionIndex > -1 {
            keyboardFocusedSuggestion = suggestions[keyboardFocusedSuggestionIndex]
        } else {
            keyboardFocusedSuggestion = nil
        }
    }

    public func isFocused(_ suggestion: Suggestion) -> Bool {
        return suggestion == keyboardFocusedSuggestion
    }

    // MARK: - Initlization
    init(bvc: BrowserViewController, profile: Profile, queryModel: SearchQueryModel) {
        self.bvc = bvc
        self.frecentHistory = profile.history.getFrecentHistory()
        self.queryModel = queryModel

        searchQueryListener = queryModel.$value.sink(receiveValue: { updatedQuery in
            self.searchQuery = updatedQuery
        })

        subscribe()
        KeyboardHelper.defaultHelper.addDelegate(self)
    }

    convenience init(
        bvc: BrowserViewController, previewSites: [Site]? = nil, previewCompletion: String? = nil,
        queryModel: SearchQueryModel = SearchQueryModel(previewValue: ""),
        searchQueryForTesting: String = "",
        previewLensBang: ActiveLensBangInfo? = nil, topSuggestions: [Suggestion] = [],
        chipQuerySuggestions: [Suggestion] = [], rowQuerySuggestions: [Suggestion] = []
    ) {
        self.init(bvc: bvc, profile: BrowserProfile(localName: "profile"), queryModel: queryModel)
        self.sites = previewSites
        self.completion = previewCompletion
        self.topSuggestions = topSuggestions
        self.chipQuerySuggestions = chipQuerySuggestions
        self.rowQuerySuggestions = rowQuerySuggestions
        self.activeLensBang = previewLensBang
        self.searchQuery = searchQueryForTesting
        self.sites = previewSites
    }
}

extension SuggestionModel: KeyboardHelperDelegate {
    func keyboardHelper(
        _ keyboardHelper: KeyboardHelper, keyboardWillShowWithState state: KeyboardState
    ) {
        animateSearchEnginesWithKeyboard(state)
    }

    func keyboardHelper(
        _ keyboardHelper: KeyboardHelper, keyboardDidShowWithState state: KeyboardState
    ) {
    }

    func keyboardHelper(
        _ keyboardHelper: KeyboardHelper, keyboardWillHideWithState state: KeyboardState
    ) {
        animateSearchEnginesWithKeyboard(state)
    }

    func keyboardHelper(
        _ keyboardHelper: KeyboardHelper, keyboardDidHideWithState state: KeyboardState
    ) {
    }

    func animateSearchEnginesWithKeyboard(_ keyboardState: KeyboardState) {
        keyboardState.animateAlongside {
            self.objectWillChange.send()
        }
    }
}

// Analytics

// See https://paper.dropbox.com/doc/Suggestion-Logging--BRKRJ~Nh4Swy4qpS2YznTGHxAg-090AYbHRKr5TsjKPDG406
// for the attribute format of suggestion
extension SuggestionModel {
    enum SuggestionLoggingType: String {
        case tabSuggestion = "TabSuggestion"
        case chipSuggestion = "ChipSuggestion"
        case rowQuerySuggestion = "RowQuerySuggestion"
        case personalSuggestion = "PersonalSuggestion"
        case memorizedSuggestion = "MemorizedSuggestion"
        case historySuggestion = "HistorySuggestion"
        case bangSuggestion = "BangSuggestion"
        case lensSuggestion = "LensSuggestion"
    }

    func suggestionSnapshotAttributes() -> [ClientLogCounterAttribute] {
        var implLogAttributes = [ClientLogCounterAttribute]()
        var snapshotLogAttributes = [ClientLogCounterAttribute]()
        var suggestionIdx = 0

        var numberOfMemorizedSuggestions = 0
        var numberOfHistorySuggestions = 0
        var numberOfPersonalSuggestions = 0
        var numberOfCalculatorAnnotations = 0
        var numberOfWikiAnnotations = 0
        var numberOfStockAnnotations = 0

        suggestions.enumerated().forEach { (index, suggestion) in
            var isChipQuery = false
            switch suggestion {
            case .tabSuggestion(_):
                implLogAttributes.append(
                    ClientLogCounterAttribute(
                        key:
                            "\(LogConfig.SuggestionAttribute.suggestionTypePosition)\(suggestionIdx)",
                        value: SuggestionLoggingType.tabSuggestion.rawValue)
                )
            case .query(let query):
                switch AnnotationType(annotation: query.annotation) {
                case .calculator:
                    numberOfCalculatorAnnotations += 1
                case .wikipedia:
                    numberOfWikiAnnotations += 1
                case .stock:
                    numberOfStockAnnotations += 1
                default:
                    break
                }
                if index >= chipQueryRange?.lowerBound ?? -1
                    && index <= chipQueryRange?.upperBound ?? -1
                {
                    if index == chipQueryRange?.lowerBound {
                        implLogAttributes.append(
                            ClientLogCounterAttribute(
                                key:
                                    "\(LogConfig.SuggestionAttribute.suggestionTypePosition)\(suggestionIdx)",
                                value: SuggestionLoggingType.chipSuggestion.rawValue)
                        )
                        suggestionIdx += 1
                    }
                    isChipQuery = true
                } else {
                    implLogAttributes.append(
                        ClientLogCounterAttribute(
                            key:
                                "\(LogConfig.SuggestionAttribute.suggestionTypePosition)\(suggestionIdx)",
                            value: SuggestionLoggingType.rowQuerySuggestion.rawValue
                        )
                    )
                }
                if let attribute = annotationTypeAttribute(
                    suggestion: suggestion,
                    suggestionIdx: suggestionIdx
                ) {
                    snapshotLogAttributes.append(attribute)
                }
            case .url(let url):
                if !(url.subtitle?.isEmpty ?? true) {
                    numberOfMemorizedSuggestions += 1
                    implLogAttributes.append(
                        ClientLogCounterAttribute(
                            key:
                                "\(LogConfig.SuggestionAttribute.suggestionTypePosition)\(suggestionIdx)",
                            value: SuggestionLoggingType.memorizedSuggestion.rawValue)
                    )
                } else {
                    numberOfPersonalSuggestions += 1
                    implLogAttributes.append(
                        ClientLogCounterAttribute(
                            key:
                                "\(LogConfig.SuggestionAttribute.suggestionTypePosition)\(suggestionIdx)",
                            value: SuggestionLoggingType.personalSuggestion.rawValue)
                    )
                }
            case .navigation(let nav):
                if nav.isMemorizedNav {
                    numberOfMemorizedSuggestions += 1
                    implLogAttributes.append(
                        ClientLogCounterAttribute(
                            key:
                                "\(LogConfig.SuggestionAttribute.suggestionTypePosition)\(suggestionIdx)",
                            value: SuggestionLoggingType.memorizedSuggestion.rawValue)
                    )
                } else {
                    numberOfHistorySuggestions += 1
                    implLogAttributes.append(
                        ClientLogCounterAttribute(
                            key:
                                "\(LogConfig.SuggestionAttribute.suggestionTypePosition)\(suggestionIdx)",
                            value: SuggestionLoggingType.historySuggestion.rawValue)
                    )
                }
            case .bang(_):
                implLogAttributes.append(
                    ClientLogCounterAttribute(
                        key:
                            "\(LogConfig.SuggestionAttribute.suggestionTypePosition)\(suggestionIdx)",
                        value: SuggestionLoggingType.bangSuggestion.rawValue)
                )
            case .lens(_):
                implLogAttributes.append(
                    ClientLogCounterAttribute(
                        key:
                            "\(LogConfig.SuggestionAttribute.suggestionTypePosition)\(suggestionIdx)",
                        value: SuggestionLoggingType.lensSuggestion.rawValue)
                )
            default:
                break
            }
            if !isChipQuery {
                suggestionIdx += 1
            }
        }

        snapshotLogAttributes.append(
            ClientLogCounterAttribute(
                key: LogConfig.SuggestionAttribute.numberOfMemorizedSuggestions,
                value: String(numberOfMemorizedSuggestions))
        )
        snapshotLogAttributes.append(
            ClientLogCounterAttribute(
                key: LogConfig.SuggestionAttribute.numberOfHistorySuggestions,
                value: String(numberOfHistorySuggestions))
        )
        snapshotLogAttributes.append(
            ClientLogCounterAttribute(
                key: LogConfig.SuggestionAttribute.numberOfPersonalSuggestions,
                value: String(numberOfPersonalSuggestions))
        )
        snapshotLogAttributes.append(
            ClientLogCounterAttribute(
                key: LogConfig.SuggestionAttribute.numberOfCalculatorAnnotations,
                value: String(numberOfCalculatorAnnotations))
        )
        snapshotLogAttributes.append(
            ClientLogCounterAttribute(
                key: LogConfig.SuggestionAttribute.numberOfWikiAnnotations,
                value: String(numberOfWikiAnnotations))
        )
        snapshotLogAttributes.append(
            ClientLogCounterAttribute(
                key: LogConfig.SuggestionAttribute.numberOfStockAnnotations,
                value: String(numberOfStockAnnotations))
        )
        snapshotLogAttributes.append(
            ClientLogCounterAttribute(
                key: LogConfig.SuggestionAttribute.numberOfChipSuggestions,
                value: String(chipQuerySuggestions.count))
        )

        // we only log the first 6 positions which should cover what's appear on most screens without scrolling
        return snapshotLogAttributes + Array(implLogAttributes.prefix(6))
    }
}
