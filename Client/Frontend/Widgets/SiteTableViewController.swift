/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import Storage
import UIKit

private enum SiteTableViewControllerUX {
    static let RowHeight: CGFloat = 44
}

/// Provides base shared functionality for site rows and headers.
@objcMembers
class SiteTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    fileprivate let CellIdentifier = "CellIdentifier"
    let profile: Profile

    var data: Cursor<Site> = Cursor<Site>(status: .success, msg: "No data set")
    var tableView = UITableView()

    private override init(nibName: String?, bundle: Bundle?) {
        fatalError("init(coder:) has not been implemented")
    }

    init(profile: Profile) {
        self.profile = profile
        super.init(nibName: nil, bundle: nil)
        navigationController?.navigationBar.barTintColor =
            UIColor.legacyTheme.tableView.headerBackground
        navigationController?.navigationBar.tintColor = .ui.adaptive.blue
        navigationController?.navigationBar.titleTextAttributes = [
            .foregroundColor: UIColor.legacyTheme.tableView.headerTextDark
        ]

        tableView.backgroundColor = UIColor.legacyTheme.tableView.rowBackground
        tableView.separatorColor = UIColor.legacyTheme.tableView.separator
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.edges.equalTo(self.view)
            return
        }

        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(SiteTableViewCell.self, forCellReuseIdentifier: CellIdentifier)
        tableView.layoutMargins = .zero
        tableView.keyboardDismissMode = .onDrag

        tableView.accessibilityIdentifier = "SiteTable"
        tableView.cellLayoutMarginsFollowReadableWidth = false
        tableView.estimatedRowHeight = SiteTableViewControllerUX.RowHeight

        // Set an empty footer to prevent empty cells from appearing in the list.
        tableView.tableFooterView = UIView()
    }

    deinit {
        // The view might outlive this view controller thanks to animations;
        // explicitly nil out its references to us to avoid crashes. Bug 1218826.
        tableView.dataSource = nil
        tableView.delegate = nil
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        reloadData()
    }

    override func viewWillTransition(
        to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator
    ) {
        super.viewWillTransition(to: size, with: coordinator)
        tableView.setEditing(false, animated: false)
    }

    func reloadData() {
        if data.status != .success {
            print("Err: \(data.statusMessage)", terminator: "\n")
        } else {
            self.tableView.reloadData()
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier, for: indexPath)
        if self.tableView(tableView, hasFullWidthSeparatorForRowAtIndexPath: indexPath) {
            cell.separatorInset = .zero
        }
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

    func tableView(
        _ tableView: UITableView, hasFullWidthSeparatorForRowAtIndexPath indexPath: IndexPath
    ) -> Bool {
        return false
    }
}
