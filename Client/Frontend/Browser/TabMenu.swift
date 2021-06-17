// Copyright Neeva. All rights reserved.

import UIKit

class TabMenu {
    var tabManager: TabManager
    var neevaHomeViewController: NeevaHomeViewController?
    var alertPresentViewController: UIViewController?

    // MARK: Close All Tabs
    func showConfirmCloseAllTabs(numberOfTabs: Int) {
        guard let alertPresentViewController = alertPresentViewController else {
            return
        }

        let actionSheet = UIAlertController(title: nil, message: "Are you sure you want to close all open tabs?", preferredStyle: .actionSheet)
        let closeAction = UIAlertAction(title: "Close \(numberOfTabs) Tabs", style: .destructive) { _ in
            self.tabManager.removeAllTabsAndAddNormalTab()
            self.neevaHomeViewController?.homeViewModel.isPrivate = self.tabManager.selectedTab!.isPrivate
        }

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)

        // add all actions to alert
        actionSheet.addAction(closeAction)
        actionSheet.addAction(cancelAction)

        // show the alert
        alertPresentViewController.present(actionSheet, animated: true, completion: nil)
    }

    func createCloseAllTabsAction() -> UIAction {
        return UIAction(title: "Close All Tabs", image: UIImage(systemName: "trash"), attributes: .destructive) { _ in
            // make sure the user really wants to close all tabs
            self.showConfirmCloseAllTabs(numberOfTabs: self.tabManager.tabs.count)
        }
    }

    func createCloseAllTabsMenu() -> UIMenu {
        return UIMenu(sections: [[createCloseAllTabsAction()]])
    }

    // MARK: Recently Closed Tabs
    func createRecentlyClosedTabsMenu() -> UIMenu {
        let recentlyClosed = tabManager.recentlyClosedTabs
        var actions = [UIAction]()

        for tab in recentlyClosed.filter({ !$0.title!.isEmpty }) {
            actions.append(UIAction(title: tab.title!, handler: { _ in

            }))
        }

        return UIMenu(sections: [actions])
    }

    init(tabManager: TabManager, neevaHomeViewController: NeevaHomeViewController? = nil, alertPresentViewController: UIViewController? = nil) {
        self.tabManager = tabManager
        self.neevaHomeViewController = neevaHomeViewController
        self.alertPresentViewController = alertPresentViewController

    }
}
