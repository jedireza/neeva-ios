/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import Defaults
import Shared
import SwiftUI

enum ToolbarAction {
    case back
    case forward
    case overflow
    case longPressBackForward
    case addToSpace
    case showTabs
}

extension BrowserViewController {
    var performTabToolbarAction: (ToolbarAction) -> Void {
        { [weak self] action in
            guard let self = self else { return }
            switch action {
            case .back:
                if self.simulateBackViewController?.goBack() ?? false {
                    return
                }
                self.tabManager.selectedTab?.goBack()

            case .forward:
                if self.simulateForwardViewController?.goForward() ?? false {
                    return
                }

                self.tabManager.selectedTab?.goForward()

            case .overflow:
                let isPrivate = self.tabManager.selectedTab?.isPrivate ?? false
                let image = self.screenshot()

                self.showOverlaySheetViewController(
                    OverflowMenuViewController(
                        delegate: self,
                        onDismiss: {
                            self.hideOverlaySheetViewController()
                            self.isNeevaMenuSheetOpen = false
                        }, isPrivate: isPrivate, feedbackImage: image,
                        chromeModel: self.chromeModel,
                        changedUserAgent: self.tabManager.selectedTab?.changedUserAgent
                    )
                )
                self.dismissVC()

            case .longPressBackForward:
                let generator = UIImpactFeedbackGenerator(style: .heavy)
                generator.impactOccurred()
                if let backForwardList = self.tabManager.selectedTab?.webView?.backForwardList {
                    let backForwardViewController = BackForwardListViewController(
                        profile: self.profile, backForwardList: backForwardList)
                    backForwardViewController.tabManager = self.tabManager
                    backForwardViewController.bvc = self
                    backForwardViewController.modalPresentationStyle = .overCurrentContext
                    backForwardViewController.backForwardTransitionDelegate =
                        BackForwardListAnimator()
                    self.present(backForwardViewController, animated: true, completion: nil)
                }

            case .addToSpace:
                guard let tab = self.tabManager.selectedTab else { return }
                guard let url = tab.canonicalURL?.displayURL else { return }

                if FeatureFlag[.spacify],
                    let domain = SpaceImportDomain(rawValue: tab.url?.baseDomain ?? "")
                {
                    tab.webView?.evaluateJavaScript(domain.script) {
                        [unowned self] (result, error) in
                        guard let linkData = result as? [[String]] else {
                            self.showAddToSpacesSheet(
                                url: url, title: tab.title, webView: tab.webView!)
                            return
                        }
                        let importData = SpaceImportHandler(
                            title: tab.url!.path.remove("/").capitalized, data: linkData)
                        self.showAddToSpacesSheet(
                            url: url, title: tab.title,
                            webView: tab.webView!,
                            importData: importData
                        )
                    }
                } else {
                    self.showAddToSpacesSheet(url: url, title: tab.title, webView: tab.webView!)
                }

            case .showTabs:
                self.showTabTray()
            }
        }
    }

    func tabToolbarDidPressAddNewTab() {
        ClientLogger.shared.logCounter(
            .ClickNewTabButton, attributes: EnvironmentHelper.shared.getAttributes())
        let isPrivate = tabManager.selectedTab?.isPrivate ?? false
        openBlankNewTab(focusLocationField: true, isPrivate: isPrivate)
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
}
