/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import UIKit
import Shared
import Storage
import SwiftUI
import Apollo
import Defaults

protocol SearchViewControllerDelegate: AnyObject {
    func searchViewController(_ searchViewController: SearchViewController, didSelectURL url: URL)
    func searchViewController(_ searchViewController: SearchViewController, didAcceptSuggestion suggestion: String)
    func searchViewController(_ searchViewController: SearchViewController, didHighlightText text: String, search: Bool)
    func searchViewController(_ searchViewController: SearchViewController, didUpdateLensOrBang lensOrBang: ActiveLensBangInfo?)
}

// Storage declares its own Identifiable type
extension Site: Swift.Identifiable {}

enum SearchViewControllerUX {
    static let ImageSize: CGFloat = 29
    static let IconSize: CGFloat = 23
}

struct SuggestionsView: View {
    let isIncognito: Bool
    let suggestions: [Suggestion]
    let lensOrBang: ActiveLensBangInfo?
    let history: Cursor<Site>?
    let error: Error?
    let getKeyboardHeight: () -> CGFloat
    let onReload: () -> ()
    let onOpenURL: (URL) -> ()
    let setSearchInput: (String) -> ()

    var body: some View {
        GeometryReader { outerGeometry in
            /// This is a hack to cause SwiftUI to call this function again when `outerGeometry` changes due to device rotation.
            /// By reading that value, SwiftUI thinks our computation depends on it.
            /// See https://github.com/neevaco/neeva-ios-phoenix/pull/210 for a detailed explanation.
            let _ = outerGeometry.size.height

            VStack(spacing: 0) {
                if let error = error {
                    GeometryReader { geom in
                        ScrollView {
                            ErrorView(error, in: self, tryAgain: onReload)
                                .frame(minHeight: geom.size.height)
                        }
                    }
                } else {
                    SuggestionsList(suggestions: suggestions, lensOrBang: lensOrBang, history: history)
                }
                Spacer()
                    .frame(height: getKeyboardHeight())
            }
            .ignoresSafeArea(edges: [.bottom])
            .environment(\.onOpenURL, onOpenURL)
            .environment(\.setSearchInput, setSearchInput)
            .environment(\.isIncognito, isIncognito)
        }
    }
}

class SearchViewController: UIHostingController<SuggestionsView>, KeyboardHelperDelegate, LoaderListener, Themeable {
    var searchDelegate: SearchViewControllerDelegate?

    fileprivate let isPrivate: Bool
    fileprivate var suggestions: [Suggestion] = []
    fileprivate var lensOrBang: ActiveLensBangInfo?
    fileprivate var error: Error?
    fileprivate let profile: Profile
    fileprivate var suggestionQuery: Apollo.Cancellable?
    fileprivate var historyData: Cursor<Site>? = nil

    static var userAgent: String?

    init(profile: Profile, isPrivate: Bool) {
        self.isPrivate = isPrivate
        self.profile = profile
        super.init(rootView: SuggestionsView(isIncognito: isPrivate, suggestions: [], lensOrBang: nil, history: nil, error: nil, getKeyboardHeight: { 0 }, onReload: { }, onOpenURL: { _ in }, setSearchInput: { _ in }))
        self.render()
    }

    @objc required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    fileprivate func render() {
        rootView = SuggestionsView(
            isIncognito: isPrivate,
            suggestions: suggestions,
            lensOrBang: lensOrBang,
            history: historyData,
            error: error,
            getKeyboardHeight: { [weak self] in
                if let view = self?.view, let currentState = KeyboardHelper.defaultHelper.currentState {
                    return currentState.intersectionHeightForView(view)
                } else {
                    return 0
                }
            },
            onReload: reloadData,
            onOpenURL: { [weak self] in
                if let self = self {
                    self.searchDelegate?.searchViewController(self, didSelectURL: $0)
                }
            },
            setSearchInput: { [weak self] in
                if let self = self {
                    self.searchDelegate?.searchViewController(self, didAcceptSuggestion: $0)
                }
            }
        )
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        KeyboardHelper.defaultHelper.addDelegate(self)

        NotificationCenter.default.addObserver(self, selector: #selector(dynamicFontChanged), name: .DynamicFontChanged, object: nil)
    }

    @objc func dynamicFontChanged(_ notification: Notification) {
        guard notification.name == .DynamicFontChanged else { return }

        reloadData()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reloadData()
    }

    var searchQuery: String = "" {
        didSet {
            // Reload the tableView to show the updated text in each engine.
            reloadData()
        }
    }

    func keyboardHelper(_ keyboardHelper: KeyboardHelper, keyboardWillShowWithState state: KeyboardState) {
        animateSearchEnginesWithKeyboard(state)
    }

    func keyboardHelper(_ keyboardHelper: KeyboardHelper, keyboardDidShowWithState state: KeyboardState) {
    }

    func keyboardHelper(_ keyboardHelper: KeyboardHelper, keyboardWillHideWithState state: KeyboardState) {
        animateSearchEnginesWithKeyboard(state)
    }

    fileprivate func animateSearchEnginesWithKeyboard(_ keyboardState: KeyboardState) {
        keyboardState.animateAlongside {
            self.view.layoutIfNeeded()
            self.render()
        }
    }

    fileprivate func reloadData() {
        suggestionQuery?.cancel()

        if isPrivate || searchQuery.isEmpty || !Defaults[.showSearchSuggestions] || searchQuery.looksLikeAURL() {
            self.suggestions = []
            self.render()
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
                self.searchDelegate?.searchViewController(self, didUpdateLensOrBang: lensOrBang)
                self.lensOrBang = lensOrBang
            }
            if self.suggestions.isEmpty {
                if let lensOrBang = self.lensOrBang,
                   let shortcut = lensOrBang.shortcut,
                   let description = lensOrBang.description,
                   let type = lensOrBang.type,
                   type == .lens || type == .bang,
                   self.searchQuery.trimmingCharacters(in: .whitespaces) == type.sigil + shortcut {
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
                                suggestedQuery: self.searchQuery,
                                boldSpan: [.init(startInclusive: 0, endExclusive: self.searchQuery.count)],
                                source: .unknown
                            )
                        )
                    ]
                }
            }
            if self.lensOrBang == nil {
                self.searchDelegate?.searchViewController(self, didUpdateLensOrBang: nil)
            }
            self.render()
        }
    }

    func loader(dataLoaded data: Cursor<Site>) {
        self.historyData = data
        self.render()
    }

    func applyTheme() {
        reloadData()
        self.overrideUserInterfaceStyle = ThemeManager.instance.current.userInterfaceStyle
    }
}

extension SearchViewController {
//    func handleKeyCommands(sender: UIKeyCommand) {
//        let initialSection = SearchListSection.bookmarksAndHistory.rawValue
//        guard let current = tableView.indexPathForSelectedRow else {
//            let count = tableView(tableView, numberOfRowsInSection: initialSection)
//            if sender.input == UIKeyCommand.inputDownArrow, count > 0 {
//                let next = IndexPath(item: 0, section: initialSection)
//                self.tableView(tableView, didHighlightRowAt: next)
//                tableView.selectRow(at: next, animated: false, scrollPosition: .top)
//            }
//            return
//        }
//
//        let nextSection: Int
//        let nextItem: Int
//        guard let input = sender.input else { return }
//        switch input {
//        case UIKeyCommand.inputUpArrow:
//            // we're going down, we should check if we've reached the first item in this section.
//            if current.item == 0 {
//                // We have, so check if we can decrement the section.
//                if current.section == initialSection {
//                    // We've reached the first item in the first section.
//                    searchDelegate?.searchViewController(self, didHighlightText: searchQuery, search: false)
//                    return
//                } else {
//                    nextSection = current.section - 1
//                    nextItem = tableView(tableView, numberOfRowsInSection: nextSection) - 1
//                }
//            } else {
//                nextSection = current.section
//                nextItem = current.item - 1
//            }
//        case UIKeyCommand.inputDownArrow:
//            let currentSectionItemsCount = tableView(tableView, numberOfRowsInSection: current.section)
//            if current.item == currentSectionItemsCount - 1 {
//                if current.section == tableView.numberOfSections - 1 {
//                    // We've reached the last item in the last section
//                    return
//                } else {
//                    // We can go to the next section.
//                    nextSection = current.section + 1
//                    nextItem = 0
//                }
//            } else {
//                nextSection = current.section
//                nextItem = current.item + 1
//            }
//        default:
//            return
//        }
//        guard nextItem >= 0 else {
//            return
//        }
//        let next = IndexPath(item: nextItem, section: nextSection)
//        self.tableView(tableView, didHighlightRowAt: next)
//        tableView.selectRow(at: next, animated: false, scrollPosition: .middle)
//    }
}

/**
 * Private extension containing string operations specific to this view controller
 */
fileprivate extension String {
    func looksLikeAURL() -> Bool {
        // The assumption here is that if the user is typing in a forward slash and there are no spaces
        // involved, it's going to be a URL. If we type a space, any url would be invalid.
        // See https://bugzilla.mozilla.org/show_bug.cgi?id=1192155 for additional details.
        return self.contains("/") && !self.contains(" ")
    }
}
