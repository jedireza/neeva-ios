/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import NeevaSupport
import UIKit
import SnapKit
import Shared
import NeevaSupport

protocol TabToolbarProtocol: AnyObject {
    var tabToolbarDelegate: TabToolbarDelegate? { get set }
    var tabsButton: TabsButton { get }
    var addToSpacesButton: ToolbarButton { get }
    var forwardButton: ToolbarButton { get }
    var backButton: ToolbarButton { get }
    var shareButton: ToolbarButton { get }
    var toolbarNeevaMenuButton: ToolbarButton { get }
    var actionButtons: [ToolbarButton] { get }

    func updateBackStatus(_ canGoBack: Bool)
    func updateForwardStatus(_ canGoForward: Bool)
    func updatePageStatus(_ isWebPage: Bool)
    func appMenuBadge(setVisible: Bool)
    func warningMenuBadge(setVisible: Bool)
}

protocol TabToolbarDelegate: AnyObject {
    func tabToolbarDidPressBack(_ tabToolbar: TabToolbarProtocol, button: UIButton)
    func tabToolbarDidPressForward(_ tabToolbar: TabToolbarProtocol, button: UIButton)
    func tabToolbarDidLongPressBack(_ tabToolbar: TabToolbarProtocol, button: UIButton)
    func tabToolbarDidLongPressForward(_ tabToolbar: TabToolbarProtocol, button: UIButton)
    func tabToolbarDidPressReload(_ tabToolbar: TabToolbarProtocol, button: UIButton)
    func tabToolbarReloadMenu(_ tabToolbar: TabToolbarProtocol, button: UIButton) -> UIMenu?
    func tabToolbarDidPressStop(_ tabToolbar: TabToolbarProtocol, button: UIButton)
    func tabToolbarSpacesMenu(_ tabToolbar: TabToolbarProtocol, button: UIButton)
    func tabToolbarDidPressTabs(_ tabToolbar: TabToolbarProtocol, button: UIButton)
    func tabToolbarTabsMenu(_ tabToolbar: TabToolbarProtocol, button: UIButton) -> UIMenu?
    func tabToolbarDidPressSearch(_ tabToolbar: TabToolbarProtocol, button: UIButton)
    func tabToolbarDidPressAddNewTab(_ tabToolbar: TabToolbarProtocol, button: UIButton)
}

@objcMembers
open class TabToolbarHelper: NSObject {
    let toolbar: TabToolbarProtocol
    let ImageReload = UIImage.templateImageNamed("nav-refresh")
    let ImageStop = UIImage.templateImageNamed("nav-stop")
    let ImageSearch = UIImage.templateImageNamed("search")
    let ImageNewTab = UIImage.templateImageNamed("nav-add")

    let menuActionID = UIAction.Identifier("UpdateMenu")

    init(toolbar: TabToolbarProtocol) {
        self.toolbar = toolbar
        super.init()

        let configuration = UIImage.SymbolConfiguration(pointSize: 20, weight: .medium)

        toolbar.backButton.setImage(UIImage(systemName: "arrow.left", withConfiguration: configuration), for: .normal)
        toolbar.backButton.accessibilityLabel = .TabToolbarBackAccessibilityLabel
        let longPressGestureBackButton = UILongPressGestureRecognizer(target: self, action: #selector(didLongPressBack))
        toolbar.backButton.addGestureRecognizer(longPressGestureBackButton)
        toolbar.backButton.addTarget(self, action: #selector(didClickBack), for: .touchUpInside)

        toolbar.forwardButton.setImage(UIImage(systemName: "arrow.right", withConfiguration: configuration), for: .normal)
        toolbar.forwardButton.accessibilityLabel = .TabToolbarForwardAccessibilityLabel
        let longPressGestureForwardButton = UILongPressGestureRecognizer(target: self, action: #selector(didLongPressForward))
        toolbar.forwardButton.addGestureRecognizer(longPressGestureForwardButton)
        toolbar.forwardButton.addTarget(self, action: #selector(didClickForward), for: .touchUpInside)

        toolbar.shareButton.setImage(UIImage(systemName: "square.and.arrow.up", withConfiguration: configuration), for: .normal)
        toolbar.shareButton.accessibilityLabel = NSLocalizedString("Share", comment: "Accessibility Label for the tab toolbar Share button")
        toolbar.shareButton.addAction(UIAction { _ in
            self.didPressShareButton()
        }, for: .primaryActionTriggered)

        toolbar.tabsButton.accessibilityLabel = .TabTrayButtonShowTabsAccessibilityLabel
        toolbar.tabsButton.addTarget(self, action: #selector(didClickTabs), for: .touchUpInside)
        toolbar.tabsButton.setDynamicMenu {
            toolbar.tabToolbarDelegate?.tabToolbarTabsMenu(toolbar, button: toolbar.tabsButton)
        }
        
        toolbar.addToSpacesButton.titleLabel?.font = UIFont(name: NiconFont.medium.rawValue, size: 19.17);
        toolbar.addToSpacesButton.setTitle(String(Nicon.bookmark.rawValue), for: .normal)
        toolbar.addToSpacesButton.contentMode = .center
        toolbar.addToSpacesButton.accessibilityLabel = Strings.AppMenuButtonAccessibilityLabel
        toolbar.addToSpacesButton.accessibilityIdentifier = "TabToolbar.addToSpacesButton"
        toolbar.addToSpacesButton.addTarget(self, action: #selector(didClickSpaces), for: .touchUpInside)

    
        toolbar.toolbarNeevaMenuButton.setImage(UIImage.originalImageNamed("neevaMenuIcon"), for: .normal)
        toolbar.toolbarNeevaMenuButton.accessibilityIdentifier = "TabToolbar.neevaMenuButton"
        toolbar.toolbarNeevaMenuButton.addTarget(self, action: #selector(didPressToolbarNeevaMenu), for: .touchUpInside)
    }

    func didPressToolbarNeevaMenu () {
        BrowserViewController.foregroundBVC().showNeevaMenuSheet()
    }

    func didPressShareButton () {
        ClientLogger.shared.logCounter(.ClickShareButton, attributes: EnvironmentHelper.shared.getAttributes())
        guard
            let bvc = toolbar.tabToolbarDelegate as? BrowserViewController,
            let tab = bvc.tabManager.selectedTab,
            let url = tab.url
        else { return }
        if url.isFileURL {
            bvc.share(fileURL: url, buttonView: toolbar.shareButton, presentableVC: bvc)
        } else {
            bvc.share(tab: tab, from: toolbar.shareButton, presentableVC: bvc)
        }
    }

    func didClickSpaces() {
        ClientLogger.shared.logCounter(.SaveToSpace, attributes: EnvironmentHelper.shared.getAttributes())
        toolbar.tabToolbarDelegate?.tabToolbarSpacesMenu(toolbar, button: toolbar.addToSpacesButton)
    }

    func didClickBack() {
        ClientLogger.shared.logCounter(.ClickBack, attributes: EnvironmentHelper.shared.getAttributes())
        toolbar.tabToolbarDelegate?.tabToolbarDidPressBack(toolbar, button: toolbar.backButton)
    }

    func didLongPressBack(_ recognizer: UILongPressGestureRecognizer) {
        if recognizer.state == .began {
            toolbar.tabToolbarDelegate?.tabToolbarDidLongPressBack(toolbar, button: toolbar.backButton)
        }
    }

    func didClickTabs() {
        ClientLogger.shared.logCounter(.ClickNewTabButton, attributes: EnvironmentHelper.shared.getAttributes())
        toolbar.tabToolbarDelegate?.tabToolbarDidPressTabs(toolbar, button: toolbar.tabsButton)
    }

    func didClickForward() {
        ClientLogger.shared.logCounter(.ClickForward, attributes: EnvironmentHelper.shared.getAttributes())
        toolbar.tabToolbarDelegate?.tabToolbarDidPressForward(toolbar, button: toolbar.forwardButton)
    }

    func didLongPressForward(_ recognizer: UILongPressGestureRecognizer) {
        if recognizer.state == .began {
            toolbar.tabToolbarDelegate?.tabToolbarDidLongPressForward(toolbar, button: toolbar.forwardButton)
        }
    }
}

class ToolbarButton: UIButton {
    var selectedTintColor: UIColor!
    var unselectedTintColor: UIColor!
    var disabledTintColor = UIColor.Photon.Grey50

    // Optionally can associate a separator line that hide/shows along with the button
    weak var separatorLine: UIView?

    override init(frame: CGRect) {
        super.init(frame: frame)
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

extension ToolbarButton {
    func configTint() {
    }
}

class TabToolbar: UIView {
    weak var tabToolbarDelegate: TabToolbarDelegate?

    let tabsButton = TabsButton()
    let addToSpacesButton = ToolbarButton()
    let forwardButton = ToolbarButton()
    let backButton = ToolbarButton()
    let shareButton = ToolbarButton()
    let toolbarNeevaMenuButton = ToolbarButton()
    let actionButtons: [ToolbarButton]

    fileprivate let appMenuBadge = BadgeWithBackdrop(imageName: "menuBadge")
    fileprivate let warningMenuBadge = BadgeWithBackdrop(imageName: "menuWarning", imageMask: "warning-mask")

    private var isPrivateMode: Bool = false

    private var neevaMenuIcon = UIImage.originalImageNamed("neevaMenuIcon")

    var helper: TabToolbarHelper?
    private let contentView = UIStackView()

    fileprivate override init(frame: CGRect) {
        actionButtons = [backButton, forwardButton, toolbarNeevaMenuButton, addToSpacesButton]

        super.init(frame: frame)
        setupAccessibility()

        addSubview(contentView)
        helper = TabToolbarHelper(toolbar: self)
        addButtons(actionButtons)
        contentView.addArrangedSubview(tabsButton)


        appMenuBadge.add(toParent: contentView)
        warningMenuBadge.add(toParent: contentView)

        contentView.axis = .horizontal
        contentView.distribution = .fillEqually
    }

    override func updateConstraints() {
        appMenuBadge.layout(onButton: addToSpacesButton)
        warningMenuBadge.layout(onButton: addToSpacesButton)

        contentView.snp.makeConstraints { make in
            make.leading.trailing.top.equalTo(self)
            make.bottom.equalTo(self.safeArea.bottom)
        }
        super.updateConstraints()
    }

    private func setupAccessibility() {
        backButton.accessibilityIdentifier = "TabToolbar.backButton"
        forwardButton.accessibilityIdentifier = "TabToolbar.forwardButton"
        shareButton.accessibilityIdentifier = "TabToolbar.shareButton"
        tabsButton.accessibilityIdentifier = "TabToolbar.tabsButton"
        toolbarNeevaMenuButton.accessibilityIdentifier = "TabToolbar.toolbarNeevaMenuButton"
        addToSpacesButton.accessibilityIdentifier = "TabToolbar.addToSpacesButton"
        accessibilityNavigationStyle = .combined
        accessibilityLabel = .TabToolbarNavigationToolbarAccessibilityLabel
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func addButtons(_ buttons: [UIButton]) {
        buttons.forEach { contentView.addArrangedSubview($0) }
    }

    override func draw(_ rect: CGRect) {
        if let context = UIGraphicsGetCurrentContext() {
            drawLine(context, start: .zero, end: CGPoint(x: frame.width, y: 0))
        }
    }

    fileprivate func drawLine(_ context: CGContext, start: CGPoint, end: CGPoint) {
        context.setStrokeColor(UIColor.black.withAlphaComponent(0.05).cgColor)
        context.setLineWidth(2)
        context.move(to: CGPoint(x: start.x, y: start.y))
        context.addLine(to: CGPoint(x: end.x, y: end.y))
        context.strokePath()
    }
}

extension TabToolbar: TabToolbarProtocol {
    func appMenuBadge(setVisible: Bool) {
        // Warning badges should take priority over the standard badge
        guard warningMenuBadge.badge.isHidden else {
            return
        }

        appMenuBadge.show(setVisible)
    }

    func warningMenuBadge(setVisible: Bool) {
        // Disable other menu badges before showing the warning.
        if !appMenuBadge.badge.isHidden { appMenuBadge.show(false) }
        warningMenuBadge.show(setVisible)
    }

    func updateBackStatus(_ canGoBack: Bool) {
        backButton.isEnabled = canGoBack
    }

    func updateForwardStatus(_ canGoForward: Bool) {
        forwardButton.isEnabled = canGoForward
    }

    func updatePageStatus(_ isWebPage: Bool) {
        shareButton.isEnabled = isWebPage
        addToSpacesButton.isEnabled = isWebPage && !isPrivateMode
    }
}

extension TabToolbar: PrivateModeUI {
    func applyUIMode(isPrivate: Bool) {
        isPrivateMode = isPrivate

        if isPrivate {
            toolbarNeevaMenuButton.setImage(neevaMenuIcon?.withRenderingMode(.alwaysTemplate), for: .normal)
        } else {
            toolbarNeevaMenuButton.setImage(neevaMenuIcon, for: .normal)
        }

        backgroundColor = UIColor.Browser.background

        appMenuBadge.badge.tintBackground(color: UIColor.Browser.background)
        warningMenuBadge.badge.tintBackground(color: UIColor.Browser.background)
        toolbarNeevaMenuButton.tintColor = UIColor.URLBar.neevaMenuTint(isPrivateMode)
    }
}
