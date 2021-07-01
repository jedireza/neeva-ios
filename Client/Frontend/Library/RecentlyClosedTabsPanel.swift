/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import UIKit

import Shared
import Storage
import XCGLogger

private let log = Logger.browserLogger

private enum RecentlyClosedPanelUX {
    static let IconSize = CGSize(width: 23, height: 23)
    static let IconBorderColor = UIColor.Photon.Grey30
    static let IconBorderWidth: CGFloat = 0.5
}

class RecentlyClosedTabsPanel: UIViewController, LibraryPanel {
    weak var libraryPanelDelegate: LibraryPanelDelegate?
    let profile: Profile

    fileprivate lazy var tableViewController = RecentlyClosedTabsPanelSiteTableViewController(profile: profile)

    init(profile: Profile) {
        self.profile = profile
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor.theme.tableView.headerBackground

        tableViewController.libraryPanelDelegate = libraryPanelDelegate
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
    weak var libraryPanelDelegate: LibraryPanelDelegate?
    var recentlyClosedTabs: [SavedTab] = []
    weak var recentlyClosedTabsPanel: RecentlyClosedTabsPanel?
    weak var tabManager: TabManager?

    var longPressIndexPath: IndexPath?

    fileprivate lazy var longPressRecognizer: UILongPressGestureRecognizer = {
        return UILongPressGestureRecognizer(target: self, action: #selector(RecentlyClosedTabsPanelSiteTableViewController.longPress))
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.addGestureRecognizer(longPressRecognizer)
        tableView.accessibilityIdentifier = "Recently Closed Tabs List"

        tabManager = BrowserViewController.foregroundBVC().tabManager
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadData()
    }

    func loadData()  {
        if let recentlyClosedTabs = tabManager?.recentlyClosedTabs {
            self.recentlyClosedTabs = recentlyClosedTabs
            self.tableView.reloadData()
        }
    }

    @objc fileprivate func longPress(_ longPressGestureRecognizer: UILongPressGestureRecognizer) {
        guard longPressGestureRecognizer.state == .began else { return }
        let touchPoint = longPressGestureRecognizer.location(in: tableView)

        guard let indexPath = tableView.indexPathForRow(at: touchPoint) else { return }
        longPressIndexPath = indexPath

        presentContextMenu(for: indexPath, savedTab: recentlyClosedTabs[indexPath.row])
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
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
            cell?.imageView?.image = cell?.imageView?.image?.createScaled(RecentlyClosedPanelUX.IconSize)
        }

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        _ = tabManager?.restoreSavedTabs([recentlyClosedTabs[indexPath.row]])
        navigationController?.popViewController(animated: true)
    }

    // Functions that deal with showing header rows.
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.recentlyClosedTabs.count
    }
}

extension RecentlyClosedTabsPanelSiteTableViewController: LibraryPanelContextMenu, PhotonActionSheetDelegate {
    func presentContextMenu(for site: Site, with indexPath: IndexPath, completionHandler: @escaping () -> PhotonActionSheet?) {
        guard let contextMenu = completionHandler() else { return }
        contextMenu.savedTab = recentlyClosedTabs[indexPath.row]
        contextMenu.delegate = self

        self.present(contextMenu, animated: true, completion: nil)
    }

    func getSiteDetails(for indexPath: IndexPath) -> Site? {
        let closedTab = recentlyClosedTabs[indexPath.row]
        let site: Site
        if let title = closedTab.title {
            site = Site(url: String(describing: closedTab.url), title: title)
        } else {
            site = Site(url: String(describing: closedTab.url), title: "")
        }
        return site
    }

    func getContextMenuActions(for site: Site, savedTab: SavedTab?, with indexPath: IndexPath) -> [PhotonActionSheetItem]? {
        return getDefaultContextMenuActions(for: site, savedTab: savedTab, libraryPanelDelegate: libraryPanelDelegate)
    }

    func didDismiss() {
        loadData()
    }
}

extension RecentlyClosedTabsPanel: Themeable {
    func applyTheme() {
        tableViewController.tableView.reloadData()
    }
}
