/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import Shared
import Storage
import UIKit
import XCGLogger

private let log = Logger.browser

private enum RecentlyClosedPanelUX {
    static let IconSize = CGSize(width: 23, height: 23)
    static let IconBorderColor = UIColor.Photon.Grey30
    static let IconBorderWidth: CGFloat = 0.5
}

class RecentlyClosedTabsPanel: UIViewController {
    weak var delegate: HistoryPanelDelegate?
    let profile: Profile

    fileprivate lazy var tableViewController = RecentlyClosedTabsPanelSiteTableViewController(
        profile: profile)

    init(profile: Profile) {
        self.profile = profile
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor.legacyTheme.tableView.headerBackground

        tableViewController.delegate = delegate
        tableViewController.recentlyClosedTabsPanel = self

        self.addChild(tableViewController)
        tableViewController.didMove(toParent: self)

        self.view.addSubview(tableViewController.view)
        tableViewController.view.snp.makeConstraints { make in
            make.edges.equalTo(self.view)
        }
    }
}

class RecentlyClosedTabsPanelSiteTableViewController: SiteTableViewController {
    weak var delegate: HistoryPanelDelegate?
    var recentlyClosedTabs: [SavedTab] = []
    weak var recentlyClosedTabsPanel: RecentlyClosedTabsPanel?

    weak var tabManager: TabManager!
    var tabMenu: TabMenu!

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.accessibilityIdentifier = "Recently Closed Tabs List"
        tabManager = BrowserViewController.foregroundBVC().tabManager
        tabMenu = TabMenu(tabManager: tabManager, alertPresentViewController: self)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadData()
    }

    func loadData() {
        if let recentlyClosedTabs = tabManager?.recentlyClosedTabs.joined(),
            recentlyClosedTabs.count > 0
        {
            self.recentlyClosedTabs = Array(recentlyClosedTabs)
            self.tableView.reloadData()
        } else {
            navigationController?.popViewController(animated: true)
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath)
        -> UITableViewCell
    {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        guard let twoLineCell = cell as? TwoLineTableViewCell else {
            return cell
        }

        let tab = recentlyClosedTabs[indexPath.row]
        let displayURL = tab.url?.displayURL ?? tab.url
        twoLineCell.setLines(tab.title, detailText: displayURL?.absoluteDisplayString)

        let site: Favicon? = (tab.faviconURL != nil) ? Favicon(url: tab.faviconURL!) : nil
        cell.imageView?.layer.borderColor = RecentlyClosedPanelUX.IconBorderColor.cgColor
        cell.imageView?.layer.borderWidth = RecentlyClosedPanelUX.IconBorderWidth
        cell.imageView?.contentMode = .center
        cell.imageView?.setImageAndBackground(forIcon: site, website: displayURL) { [weak cell] in
            cell?.imageView?.image = cell?.imageView?.image?.createScaled(
                RecentlyClosedPanelUX.IconSize)
        }

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        _ = tabManager?.restoreSavedTabs([recentlyClosedTabs[indexPath.row]])
        navigationController?.popViewController(animated: true)
    }

    func tableView(
        _ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath,
        point: CGPoint
    ) -> UIContextMenuConfiguration? {
        let index = indexPath.row
        let savedTab = recentlyClosedTabs[index]

        return tabMenu.createOpenTabMenu(savedTab) { (tab, isPrivate) in
            self.loadData()

            let toastLabelText: String =
                isPrivate
                ? Strings.ContextMenuButtonToastNewIncognitoTabOpenedLabelText
                : Strings.ContextMenuButtonToastNewTabOpenedLabelText
            let toastView = ToastViewManager.shared.makeToast(
                text: toastLabelText,
                buttonText: Strings.ContextMenuButtonToastNewTabOpenedButtonText,
                buttonAction: {
                    self.tabManager?.selectTab(tab)
                })

            ToastViewManager.shared.enqueue(toast: toastView)
        }
    }

    // Functions that deal with showing header rows.
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.recentlyClosedTabs.count
    }
}
