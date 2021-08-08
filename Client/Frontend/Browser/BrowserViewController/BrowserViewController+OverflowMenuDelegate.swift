// Copyright Neeva. All rights reserved.

import SFSafeSymbols
import Shared
import Storage
import SwiftUI

extension BrowserViewController: OverflowMenuDelegate {
    func overflowMenuDidPressForward() {
        if simulateForwardViewController?.goForward() ?? false {
            return
        }

        tabManager.selectedTab?.goForward()
    }

    func overflowMenuDidPressReloadStop(_ reloadButtonState: URLBarModel.ReloadButtonState) {
        if reloadButtonState == .reload {
            tabManager.selectedTab?.reload()
        } else {
            tabManager.selectedTab?.stop()
        }
    }

    func overflowMenuDidPressAddNewTab() {
        openLazyTab()
    }

    func overflowMenuDidPressFindOnPage() {
        updateFindInPageVisibility(visible: true)
    }

    func overflowMenuDidPressTextSize() {
        if let webView = tabManager.selectedTab?.webView {
            UserActivityHandler.presentTextSizeView(
                webView: webView,
                overlayParent: self)
        }
    }

    func overflowMenuDidPressRequestDesktopSite() {
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
