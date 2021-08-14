/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import Foundation
import Shared
import WebKit

/// Handles screenshots for a given tab, including pages with non-webview content.
class ScreenshotHelper {
    var viewIsVisible = false

    fileprivate weak var controller: BrowserViewController?

    init(controller: BrowserViewController) {
        self.controller = controller
    }

    init() {
        self.controller = SceneDelegate.getBVC()
    }

    /// Takes a screenshot of the WebView to be displayed on the tab view page
    /// If taking a screenshot of the zero query page, uses our custom screenshot `UIView` extension function
    /// If taking a screenshot of a website, uses apple's `takeSnapshot` function
    func takeScreenshot(_ tab: Tab) {
        guard let webView = tab.webView, let url = tab.url else {
            Sentry.shared.send(
                message: "Tab Snapshot Error", tag: .tabManager, severity: .debug,
                description: "Tab webView or url is nil")
            return
        }

        if InternalURL(url)?.isZeroQueryURL ?? false {
            if let webviewContainer = controller?.tabContentHost {
                let screenshot = webviewContainer.view.screenshot(
                    quality: UIConstants.ActiveScreenshotQuality)
                tab.setScreenshot(screenshot)
            }
        } else {
            let configuration = WKSnapshotConfiguration()
            // This is for a bug in certain iOS 13 versions, snapshots cannot be taken correctly without this boolean being set
            configuration.afterScreenUpdates = false
            webView.takeSnapshot(with: configuration) { [weak tab] image, error in
                if let image = image {
                    tab?.setScreenshot(image)
                    if FeatureFlag[.cardStrip] {
                        self.controller?.cardStripViewController?.tabCardModel.onDataUpdated()
                    }
                } else if let error = error {
                    Sentry.shared.send(
                        message: "Tab snapshot error", tag: .tabManager, severity: .debug,
                        description: error.localizedDescription)
                } else {
                    Sentry.shared.send(
                        message: "Tab snapshot error", tag: .tabManager, severity: .debug,
                        description: "No error description")
                }
            }
        }
    }

    /// Takes a screenshot after a small delay.
    /// Trying to take a screenshot immediately after didFinishNavigation results in a screenshot
    /// of the previous page, presumably due to an iOS bug. Adding a brief delay fixes this.
    func takeDelayedScreenshot(_ tab: Tab) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            // If the view controller isn't visible, the screenshot will be blank.
            // Wait until the view controller is visible again to take the screenshot.
            guard self.viewIsVisible else {
                tab.pendingScreenshot = true
                return
            }

            self.takeScreenshot(tab)
        }
    }

    func takePendingScreenshots(_ tabs: [Tab]) {
        for tab in tabs where tab.pendingScreenshot {
            tab.pendingScreenshot = false
            takeDelayedScreenshot(tab)
        }
    }
}
