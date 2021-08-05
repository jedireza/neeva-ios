// Copyright Neeva. All rights reserved.

import SFSafeSymbols
import Shared
import Storage
import SwiftUI

extension BrowserViewController: OverflowMenuDelegate {
    func didPressForward() {
        if simulateForwardViewController?.goForward() ?? false {
            return
        }

        tabManager.selectedTab?.goForward()
    }

    func didPressReload() {
        tabManager.selectedTab?.reload()
    }

    func didPressStopLoading() {
        tabManager.selectedTab?.reload()
    }

    func didPressAddNewTab() {
        openLazyTab()
    }

    func didPressFindOnPage() {
        updateFindInPageVisibility(visible: true)
    }

    func didPressTextSize() {
        if let tab = tabManager.selectedTab,
            let webView = tab.webView
        {
            UserActivityHandler.presentTextSizeView(
                webView: webView,
                overlayParent: self)
        }
    }

    func didPressRequestDesktopSite() {
        if let tab = tabManager.selectedTab,
            let url = tab.url
        {
            tab.toggleChangeUserAgent()
            Tab.ChangeUserAgent.updateDomainList(
                forUrl: url, isChangedUA: tab.changedUserAgent,
                isPrivate: tab.isPrivate)
        }
    }

}
