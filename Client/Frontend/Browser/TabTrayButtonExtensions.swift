/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import UIKit
import SwiftUI

class PrivateModeButton: ToggleButton, PrivateModeUI {
    var offTint = UIColor.black
    var onTint = UIColor.black

    override init(frame: CGRect) {
        super.init(frame: frame)
        accessibilityLabel = .TabTrayToggleAccessibilityLabel
        accessibilityHint = .TabTrayToggleAccessibilityHint
        let maskImage = UIImage(named: "incognito")?.withRenderingMode(.alwaysTemplate)
        setImage(maskImage, for: [])
        isPointerInteractionEnabled = true
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func applyUIMode(isPrivate: Bool) {
        isSelected = isPrivate

        tintColor = isPrivate ? onTint : offTint
        imageView?.tintColor = tintColor

        accessibilityValue = isSelected ? .TabTrayToggleAccessibilityValueOn : .TabTrayToggleAccessibilityValueOff
    }
}

class CardStripButton: ToggleButton {
    var offTint = UIColor.label
    var onTint = UIColor.label.swappedForStyle

    override init(frame: CGRect) {
        super.init(frame: frame)
        accessibilityLabel = .TabTrayToggleAccessibilityLabel
        accessibilityHint = .TabTrayToggleAccessibilityHint
        let docImage = UIImage(named: "news")?.withRenderingMode(.alwaysTemplate)
        setImage(docImage, for: [])
        addTarget(self, action: #selector(toggleCardStripTapped), for: .touchUpInside)
        tintColor = offTint
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc func toggleCardStripTapped() {
        setSelected(!isSelected, animated: true)
        tintColor = isSelected ? onTint : offTint

        let cardStrip =
            BrowserViewController.foregroundBVC().cardStripViewController
        cardStrip?.cardStripHostingController?.view.isHidden = !isSelected
        BrowserViewController.foregroundBVC().view.bringSubviewToFront((cardStrip?.view)!)
    }
}

extension UIButton {
    static func newTabButton() -> UIButton {
        let newTab = UIButton()
        newTab.setImage(UIImage.templateImageNamed("quick_action_new_tab"), for: .normal)
        newTab.accessibilityLabel = .TabTrayButtonNewTabAccessibilityLabel
        return newTab
    }
}

extension TabsButton {
    static func tabTrayButton() -> TabsButton {
        let tabsButton = TabsButton()
        tabsButton.accessibilityLabel = .TabTrayButtonShowTabsAccessibilityLabel
        return tabsButton
    }
}
