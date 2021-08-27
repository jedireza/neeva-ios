/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import Defaults
import Shared
import SwiftUI

enum ToolbarAction {
    case back
    case overflow
    case longPressBackForward
    case addToSpace
    case showTabs
    case longPressOverflow
}

extension BrowserViewController: ToolbarDelegate {
    var performTabToolbarAction: (ToolbarAction) -> Void {
        { [weak self] action in
            guard let self = self else { return }
            switch action {
            case .back:
                if self.simulateBackViewController?.goBack() ?? false {
                    return
                }
                self.tabManager.selectedTab?.goBack()

            case .overflow:
                self.showOverlaySheetViewController(
                    OverflowMenuViewController(
                        onDismiss: self.hideOverlaySheetViewController,
                        chromeModel: self.chromeModel,
                        locationModel: self.locationModel,
                        changedUserAgent: self.tabManager.selectedTab?.changedUserAgent,
                        menuAction: { action in
                            self.perform(overflowMenuAction: action, targetButtonView: nil)
                        }
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
            case .longPressOverflow:
                self.showShareSheet(buttonView: self.topBar.view)
            }
        }
    }

    func tabToolbarTabsMenu() -> UIMenu? {
        guard self.presentedViewController == nil else {
            return nil
        }

        let switchPrivacyMode = { [self] (_: UIAction) in
            _ = tabManager.toggleIncognitoMode()
        }

        var switchModeTitle = Strings.openIncognitoModeTitle
        var switchModeImage: UIImage? = UIImage(named: "incognito")

        var newTabTitle = Strings.NewTabTitle
        var newTabImage = UIImage(systemSymbol: .plusSquare)
        var newTabAccessibilityLabel = "New Tab"

        if tabManager.isIncognito {
            switchModeTitle = Strings.leaveIncognitoModeTitle
            switchModeImage = nil

            newTabTitle = Strings.NewIncognitoTabTitle
            newTabImage = UIImage(systemSymbol: .plusSquareFill)
            newTabAccessibilityLabel = "New Incognito Tab"
        }

        let switchModeAction = UIAction(
            title: switchModeTitle,
            image: switchModeImage,
            handler: switchPrivacyMode)
        let newTabAction = UIAction(title: newTabTitle, image: newTabImage) { _ in
            DispatchQueue.main.async {
                self.openLazyTab(openedFrom: .openTab(self.tabManager.selectedTab))
            }
        }
        newTabAction.accessibilityLabel = newTabAccessibilityLabel

        var actions = [newTabAction, switchModeAction]

        let tabCount =
            tabManager.isIncognito
            ? tabManager.privateTabs.count : tabManager.normalTabs.count

        if let tab = self.tabManager.selectedTab {
            if tabCount > 0 || !tab.isURLStartingPage {
                let closeTabAction = UIAction(
                    title: Strings.CloseTabTitle, image: UIImage(systemSymbol: .xmark)
                ) { _ in
                    if let tab = self.tabManager.selectedTab {
                        self.tabManager.removeTabAndUpdateSelectedTab(tab, addNewTab: true)
                    }
                }
                closeTabAction.accessibilityIdentifier = "Close Tab Action"
                actions.insert(closeTabAction, at: 0)
            }
        }

        if tabCount > 1 {
            actions.insert(
                TabMenu(tabManager: tabManager, alertPresentViewController: self)
                    .createCloseAllTabsAction(fromTabTray: false), at: 0)
        }

        return UIMenu(sections: [actions])
    }
}
