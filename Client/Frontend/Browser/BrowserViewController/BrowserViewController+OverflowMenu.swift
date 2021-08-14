// Copyright Neeva. All rights reserved.

import Shared

public enum OverflowMenuAction {
    case forward
    case reloadStop
    case newTab
    case findOnPage
    case textSize
    case readingMode
    case desktopSite
    case share
}

extension BrowserViewController {
    func perform(overflowMenuAction: OverflowMenuAction, targetButtonView: UIView?) {
        switch overflowMenuAction {
        case .forward:
            if simulateForwardViewController?.goForward() ?? false {
                return
            }

            tabManager.selectedTab?.goForward()
            break
        case .reloadStop:
            if chromeModel.reloadButton == .reload {
                tabManager.selectedTab?.reload()
            } else {
                tabManager.selectedTab?.stop()
            }
            break
        case .newTab:
            openLazyTab()
            break
        case .findOnPage:
            updateFindInPageVisibility(visible: true)
            break
        case .textSize:
            if let webView = tabManager.selectedTab?.webView {
                UserActivityHandler.presentTextSizeView(
                    webView: webView,
                    overlayParent: self)
            }
            break
        case .readingMode:
            break
        case .desktopSite:
            if let tab = tabManager.selectedTab,
                let url = tab.url
            {
                tab.toggleChangeUserAgent()
                Tab.ChangeUserAgent.updateDomainList(
                    forUrl: url, isChangedUA: tab.changedUserAgent,
                    isPrivate: tab.isPrivate)
            }
            break
        case .share:
            showShareSheet(buttonView: targetButtonView ?? urlBar.view)
            break
        }
    }
}
