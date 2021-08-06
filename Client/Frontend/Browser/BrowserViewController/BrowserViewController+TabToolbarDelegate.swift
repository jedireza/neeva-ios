/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import Defaults
import Shared
import SwiftUI

extension BrowserViewController: TabToolbarDelegate {
    func tabToolbarDidPressBack() {
        if simulateBackViewController?.goBack() ?? false {
            return
        }

        ClientLogger.shared.logCounter(
            .ClickBack, attributes: EnvironmentHelper.shared.getAttributes())

        tabManager.selectedTab?.goBack()
    }

    func tabToolbarDidLongPressBackForward() {
        let generator = UIImpactFeedbackGenerator(style: .heavy)
        generator.impactOccurred()
        showBackForwardList()
    }

    func tabToolbarDidPressForward() {
        if simulateForwardViewController?.goForward() ?? false {
            return
        }

        ClientLogger.shared.logCounter(
            .ClickForward, attributes: EnvironmentHelper.shared.getAttributes())

        tabManager.selectedTab?.goForward()
    }

    func tabToolbarDidPressOverflow() {
        let isPrivate = tabManager.selectedTab?.isPrivate ?? false
        let image = screenshot()

        self.showOverlaySheetViewController(
            OverflowMenuViewController(
                delegate: self,
                onDismiss: {
                    self.hideOverlaySheetViewController()
                    self.isNeevaMenuSheetOpen = false
                }, isPrivate: isPrivate, feedbackImage: image,
                tabToolbarModel: toolbarModel,
                urlBarModel: urlBar.shared.model,
                changedUserAgent: tabManager.selectedTab?.changedUserAgent
            )
        )
        self.dismissVC()
    }

    func tabToolbarDidPressAddNewTab() {
        ClientLogger.shared.logCounter(
            .ClickNewTabButton, attributes: EnvironmentHelper.shared.getAttributes())
        let isPrivate = tabManager.selectedTab?.isPrivate ?? false
        openBlankNewTab(focusLocationField: true, isPrivate: isPrivate)
    }

    func tabToolbarSpacesMenu() {
        guard let tab = tabManager.selectedTab else { return }
        guard let url = tab.canonicalURL?.displayURL else { return }

        ClientLogger.shared.logCounter(
            .SaveToSpace, attributes: EnvironmentHelper.shared.getAttributes())

        showAddToSpacesSheet(url: url, title: tab.title, webView: tab.webView!)
    }

    func tabToolbarDidPressTabs() {
        showTabTray()
    }

    func tabToolbarTabsMenu() -> UIMenu? {
        guard self.presentedViewController == nil else {
            return nil
        }

        let count =
            tabManager.selectedTab?.isPrivate ?? false
            ? tabManager.normalTabs.count : tabManager.privateTabs.count

        let icon: UIImage?
        if count <= 50 {
            icon = UIImage(systemName: "\(count).square")
        } else {
            // ideally this would be infinity.square but there is no such icon
            let img = UIImage(systemSymbol: ._8Square)
            icon = UIImage(cgImage: img.cgImage!, scale: img.scale, orientation: .left)
        }

        let switchPrivacyMode = { [self] (_: UIAction) in
            _ = tabManager.switchPrivacyMode()
        }
        let incognitoActions = [
            tabManager.selectedTab?.isPrivate ?? false
                ? UIAction(
                    title: Strings.normalBrowsingModeTitle, image: icon, handler: switchPrivacyMode)
                : UIAction(
                    title: Strings.incognitoBrowsingModeTitle, image: icon,
                    handler: switchPrivacyMode)
        ]

        let newTab = UIAction(title: Strings.NewTabTitle, image: UIImage(systemSymbol: .plusSquare))
        { _ in
            DispatchQueue.main.async {
                self.openLazyTab(openedFrom: .openTab(self.tabManager.selectedTab))
            }
        }
        newTab.accessibilityLabel = "New Tab"

        let newIncognitoTab = UIAction(
            title: Strings.NewIncognitoTabTitle, image: UIImage.templateImageNamed("incognito")
        ) { _ in
            DispatchQueue.main.async {
                self.openLazyTab(openedFrom: .openTab(self.tabManager.selectedTab))
            }
        }

        let tabCount =
            tabManager.selectedTab?.isPrivate ?? false
            ? tabManager.privateTabs.count : tabManager.normalTabs.count
        var tabActions = [newTab]

        if let tab = self.tabManager.selectedTab {
            tabActions = tab.isPrivate ? [newIncognitoTab] : [newTab]

            if tabCount > 0 || !tab.isURLStartingPage {
                let closeTab = UIAction(
                    title: Strings.CloseTabTitle, image: UIImage(systemSymbol: .xmark),
                    attributes: .destructive
                ) { _ in
                    if let tab = self.tabManager.selectedTab {
                        self.tabManager.removeTabAndUpdateSelectedTab(tab)
                    }
                }
                closeTab.accessibilityIdentifier = "Close Tab Action"
                tabActions.append(closeTab)
            }
        }

        if tabCount > 1 {
            tabActions.append(
                TabMenu(tabManager: tabManager, alertPresentViewController: self)
                    .createCloseAllTabsAction())
        }

        return UIMenu(sections: [incognitoActions, tabActions])
    }

    func showBackForwardList() {
        if let backForwardList = tabManager.selectedTab?.webView?.backForwardList {
            let backForwardViewController = BackForwardListViewController(
                profile: profile, backForwardList: backForwardList)
            backForwardViewController.tabManager = tabManager
            backForwardViewController.bvc = self
            backForwardViewController.modalPresentationStyle = .overCurrentContext
            backForwardViewController.backForwardTransitionDelegate = BackForwardListAnimator()
            self.present(backForwardViewController, animated: true, completion: nil)
        }
    }
}
