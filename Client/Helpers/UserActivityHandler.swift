/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import CoreSpotlight
import Foundation
import MobileCoreServices
import Shared
import Storage
import SwiftUI
import WebKit

private let browsingActivityType: String = "co.neeva.app.ios.browser.browsing"

private let searchableIndex = CSSearchableIndex(name: "neeva")

class UserActivityHandler {
    init() {
        register(
            self, forTabEvents: .didClose, .didLoseFocus, .didGainFocus, .didChangeURL,
            .didLoadPageMetadata)  // .didLoadFavicon, // TODO: Bug 1390294
    }

    class func clearSearchIndex(completionHandler: ((Error?) -> Void)? = nil) {
        searchableIndex.deleteAllSearchableItems(completionHandler: completionHandler)
    }

    fileprivate func setUserActivityForTab(_ tab: Tab, url: URL) {
        guard !tab.isIncognito, url.isWebPage(includeDataURIs: false), !InternalURL.isValid(url: url)
        else {
            tab.userActivity?.resignCurrent()
            tab.userActivity = nil
            return
        }

        tab.userActivity?.invalidate()

        let userActivity = NSUserActivity(activityType: browsingActivityType)
        userActivity.webpageURL = url
        userActivity.becomeCurrent()

        tab.userActivity = userActivity
    }

    class func presentTextSizeView(webView: WKWebView, overlayParent: UIViewController) {
        let sheet = UIHostingController(
            rootView: TextSizeView(
                model: TextSizeModel(webView: webView),
                onDismiss: { [overlayParent] in
                    overlayParent.presentedViewController?.dismiss(animated: true, completion: nil)
                }
            )
        )
        sheet.modalPresentationStyle = .overFullScreen
        sheet.view.isOpaque = false
        sheet.view.backgroundColor = .clear
        overlayParent.present(sheet, animated: true, completion: nil)
    }
}

extension UserActivityHandler: TabEventHandler {
    func tabDidGainFocus(_ tab: Tab) {
        tab.userActivity?.becomeCurrent()
    }

    func tabDidLoseFocus(_ tab: Tab) {
        tab.userActivity?.resignCurrent()
    }

    func tab(_ tab: Tab, didChangeURL url: URL) {
        setUserActivityForTab(tab, url: url)
    }

    func tab(_ tab: Tab, didLoadPageMetadata metadata: PageMetadata) {
        setUserActivityForTab(tab, url: metadata.siteURL)
    }

    func tabDidClose(_ tab: Tab) {
        guard let userActivity = tab.userActivity else {
            return
        }
        tab.userActivity = nil
        userActivity.invalidate()
    }
}
