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
}

enum SearchViewControllerUX {
    static let FaviconSize: CGFloat = 12
    static let IconSize: CGFloat = 20
}

struct SuggestionsView: View {
    // not an ObservedObject because we pass it directly to .environmentObject without reading any mutable properties
    let historyModel: HistorySuggestionModel
    @ObservedObject var neevaModel: NeevaSuggestionModel
    let getKeyboardHeight: () -> CGFloat
    let onOpenURL: (URL) -> ()
    let setSearchInput: (String) -> ()

    var body: some View {
        GeometryReader { outerGeometry in
            /// This is a hack to cause SwiftUI to call this function again when `outerGeometry` changes due to device rotation.
            /// By reading that value, SwiftUI thinks our computation depends on it.
            /// See https://github.com/neevaco/neeva-ios-phoenix/pull/210 for a detailed explanation.
            let _ = outerGeometry.size.height

            VStack(spacing: 0) {
                if let error = neevaModel.error {
                    GeometryReader { geom in
                        ScrollView {
                            ErrorView(error, in: self, tryAgain: neevaModel.reload)
                                .frame(minHeight: geom.size.height)
                        }
                    }
                } else {
                    SuggestionsList()
                        .environmentObject(historyModel)
                        .environmentObject(neevaModel)
                }
                Spacer()
                    .frame(height: getKeyboardHeight())
            }
            .ignoresSafeArea(edges: [.bottom])
            .environment(\.onOpenURL, onOpenURL)
            .environment(\.isIncognito, neevaModel.isIncognito)
            .environment(\.setSearchInput, setSearchInput)
        }
    }
}

class SearchViewController: UIHostingController<SuggestionsView>, KeyboardHelperDelegate {
    var searchDelegate: SearchViewControllerDelegate?

    fileprivate let historyModel: HistorySuggestionModel
    fileprivate let neevaModel: NeevaSuggestionModel

    fileprivate let profile: Profile

    init(profile: Profile, historyModel: HistorySuggestionModel, neevaModel: NeevaSuggestionModel) {
        self.profile = profile
        self.historyModel = historyModel
        self.neevaModel = neevaModel
        super.init(rootView: SuggestionsView(historyModel: historyModel, neevaModel: neevaModel, getKeyboardHeight: { 0 }, onOpenURL: { _ in }, setSearchInput: { _ in }))
        self.render()
    }

    @objc required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    fileprivate func render() {
        rootView = SuggestionsView(
            historyModel: historyModel,
            neevaModel: neevaModel,
            getKeyboardHeight: { [weak self] in
                if let view = self?.view, let currentState = KeyboardHelper.defaultHelper.currentState {
                    return currentState.intersectionHeightForView(view)
                } else {
                    return 0
                }
            },
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
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        neevaModel.reload()
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

