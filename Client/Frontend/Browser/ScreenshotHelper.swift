/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import Foundation
import Shared
import WebKit

private let log = Logger.browser

/// Handles screenshots for a given tab, including pages with non-webview content.
class ScreenshotHelper {
    var viewIsVisible = false

    fileprivate weak var controller: BrowserViewController?

    init(controller: BrowserViewController) {
        self.controller = controller
    }

    init() {
        self.controller = SceneDelegate.getBVC(for: nil)
    }

    /// Takes a screenshot of the WebView to be displayed on the tab view page
    /// If taking a screenshot of the zero query page, uses our custom screenshot `UIView` extension function
    /// If taking a screenshot of a website, uses apple's `takeSnapshot` function
    func takeScreenshot(_ tab: Tab) {
        guard let webView = tab.webView else {
            log.error("Tab Snapshot Error: webView is nil")
            return
        }

        let configuration = WKSnapshotConfiguration()
        // This is for a bug in certain iOS 13 versions, snapshots cannot be taken correctly without this boolean being set
        configuration.afterScreenUpdates = false
        webView.takeSnapshot(with: configuration) { [weak tab] image, error in
            // Unfortunately WebKit can sometimes report success but provide only
            // an empty image. This seems to happen when the WebView is added and
            // removed quickly from the scene. Just ignore these cases and let the
            // tab continue using whatever screenshot it used to have.
            if let image = image, image.size.width != .zero && image.size.height != .zero {
                tab?.setScreenshot(image)
                if FeatureFlag[.cardStrip] {
                    self.controller?.tabContainerModel.tabCardModel.onDataUpdated()
                }
            } else if let error = error {
                log.error("Tab snapshot error: \(error.localizedDescription)")
            } else {
                log.error("Tab snapshot error: bad image!?")
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
