/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import UIKit
import SnapKit
import Shared
import Combine

protocol LegacyTabToolbarProtocol: AnyObject {
    var tabToolbarDelegate: TabToolbarDelegate? { get set }
    var tabsButton: TabsButton { get }
    var addToSpacesButton: ToolbarButton { get }
    var forwardButton: ToolbarButton { get }
    var backButton: ToolbarButton { get }
    var shareButton: ToolbarButton { get }
    var toolbarNeevaMenuButton: ToolbarButton { get }
    var actionButtons: [ToolbarButton] { get }
    var isPrivateMode: Bool { get }
}

protocol TabToolbarDelegate: AnyObject {
    func tabToolbarDidPressBack()
    func tabToolbarDidPressForward()
    func tabToolbarDidLongPressBackForward()
    func tabToolbarSpacesMenu()
    func tabToolbarDidPressTabs()
    func tabToolbarTabsMenu() -> UIMenu?
}

@objcMembers
open class LegacyTabToolbarHelper: NSObject {
    let toolbar: LegacyTabToolbarProtocol

    let menuActionID = UIAction.Identifier("UpdateMenu")

    init(toolbar: LegacyTabToolbarProtocol) {
        self.toolbar = toolbar
        super.init()

        let configuration = UIImage.SymbolConfiguration(pointSize: 20, weight: .medium)

        toolbar.backButton.setImage(UIImage(systemName: "arrow.left", withConfiguration: configuration), for: .normal)
        toolbar.backButton.accessibilityLabel = .TabToolbarBackAccessibilityLabel
        let longPressGestureBackButton = UILongPressGestureRecognizer(target: self, action: #selector(didLongPressBackForward))
        toolbar.backButton.addGestureRecognizer(longPressGestureBackButton)
        toolbar.backButton.addTarget(self, action: #selector(didClickBack), for: .touchUpInside)
        toolbar.backButton.isPointerInteractionEnabled = true

        toolbar.forwardButton.setImage(UIImage(systemName: "arrow.right", withConfiguration: configuration), for: .normal)
        toolbar.forwardButton.accessibilityLabel = .TabToolbarForwardAccessibilityLabel
        let longPressGestureForwardButton = UILongPressGestureRecognizer(target: self, action: #selector(didLongPressBackForward))
        toolbar.forwardButton.addGestureRecognizer(longPressGestureForwardButton)
        toolbar.forwardButton.addTarget(self, action: #selector(didClickForward), for: .touchUpInside)
        toolbar.forwardButton.isPointerInteractionEnabled = true
        
        toolbar.shareButton.setImage(UIImage(systemName: "square.and.arrow.up", withConfiguration: configuration), for: .normal)
        toolbar.shareButton.accessibilityLabel = "Share Menu"
        toolbar.shareButton.addAction(UIAction { _ in
            self.didPress(shareButton: toolbar.shareButton)
        }, for: .primaryActionTriggered)
        toolbar.shareButton.isPointerInteractionEnabled = true

        toolbar.tabsButton.accessibilityLabel = .TabTrayButtonShowTabsAccessibilityLabel
        toolbar.tabsButton.addTarget(self, action: #selector(didClickTabs), for: .touchUpInside)
        toolbar.tabsButton.setDynamicMenu {
            toolbar.tabToolbarDelegate?.tabToolbarTabsMenu()
        }
        toolbar.tabsButton.isPointerInteractionEnabled = true
        
        toolbar.addToSpacesButton.titleLabel?.font = UIFont(name: NiconFont.medium.rawValue, size: 19.17);
        toolbar.addToSpacesButton.setTitle(String(Nicon.bookmark.rawValue), for: .normal)
        toolbar.addToSpacesButton.contentMode = .center
        toolbar.addToSpacesButton.accessibilityLabel = "Add To Space"
        toolbar.addToSpacesButton.accessibilityIdentifier = "TabToolbar.addToSpacesButton"
        toolbar.addToSpacesButton.addTarget(self, action: #selector(didClickSpaces), for: .touchUpInside)
        toolbar.addToSpacesButton.isPointerInteractionEnabled = true

        toolbar.toolbarNeevaMenuButton.setImage(UIImage.originalImageNamed("neevaMenuIcon"), for: .normal)
        toolbar.toolbarNeevaMenuButton.accessibilityLabel = "Neeva Menu"
        toolbar.toolbarNeevaMenuButton.addTarget(self, action: #selector(didPressToolbarNeevaMenu), for: .touchUpInside)
        toolbar.toolbarNeevaMenuButton.isPointerInteractionEnabled = true
    }

    func didPressToolbarNeevaMenu () {
        BrowserViewController.foregroundBVC().showNeevaMenuSheet()
    }

    func didPress(shareButton: UIView) {
        ClientLogger.shared.logCounter(.ClickShareButton, attributes: EnvironmentHelper.shared.getAttributes())
        guard
            let bvc = toolbar.tabToolbarDelegate as? BrowserViewController,
            let tab = bvc.tabManager.selectedTab,
            let url = tab.url
        else { return }
        if url.isFileURL {
            bvc.share(fileURL: url, buttonView: shareButton, presentableVC: bvc)
        } else {
            bvc.share(tab: tab, from: shareButton, presentableVC: bvc)
        }
    }

    func didClickSpaces() {
        ClientLogger.shared.logCounter(.SaveToSpace, attributes: EnvironmentHelper.shared.getAttributes())
        toolbar.tabToolbarDelegate?.tabToolbarSpacesMenu()
    }

    func didClickBack() {
        ClientLogger.shared.logCounter(.ClickBack, attributes: EnvironmentHelper.shared.getAttributes())
        toolbar.tabToolbarDelegate?.tabToolbarDidPressBack()
    }

    func didLongPressBackForward(_ recognizer: UILongPressGestureRecognizer) {
        if recognizer.state == .began {
            toolbar.tabToolbarDelegate?.tabToolbarDidLongPressBackForward()
        }
    }

    func didClickTabs() {
        ClientLogger.shared.logCounter(.ClickNewTabButton, attributes: EnvironmentHelper.shared.getAttributes())
        toolbar.tabToolbarDelegate?.tabToolbarDidPressTabs()
    }

    func didClickForward() {
        ClientLogger.shared.logCounter(.ClickForward, attributes: EnvironmentHelper.shared.getAttributes())
        toolbar.tabToolbarDelegate?.tabToolbarDidPressForward()
    }

    func subscribe(to model: TabToolbarModel) -> Set<AnyCancellable> {
        [
            model.$canGoBack.sink { [weak toolbar] in toolbar?.backButton.isEnabled = $0 },
            model.$canGoForward.sink { [weak toolbar] in toolbar?.forwardButton.isEnabled = $0 },
            model.$isPage.sink { [weak toolbar] isWebPage in
                if let toolbar = toolbar {
                    toolbar.shareButton.isEnabled = isWebPage
                    toolbar.addToSpacesButton.isEnabled = isWebPage && !toolbar.isPrivateMode
                }
            },
        ]
    }
}

class ToolbarButton: UIButton {
    var selectedTintColor: UIColor!
    var unselectedTintColor: UIColor!
    var disabledTintColor: UIColor!

    // Optionally can associate a separator line that hide/shows along with the button
    weak var separatorLine: UIView?

    override init(frame: CGRect) {
        super.init(frame: frame)
        adjustsImageWhenDisabled = false
        adjustsImageWhenHighlighted = false
        imageView?.contentMode = .scaleAspectFit
        selectedTintColor = UIColor.ToolbarButton.selectedTint
        disabledTintColor = UIColor.ToolbarButton.disabledTint
        unselectedTintColor = UIColor.Browser.tint
        tintColor = isEnabled ? unselectedTintColor : disabledTintColor
        imageView?.tintColor = tintColor
        setTitleColor(unselectedTintColor, for: .normal)
        setTitleColor(disabledTintColor, for: .disabled)
        setTitleColor(selectedTintColor, for: .highlighted)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override open var isHighlighted: Bool {
        didSet {
            self.tintColor = isHighlighted ? selectedTintColor : unselectedTintColor
        }
    }

    override open var isEnabled: Bool {
        didSet {
            self.tintColor = isEnabled ? unselectedTintColor : disabledTintColor
        }
    }

    override var tintColor: UIColor! {
        didSet {
            self.imageView?.tintColor = self.tintColor
        }
    }

    override var isHidden: Bool {
        didSet {
            separatorLine?.isHidden = isHidden
        }
    }
}
