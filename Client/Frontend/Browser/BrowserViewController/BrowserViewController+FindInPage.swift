/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import Shared
import SwiftUI

extension BrowserViewController {
    func updateFindInPageVisibility(visible: Bool, tab: Tab? = nil, query: String? = nil) {
        if visible {
            // delay displaying query till after animation to prevent weird spacing
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) { [unowned self] in
                overlayWindowManager?.createWindow(
                    with: findInPageViewController,
                    height: 50,
                    addShadow: true,
                    alignToBottom: true)
            }

            if let query = query {
                findInPageViewController.model.searchValue = query
            }
        } else {
            let tab = tab ?? tabManager.selectedTab
            guard let webView = tab?.webView else { return }
            webView.evaluateJavascriptInDefaultContentWorld("__firefox__.findDone()")

            overlayWindowManager?.removeCurrentWindow()
        }
    }
}

extension BrowserViewController: FindInPageHelperDelegate {
    func findInPageHelper(
        _ findInPageHelper: FindInPageHelper, didUpdateCurrentResult currentResult: Int
    ) {
        findInPageViewController.model.currentIndex = currentResult
    }

    func findInPageHelper(
        _ findInPageHelper: FindInPageHelper, didUpdateTotalResults totalResults: Int
    ) {
        findInPageViewController.model.numberOfResults = totalResults
    }
}
