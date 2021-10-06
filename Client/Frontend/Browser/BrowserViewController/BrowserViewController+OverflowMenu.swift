// Copyright Neeva. All rights reserved.

import Shared

public enum OverflowMenuAction {
    case forward
    case reloadStop
    case newTab
    case findOnPage
    case textSize
    case desktopSite
    case share
    case downloadPage
    case longPressForward
}

extension BrowserViewController {
    func perform(overflowMenuAction: OverflowMenuAction, targetButtonView: UIView?) {
        switch overflowMenuAction {
        case .forward:
            if simulateForwardViewController?.goForward() ?? false {
                return
            }

            tabManager.selectedTab?.goForward()
        case .reloadStop:
            if chromeModel.reloadButton == .reload {
                tabManager.selectedTab?.reload()
            } else {
                tabManager.selectedTab?.stop()
            }
        case .newTab:
            openLazyTab()
        case .findOnPage:
            updateFindInPageVisibility(visible: true)
        case .textSize:
            if let webView = tabManager.selectedTab?.webView {
                UserActivityHandler.presentTextSizeView(
                    webView: webView,
                    overlayParent: self)
            }
        case .desktopSite:
            if let tab = tabManager.selectedTab,
                let url = tab.url
            {
                tab.toggleChangeUserAgent()
                Tab.ChangeUserAgent.updateDomainList(
                    forUrl: url, isChangedUA: tab.changedUserAgent,
                    isPrivate: tab.isIncognito)
            }
        case .share:
            showShareSheet(buttonView: targetButtonView ?? topBar.view)
        case .downloadPage:
            guard let selectedTab = tabManager.selectedTab, let url = selectedTab.url else {
                return
            }

            if !DownloadContentScript.requestBlobDownload(url: url, tab: selectedTab) {
                self.pendingDownloadWebView = selectedTab.webView
                let request = URLRequest(url: url)
                selectedTab.webView?.load(request)
            }
        case .longPressForward:
            self.showBackForwardList()
        }
    }
}
