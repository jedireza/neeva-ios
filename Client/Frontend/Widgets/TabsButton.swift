/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import Foundation
import SnapKit
import Shared
import NeevaSupport

struct TabsButtonUX {
    static let CornerRadius: CGFloat = 2
    static let TitleFont: UIFont = UIConstants.DefaultChromeSmallFontBold
    static let BorderStrokeWidth: CGFloat = 2
}

class TabsButton: UIButton {
    override var transform: CGAffineTransform {
        didSet {
            clonedTabsButton?.transform = transform
        }
    }

    lazy var insideButton: UIView = {
        let view = UIView()
        view.clipsToBounds = false
        view.isUserInteractionEnabled = false
        return view
    }()

    fileprivate lazy var doubleSquareImageView: UIImageView = {
        let doubleSquareIcon = UIImage(systemName: "square.on.square", withConfiguration: UIImage.SymbolConfiguration(pointSize: 21, weight: .medium))
        let imageView = UIImageView(image: doubleSquareIcon)
        imageView.tintColor = UIColor.Photon.Grey80
        imageView.frame = CGRect(x: 0, y: 0, width: 26, height: 24)
        imageView.tintColor = UIColor.TabTray.tabsButton
        return imageView
    }()

    // Used to temporarily store the cloned button so we can respond to layout changes during animation
    fileprivate weak var clonedTabsButton: TabsButton?

    override init(frame: CGRect) {
        super.init(frame: frame)
        insideButton.addSubview(doubleSquareImageView)
        addSubview(insideButton)
        isAccessibilityElement = true
        accessibilityTraits.insert(.button)
    }

    override func updateConstraints() {
        super.updateConstraints()
        insideButton.snp.remakeConstraints { (make) -> Void in
            make.size.equalTo(20)
            make.center.equalTo(self)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc override func clone() -> UIView {
        let button = TabsButton()
        button.accessibilityLabel = accessibilityLabel
        return button
    }

    @objc func cloneDidClickTabs() {
        sendActions(for: .touchUpInside)
    }


}

