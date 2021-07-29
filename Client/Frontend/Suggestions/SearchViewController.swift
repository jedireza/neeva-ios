/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import Apollo
import Defaults
import Shared
import Storage
import SwiftUI
import UIKit

protocol SearchViewControllerDelegate: AnyObject {
    func searchViewController(_ searchViewController: SearchViewController, didSelectURL url: URL)
    func searchViewController(
        _ searchViewController: SearchViewController, didAcceptSuggestion suggestion: String)
}

enum SearchViewControllerUX {
    static let FaviconSize: CGFloat = 12
    static let IconSize: CGFloat = 20
}

struct SuggestionsView: View {
    // not an ObservedObject because we pass it directly to .environmentObject without reading any mutable properties
    let historyModel: HistorySuggestionModel
    @ObservedObject var neevaModel: NeevaSuggestionModel
    let navModel: NavSuggestionModel
    let getKeyboardHeight: () -> CGFloat
    let onOpenURL: (URL) -> Void
    let setSearchInput: (String) -> Void

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
                        .environmentObject(navModel)
                }
                Spacer()
                    .frame(height: getKeyboardHeight())
            }
            .ignoresSafeArea(edges: [.bottom])
            .environment(\.onOpenURL, onOpenURL)
            .environment(\.setSearchInput, setSearchInput)
        }
    }
}

class SearchViewController: IncognitoAwareHostingController<SuggestionsView>, KeyboardHelperDelegate
{
    var searchDelegate: SearchViewControllerDelegate?

    fileprivate let historyModel: HistorySuggestionModel
    fileprivate let neevaModel: NeevaSuggestionModel
    let navModel: NavSuggestionModel
    fileprivate let profile: Profile

    init(profile: Profile, historyModel: HistorySuggestionModel, neevaModel: NeevaSuggestionModel) {
        self.profile = profile
        self.historyModel = historyModel
        self.neevaModel = neevaModel
        self.navModel = NavSuggestionModel(neevaModel: neevaModel, historyModel: historyModel)
        super.init { [navModel] in
            SuggestionsView(
                historyModel: historyModel,
                neevaModel: neevaModel,
                navModel: navModel,
                getKeyboardHeight: { 0 },
                onOpenURL: { _ in },
                setSearchInput: { _ in }
            )
        }
        self.render()
    }

    @objc required dynamic init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    fileprivate func render() {
        setRootView { [historyModel, neevaModel, navModel] in
            SuggestionsView(
                historyModel: historyModel,
                neevaModel: neevaModel,
                navModel: navModel,
                getKeyboardHeight: { [weak self] in
                    if let view = self?.view,
                        let currentState = KeyboardHelper.defaultHelper.currentState
                    {
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
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        KeyboardHelper.defaultHelper.addDelegate(self)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        neevaModel.reload()
    }

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

    fileprivate func animateSearchEnginesWithKeyboard(_ keyboardState: KeyboardState) {
        keyboardState.animateAlongside {
            self.view.layoutIfNeeded()
            self.render()
        }
    }

    override func applyUIMode(isPrivate: Bool) {
        super.applyUIMode(isPrivate: isPrivate)
        neevaModel.setIncognito(isPrivate)
    }
}
