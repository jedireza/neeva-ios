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
            let sheet = UIHostingController(
                rootView: TextSizeView(
                    model: TextSizeModel(webView: webView),
                    onDismiss: { [self] in
                        presentedViewController?.dismiss(
                            animated: true,
                            completion: nil)
                    }
                )
            )
            sheet.modalPresentationStyle = .overFullScreen
            sheet.view.isOpaque = false
            sheet.view.backgroundColor = .clear
            present(sheet, animated: true, completion: nil)
        }
    }

    func didPressRequestDesktopSite() {
        if let tab = tabManager.selectedTab,
           let url = tab.url {
            tab.toggleChangeUserAgent()
            Tab.ChangeUserAgent.updateDomainList(
                forUrl: url, isChangedUA: tab.changedUserAgent,
                isPrivate: tab.isPrivate)
        }
    }

}
