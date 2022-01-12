// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

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
    case toggleIncognitoMode
    case goToSettings
    case goToHistory
    case goToDownloads
    case closeAllTabs
    case support
    case cryptoWallet
}

extension BrowserViewController {
    func perform(overflowMenuAction: OverflowMenuAction, targetButtonView: UIView?) {
        overlayManager.hideCurrentOverlay()

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
            openLazyTab(openedFrom: .newTabButton)
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
        case .toggleIncognitoMode:
            self.cardGridViewController.toolbarModel.onToggleIncognito()
        case .goToSettings:
            perform(neevaMenuAction: .settings)
        case .goToHistory:
            perform(neevaMenuAction: .history)
        case .goToDownloads:
            openDownloadsFolderInFilesApp()
        case .closeAllTabs:
            TabMenu(tabManager: tabManager).showConfirmCloseAllTabs(sourceView: nil)
        case .support:
            perform(neevaMenuAction: .support)
        case .cryptoWallet:
            let cryptoWalletPanel = CryptoWalletController(onDismiss: {
                self.dismiss(animated: true, completion: nil)
            })
            let navigationController = UINavigationController(rootViewController: cryptoWalletPanel)
            navigationController.modalPresentationStyle = .formSheet

            present(navigationController, animated: true, completion: nil)
        }
    }
}
