/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import Shared
import NeevaSupport
import SwiftUI

extension BrowserViewController: TabToolbarDelegate, PhotonActionSheetProtocol {
    func tabToolbarDidPressBack(_ tabToolbar: TabToolbarProtocol, button: UIButton) {
        tabManager.selectedTab?.goBack()
    }

    func tabToolbarDidLongPressBack(_ tabToolbar: TabToolbarProtocol, button: UIButton) {
        let generator = UIImpactFeedbackGenerator(style: .heavy)
        generator.impactOccurred()
        showBackForwardList()
    }

    func tabToolbarDidPressReload(_ tabToolbar: TabToolbarProtocol, button: UIButton) {
        tabManager.selectedTab?.reload()
    }

    func tabToolbarReloadMenu(_ tabToolbar: TabToolbarProtocol, button: UIButton) -> UIMenu? {
        guard let tab = tabManager.selectedTab else {
            return nil
        }
        return self.getRefreshLongPressMenu(for: tab)
    }

    func tabToolbarDidPressStop(_ tabToolbar: TabToolbarProtocol, button: UIButton) {
        tabManager.selectedTab?.stop()
    }

    func tabToolbarDidPressForward(_ tabToolbar: TabToolbarProtocol, button: UIButton) {
        tabManager.selectedTab?.goForward()
    }

    func tabToolbarDidLongPressForward(_ tabToolbar: TabToolbarProtocol, button: UIButton) {
        let generator = UIImpactFeedbackGenerator(style: .heavy)
        generator.impactOccurred()
        showBackForwardList()
    }

    func tabToolbarDidPressLibrary(_ tabToolbar: TabToolbarProtocol, button: UIButton) {
        if let libraryDrawerViewController = self.libraryDrawerViewController, libraryDrawerViewController.isOpen {
            libraryDrawerViewController.close()
        } else {
            showLibrary()
        }
    }
    
    func tabToolbarDidPressAddNewTab(_ tabToolbar: TabToolbarProtocol, button: UIButton) {
        let isPrivate = tabManager.selectedTab?.isPrivate ?? false
        tabManager.selectTab(tabManager.addTab(nil, isPrivate: isPrivate))
        focusLocationTextField(forTab: tabManager.selectedTab)
    }
    
    func tabToolbarSpacesMenu(_ tabToolbar: TabToolbarProtocol, button: UIButton) {
        guard let tab = tabManager.selectedTab else { return }
        guard let url = tab.canonicalURL?.displayURL else { return }

        tab.webView!.evaluateJavaScript("document.querySelector('meta[name=\"description\"]').content") { (result, error) in
            self.present(AddToSpaceViewController(
                title: tab.title ?? url.absoluteString,
                description: result as? String,
                url: url,
                onDismiss: { _ in
                    self.dismissVC()
                    SimpleToast().showAlertWithText("Added to Space", bottomContainer: self.webViewContainer)
                },
                onOpenURL: {
                    self.dismissVC()
                    self.settingsOpenURLInNewTab($0)
                }
            ), animated: true, completion: nil)
        }
    }
    
    func tabToolbarDidPressTabs(_ tabToolbar: TabToolbarProtocol, button: UIButton) {
        showTabTray()
        TelemetryWrapper.recordEvent(category: .action, method: .press, object: .tabToolbar, value: .tabView)
    }

    func getTabToolbarLongPressActionsForModeSwitching() -> [UIMenuElement] {
        guard let selectedTab = tabManager.selectedTab else { return [] }
        let count = selectedTab.isPrivate ? tabManager.normalTabs.count : tabManager.privateTabs.count

        func action() {
            let result = tabManager.switchPrivacyMode()
            if result == .createdNewTab, NewTabAccessors.getNewTabPage(self.profile.prefs) == .blankPage {
                focusLocationTextField(forTab: tabManager.selectedTab)
            }
        }

        let icon: UIImage?
        if count <= 50 {
                    icon = UIImage(systemName: "\(count).square")
        } else {
            // ideally this would be infinity.square but there is no such icon
            let img = UIImage(systemName: "8.square")!
            icon = UIImage(cgImage: img.cgImage!, scale: img.scale, orientation: .left)
        }

        let privateBrowsingMode = UIAction(title: Strings.privateBrowsingModeTitle, image: icon) { _ in
            action()
        }
        let normalBrowsingMode = UIAction(title: Strings.normalBrowsingModeTitle, image: icon) { _ in
            action()
        }

        if let tab = self.tabManager.selectedTab {
            return tab.isPrivate ? [normalBrowsingMode] : [privateBrowsingMode]
        }
        return [privateBrowsingMode]
    }

    func getMoreTabToolbarLongPressActions() -> [UIMenuElement] {
        let newTab = UIAction(title: Strings.NewTabTitle, image: UIImage(systemName: "plus")) { _ in
            let shouldFocusLocationField = NewTabAccessors.getNewTabPage(self.profile.prefs) == .blankPage
            self.openBlankNewTab(focusLocationField: shouldFocusLocationField, isPrivate: false)
        }
        let newPrivateTab = UIAction(title: Strings.NewPrivateTabTitle, image: UIImage(systemName: "plus")) { _ in
            let shouldFocusLocationField = NewTabAccessors.getNewTabPage(self.profile.prefs) == .blankPage
            self.openBlankNewTab(focusLocationField: shouldFocusLocationField, isPrivate: true)}
        let closeTab = UIAction(title: Strings.CloseTabTitle, image: UIImage(systemName: "xmark")) { _ in
            if let tab = self.tabManager.selectedTab {
                self.tabManager.removeTabAndUpdateSelectedIndex(tab)
                self.updateTabCountUsingTabManager(self.tabManager)
            }}
        if let tab = self.tabManager.selectedTab {
            return tab.isPrivate ? [newPrivateTab, closeTab] : [newTab, closeTab]
        }
        return [newTab, closeTab]
    }

    func tabToolbarTabsMenu(_ tabToolbar: TabToolbarProtocol, button: UIButton) -> UIMenu? {
        guard self.presentedViewController == nil else {
            return nil
        }
        var actions: [[UIMenuElement]] = []
        actions.append(getTabToolbarLongPressActionsForModeSwitching())
        actions.append(getMoreTabToolbarLongPressActions())

        return UIMenu(sections: actions)
    }

    func showBackForwardList() {
        if let backForwardList = tabManager.selectedTab?.webView?.backForwardList {
            let backForwardViewController = BackForwardListViewController(profile: profile, backForwardList: backForwardList)
            backForwardViewController.tabManager = tabManager
            backForwardViewController.bvc = self
            backForwardViewController.modalPresentationStyle = .overCurrentContext
            backForwardViewController.backForwardTransitionDelegate = BackForwardListAnimator()
            self.present(backForwardViewController, animated: true, completion: nil)
        }
    }

    func tabToolbarDidPressSearch(_ tabToolbar: TabToolbarProtocol, button: UIButton) {
        focusLocationTextField(forTab: tabManager.selectedTab)
    }
}

