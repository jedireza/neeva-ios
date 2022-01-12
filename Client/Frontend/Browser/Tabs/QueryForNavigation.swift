// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

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
            currentSearchQuery = nil

            let backForwardList = webView.backForwardList.all
            queryForNavigations = queryForNavigations.filter {
                backForwardList.contains($0.key)
            }
        }
    }
}
