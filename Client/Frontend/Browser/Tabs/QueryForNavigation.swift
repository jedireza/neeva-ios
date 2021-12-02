// Copyright Neeva. All rights reserved.

import Foundation
import WebKit

class QueryForNavigation {
    @Published var queryForNavigations = [WKBackForwardListItem: String]()
    var currentSearchQuery: String?

    func findQueryIndexFor(navigation: WKBackForwardListItem) -> Int? {
        return Array(queryForNavigations.keys).firstIndex { $0 == navigation }
    }

    func findQueryFor(navigation: WKBackForwardListItem) -> String? {
        return queryForNavigations[navigation]
    }

    func attachCurrentSearchQueryToCurrentNavigation(webView: WKWebView) {
        if let navigation = webView.backForwardList.currentItem,
            let query = currentSearchQuery, !query.isEmpty
        {
            queryForNavigations[navigation] = query

            let backForwardList = webView.backForwardList.all
            queryForNavigations = queryForNavigations.filter {
                backForwardList.contains($0.key)
            }
        }
    }
}
