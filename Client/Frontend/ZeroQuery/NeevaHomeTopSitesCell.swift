/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import Foundation
import SDWebImage
import Shared
import Storage
import SwiftUI

/*
 The View that describes the topSite cell that appears in the tableView.
 */
class HomeUIView: UIView {

    lazy var collectionView: UIView = {
        let home = NeevaHome(incognito: false)
        let controller = UIHostingController(
            rootView: home.environmentObject(
                delegate?.viewModel ?? SuggestedSitesViewModel(sites: [Site]())))
        controller.view.backgroundColor = UIColor.clear
        return controller.view
    }()

    weak var delegate: HomeViewDelegate? {
        didSet {
            self.addSubview(collectionView)

            collectionView.snp.makeConstraints { make in
                make.edges.equalTo(self.safeArea.edges)
                make.left.equalTo(NeevaHomeUX.rowSpacing).offset(15)
            }
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        isAccessibilityElement = false
        accessibilityIdentifier = "TopSitesCell"
        backgroundColor = UIColor.clear
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

/*
 This Delegate/DataSource is used to manage the ASHorizontalScrollCell's UICollectionView.
 This is left generic enough for it to be re used for other parts of Activity Stream.
 */

class HomeViewDelegate: NSObject {
    var viewModel = SuggestedSitesViewModel(sites: [Site]())

    var urlPressedHandler: ((URL, IndexPath) -> Void)?
    // The current traits that define the parent ViewController. Used to determine how many rows/columns should be created.
    var currentTraits: UITraitCollection?

    func numberOfHorizontalItems() -> Int {
        guard let traits = currentTraits else {
            return 0
        }
        let isLandscape = UIApplication.shared.statusBarOrientation.isLandscape
        if UIDevice.current.userInterfaceIdiom == .phone {
            if isLandscape {
                return 8
            } else {
                return 6
            }
        }
        // On iPad
        // The number of items in a row is equal to the number of highlights in a row * 2
        var numItems = Int(
            NeevaHomeUX.numberOfItemsPerRowForSizeClassIpad[traits.horizontalSizeClass])
        if UIApplication.shared.statusBarOrientation.isPortrait
            || (traits.horizontalSizeClass == .compact && isLandscape)
        {
            numItems = numItems - 1
        }
        return numItems * 2
    }
}
