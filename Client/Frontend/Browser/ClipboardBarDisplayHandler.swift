/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import Foundation
import Shared
import Defaults

public enum ClipboardBarToastUX {
    static let ToastDelay = DispatchTimeInterval.milliseconds(4000)
}

class ClipboardBarDisplayHandler: NSObject, URLChangeDelegate {
    weak var bvc: BrowserViewController?
    weak var tabManager: TabManager?
    private var sessionStarted = true
    private var sessionRestored = false
    private var firstTabLoaded = false
    private var lastDisplayedURL: String?
    private weak var firstTab: Tab?

    init(tabManager: TabManager) {
        self.tabManager = tabManager

        super.init()

        NotificationCenter.default.addObserver(self, selector: #selector(UIPasteboardChanged), name: UIPasteboard.changedNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(appWillEnterForegroundNotification), name: UIApplication.willEnterForegroundNotification, object: nil)
    }

    @objc private func UIPasteboardChanged() {
        // UIPasteboardChanged gets triggered when calling UIPasteboard.general.
        NotificationCenter.default.removeObserver(self, name: UIPasteboard.changedNotification, object: nil)

        UIPasteboard.general.asyncURL().uponQueue(.main) { res in
            defer {
                NotificationCenter.default.addObserver(self, selector: #selector(self.UIPasteboardChanged), name: UIPasteboard.changedNotification, object: nil)
            }

            guard let copiedURL: URL? = res.successValue,
                let url = copiedURL else {
                    return
            }
            self.lastDisplayedURL = url.absoluteString
        }
    }

    @objc private func appWillEnterForegroundNotification() {
        sessionStarted = true
        checkIfShouldDisplayBar()
    }

    private func observeURLForFirstTab(firstTab: Tab) {
        if firstTab.webView == nil {
            // Nothing to do; bail out.
            firstTabLoaded = true
            return
        }
        self.firstTab = firstTab
        firstTab.observeURLChanges(delegate: self)
    }

    func didRestoreSession() {
        guard !sessionRestored else { return }
        if let tabManager = self.tabManager,
            let firstTab = tabManager.selectedTab {
            observeURLForFirstTab(firstTab: firstTab)
        } else {
            firstTabLoaded = true
        }

        sessionRestored = true
        checkIfShouldDisplayBar()
    }

    func tab(_ tab: Tab, urlDidChangeTo url: URL) {
        // Ugly hack to ensure we wait until we're finished restoring the session on the first tab
        // before checking if we should display the clipboard bar.
        guard sessionRestored,
            !url.absoluteString.hasPrefix("\(WebServer.sharedInstance.base)/about/sessionrestore?history=") else {
            return
        }

        tab.removeURLChangeObserver(delegate: self)
        firstTabLoaded = true
        checkIfShouldDisplayBar()
    }

    private func shouldDisplayBar(_ copiedURL: String) -> Bool {
        if !sessionStarted ||
            !sessionRestored ||
            !firstTabLoaded ||
            isClipboardURLAlreadyDisplayed(copiedURL) ||
            !Defaults[.introSeen] {
            return false
        }
        sessionStarted = false
        return true
    }

    // If we already displayed this URL on the previous session, or in an already open
    // tab, we shouldn't display it again
    private func isClipboardURLAlreadyDisplayed(_ clipboardURL: String) -> Bool {
        if lastDisplayedURL == clipboardURL {
            return true
        }

        if let url = URL(string: clipboardURL),
            let _ = tabManager?.getTabFor(url) {
            return true
        }
        return false
    }

    func checkIfShouldDisplayBar() {
        guard Defaults[.showClipboardBar], UIPasteboard.general.hasURLs else {
            // There's no point in doing any of this work unless the
            // user has asked for it in settings, and there is a URL to look at.
            return
        }
        UIPasteboard.general.asyncURL().uponQueue(.main) { res in
            guard let copiedURL: URL? = res.successValue,
                let url = copiedURL else {
                return
            }

            let absoluteString = url.absoluteString

            guard self.shouldDisplayBar(absoluteString) else {
                return
            }

            self.lastDisplayedURL = absoluteString

            let toastView = ToastViewManager.shared.makeToast(text: Strings.GoToCopiedLink, buttonText: Strings.GoButtonTitle, buttonAction: {
                self.bvc?.openURLInNewTabPreservingIncognitoState(url)
            })

            ToastViewManager.shared.enqueue(toast: toastView)
        }
    }
}
