// Copyright Neeva. All rights reserved.

import Combine
import SwiftUI

enum SearchFunction: String {
    case find = "find"
    case findNext = "findNext"
    case findPrevious = "findPrevious"
}

public class FindInPageModel: ObservableObject {
    // MARK: Properties
    let tabManager: TabManager

    @Published var searchValue: String = "" {
        didSet {
            search(function: .find)
        }
    }

    @Published var currentIndex: Int = 0
    @Published var numberOfResults: Int = 0 {
        didSet {
            numberOfResultsUpdate?()
        }
    }

    var numberOfResultsUpdate: (() -> Void)?

    var matchIndex: String {
        "\(currentIndex) of \(numberOfResults > 500 ? "500+" : String(numberOfResults))"
    }

    // MARK: Searching
    private func search(function: SearchFunction) {
        guard let tab = tabManager.selectedTab, let webView = tab.webView else { return }

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
    public init(tabManager: TabManager) {
        self.tabManager = tabManager
    }
}
