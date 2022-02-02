// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Shared
import Storage
import UIKit

// TODO(iOS 15): Port this to SwiftUI
struct TabMenu {
    let tabManager: TabManager

    // MARK: Close All Tabs
    func showConfirmCloseAllTabs(sourceView: UIView?) {
        let numberOfTabs = tabManager.getTabCountForCurrentType()
        let isIncognito = tabManager.isIncognito
        guard
            let scene = tabManager.scene as? UIWindowScene,
            let alertVC = scene.frontViewController
        else { return }

        let actionSheet = UIAlertController(
            title: nil,
            message:
                "Are you sure you want to close all open \(isIncognito ? "incognito " : "")tabs?",
            preferredStyle: sourceView == nil ? .alert : .actionSheet
        )

        let closeAction = UIAlertAction(
            title:
                "Close \(numberOfTabs) \(isIncognito ? "Incognito " : "")\(numberOfTabs > 1 ? "Tabs" : "Tab")",
            style: .destructive
        ) { [self] _ in
            tabManager.removeTabs(
                isIncognito ? tabManager.privateTabs : tabManager.normalTabs, showToast: false)
        }
        closeAction.accessibilityLabel = "Confirm Close All Tabs"

        if let popoverPresentationController = actionSheet.popoverPresentationController,
            let sourceView = sourceView
        {
            popoverPresentationController.sourceView = sourceView
        }

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        // add all actions to alert
        actionSheet.addAction(closeAction)
        actionSheet.addAction(cancelAction)
        // show the alert
        alertVC.present(actionSheet, animated: true, completion: nil)
    }

    func createCloseAllTabsAction(sourceView: UIView?) -> UIAction {
        let isPrivate = tabManager.isIncognito
        let action = UIAction(
            title: "Close All \(isPrivate ? "Incognito " : "")Tabs",
            image: UIImage(systemName: "trash"), attributes: .destructive
        ) { _ in
            // make sure the user really wants to close all tabs
            self.showConfirmCloseAllTabs(sourceView: sourceView)
        }
        action.accessibilityLabel = "Close All Tabs"

        Haptics.longPress()

        return action
    }

    // MARK: Recently Closed Tabs
    func createRecentlyClosedTabsMenu() -> UIMenu {
        let recentlyClosed = tabManager.recentlyClosedTabs.joined().filter {
            !InternalURL.isValid(url: ($0.url ?? URL(string: "")))
        }

        var actions = [UIAction]()
        for tab in recentlyClosed {
            let action = UIAction(
                title: tab.title ?? "Untitled", discoverabilityTitle: tab.url?.absoluteString
            ) { _ in
                _ = self.tabManager.restoreSavedTabs([tab])
            }
            action.accessibilityLabel = tab.title ?? "Untitled"
            actions.append(action)
        }

        if recentlyClosed.count > 0 {
            Haptics.longPress()
        }

        return UIMenu(title: "Recently Closed", children: actions)
    }

    // MARK: Open Tab
    func createOpenTabMenu(_ tab: SavedTab, openedTab: @escaping (Tab?, Bool) -> Void)
        -> UIContextMenuConfiguration
    {
        Haptics.longPress()

        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { _ in
            let newTabAction = UIAction(
                title: "Open in New tab",
                image: UIImage(systemName: "plus.square")
            ) { _ in
                let tab = self.tabManager.restoreSavedTabs([tab], shouldSelectTab: false)
                openedTab(tab, false)
            }

            let newIncognitoTabAction = UIAction(
                title: "Open in New Incognito Tab",
                image: UIImage(named: "incognito")?.withRenderingMode(.alwaysTemplate)
            ) { _ in
                let tab = self.tabManager.restoreSavedTabs(
                    [tab], isPrivate: true, shouldSelectTab: true)
                openedTab(tab, true)
            }

            return UIMenu(children: [newTabAction, newIncognitoTabAction])
        }
    }
}
