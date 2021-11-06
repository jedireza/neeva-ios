// Copyright Neeva. All rights reserved.

import Combine
import SwiftUI

enum SearchFunction: String {
    case find = "find"
    case findNext = "findNext"
    case findPrevious = "findPrevious"
}

class FindInPageModel: ObservableObject {
    // MARK: Properties
    var tab: Tab?

    @Published var searchValue: String = "" {
        didSet {
            search(function: .find)
        }
    }

    @Published var currentIndex: Int = 0
    @Published var numberOfResults: Int = 0
    var matchIndex: String {
        "\(currentIndex) of \(numberOfResults > 500 ? "500+" : String(numberOfResults))"
    }

    // MARK: Searching
    private func search(function: SearchFunction) {
        guard let tab = tab, let webView = tab.webView else { return }

        do {
            guard
                let escapedEncoded = String(
                    data: try JSONEncoder().encode(searchValue), encoding: .utf8)
            else { return }
            webView.evaluateJavascriptInDefaultContentWorld(
                "__firefox__.\(function.rawValue)(\(escapedEncoded))")
        } catch {
            print("Error encoding escaped value: \(error)")
        }
    }

    /// Navigates to the next result
    public func next() {
        search(function: .findNext)
    }

    /// Navigates to the previous result
    public func previous() {
        search(function: .findPrevious)
    }

    // MARK: Initialization
    init(tab: Tab?) {
        self.tab = tab
    }
}
