/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import Shared

extension BrowserViewController {
    func updateFindInPageVisibility(visible: Bool, tab: Tab? = nil) {
        if visible && findInPageViewController == nil {
            findInPageViewController = FindInPageViewController(
                model: FindInPageModel(tab: tab),
                onDismiss: {
                    self.updateFindInPageVisibility(visible: false, tab: tab)
                })

            showOverlaySheetViewController(findInPageViewController!)
        } else if findInPageViewController != nil
            && findInPageViewController == overlaySheetViewController
        {
            let tab = tab ?? tabManager.selectedTab
            guard let webView = tab?.webView else { return }
            webView.evaluateJavascriptInDefaultContentWorld("__firefox__.findDone()")

            hideOverlaySheetViewController()
            findInPageViewController = nil
        }
    }
}

extension BrowserViewController: FindInPageHelperDelegate {
    func findInPageHelper(
        _ findInPageHelper: FindInPageHelper, didUpdateCurrentResult currentResult: Int
    ) {
        findInPageViewController?.model.currentIndex = currentResult
    }

    func findInPageHelper(
        _ findInPageHelper: FindInPageHelper, didUpdateTotalResults totalResults: Int
    ) {
        findInPageViewController?.model.numberOfResults = totalResults
    }
}
