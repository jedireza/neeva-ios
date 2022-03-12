// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Foundation
import WebKit

class QueryForNavigation {
    struct Query {
        let typed: String
        let suggested: String?
    }

    @Published var queryForNavigations = [WKBackForwardListItem: Query]()
    var currentQuery: Query?

    func findQueryIndexFor(navigation: WKBackForwardListItem) -> Int? {
        return Array(queryForNavigations.keys).firstIndex { $0 == navigation }
    }

    func findQueryFor(navigation: WKBackForwardListItem) -> Query? {
        return queryForNavigations[navigation]
    }

    func attachCurrentSearchQueryToCurrentNavigation(webView: WKWebView) {
        // attach current suggested query?
        if let navigation = webView.backForwardList.currentItem,
            let query = currentQuery, !query.typed.isEmpty
        {
            queryForNavigations[navigation] = query
            currentQuery = nil

            let backForwardList = webView.backForwardList.all
            queryForNavigations = queryForNavigations.filter {
                backForwardList.contains($0.key)
            }
        }
    }
}
