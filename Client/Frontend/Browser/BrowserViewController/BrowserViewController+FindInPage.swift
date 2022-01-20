/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import Shared
import SwiftUI

extension BrowserViewController {
    func updateFindInPageVisibility(visible: Bool, tab: Tab? = nil, query: String? = nil) {
        if visible {
            if FeatureFlag[.enableBrowserView] {
                let model = FindInPageModel(tab: tab ?? tabManager.selectedTab)

                overlayManager.show(
                    overlay:
                        .findInPage(
                            FindInPageView(
                                model: model,
                                onDismiss: {
                                    self.updateFindInPageVisibility(visible: false, tab: tab)
                                }
                            )
                        ))

                model.searchValue = query ?? ""
            } else if findInPageViewController == nil {
                findInPageViewController = FindInPageViewController(
                    model: FindInPageModel(tab: tab ?? tabManager.selectedTab),
                    onDismiss: {
                        self.updateFindInPageVisibility(visible: false, tab: tab)
                    })

                let height: CGFloat = FindInPageViewUX.height
                if let query = query {
                    // delay displaying query till after animation to prevent weird spacing
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
                        guard let self = self,
                            let findInPageViewController = self.findInPageViewController
                        else {
                            return
                        }

                        self.overlayWindowManager?.createWindow(
                            with: findInPageViewController,
                            placement: .findInPage,
                            height: height,
                            addShadow: true)

                        findInPageViewController.model.searchValue = query
                    }
                } else {
                    overlayWindowManager?.createWindow(
                        with: findInPageViewController!,
                        placement: .findInPage,
                        height: height,
                        addShadow: true)
                }
            }
        } else {
            let tab = tab ?? tabManager.selectedTab
            guard let webView = tab?.webView else { return }
            webView.evaluateJavascriptInDefaultContentWorld("__firefox__.findDone()")

            if FeatureFlag[.enableBrowserView], let currentOverlay = overlayManager.currentOverlay,
                case OverlayType.findInPage = currentOverlay
            {
                overlayManager.hideCurrentOverlay(ofPriority: .modal, animate: false)
            } else {
                overlayWindowManager?.removeCurrentWindow()
                findInPageViewController = nil
            }
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
