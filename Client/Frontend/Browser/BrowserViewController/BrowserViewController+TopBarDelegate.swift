// Copyright Neeva. All rights reserved.

import SFSafeSymbols
import Shared
import Storage

extension BrowserViewController: TopBarDelegate {
    func urlBarDidPressReload() {
        // log tap reload
        ClientLogger.shared.logCounter(
            .TapReload, attributes: EnvironmentHelper.shared.getAttributes())

        tabManager.selectedTab?.reload()
    }

    func urlBarDidPressStop() {
        tabManager.selectedTab?.stop()
    }

    func urlBarReloadMenu() -> UIMenu? {
        guard
            let tab = tabManager.selectedTab,
            tab.webView?.url != nil,
            (tab.getContentScript(name: ReaderMode.name()) as? ReaderMode)?.state != .active
        else { return nil }

        let toggleActionTitle: String
        let iconName: SFSymbol

        let willSwitchToMobile =
            UserAgent.isDesktop(ua: UserAgent.getUserAgent())
            ? !tab.changedUserAgent : tab.changedUserAgent
        if willSwitchToMobile {
            toggleActionTitle = Strings.AppMenuViewMobileSiteTitleString
            let hasHomeButton = UIConstants.safeArea.bottom == 0
            iconName = hasHomeButton ? .iphoneHomebutton : .iphone
        } else {
            toggleActionTitle = Strings.AppMenuViewDesktopSiteTitleString
            iconName = .laptopcomputer
        }

        Haptics.longPress()
        
        return UIMenu(
            children: [
                UIAction(title: toggleActionTitle, image: UIImage(systemSymbol: iconName)) { _ in
                    if let url = tab.url {
                        tab.toggleChangeUserAgent()
                        Tab.ChangeUserAgent.updateDomainList(
                            forUrl: url,
                            isChangedUA: tab.changedUserAgent,
                            isPrivate: self.tabManager.isIncognito
                        )
                    }
                }
            ]
        )
    }

    func urlBar(didSubmitText text: String) {
        let currentTab = tabManager.selectedTab

        if let fixupURL = URIFixup.getURL(text) {
            // The user entered a URL, so use it.
            finishEditingAndSubmit(fixupURL, visitType: VisitType.typed, forTab: currentTab)
            return
        }

        if let queryItems = searchQueryModel.queryItems {
            // User is editing the current query, should preserve the parameters from their original query
            let url = neevaSearchEngine.searchURLFrom(searchQuery: text, queryItems: queryItems)
            finishEditingAndSubmit(url, visitType: VisitType.typed, forTab: currentTab)

            searchQueryModel.queryItems = nil

            return
        }

        // We couldn't build a URL, so check for a matching search keyword.
        let trimmedText = text.trimmingCharacters(in: .whitespaces)
        guard trimmedText.firstIndex(of: " ") != nil else {
            submitSearchText(text, forTab: currentTab)
            return
        }

        self.submitSearchText(text, forTab: currentTab)
    }

    func urlBarDidLongPressOverflow(targetButtonView: UIView) {
        showShareSheet(buttonView: targetButtonView)
    }

    fileprivate func submitSearchText(_ text: String, forTab tab: Tab?) {
        if let searchURL = neevaSearchEngine.searchURLForQuery(text) {
            // We couldn't find a matching search keyword, so do a search query.
            finishEditingAndSubmit(searchURL, visitType: VisitType.typed, forTab: tab)
        } else {
            // We still don't have a valid URL, so something is broken. Give up.
            print("Error handling URL entry: \"\(text)\".")
            assertionFailure("Couldn't generate search URL: \(text)")
        }
    }
}
