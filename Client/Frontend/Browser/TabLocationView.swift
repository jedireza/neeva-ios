/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import UIKit
import Shared
import SnapKit
import XCGLogger
import NeevaSupport

private let log = Logger.browserLogger

protocol TabLocationViewDelegate {
    func tabLocationViewDidTapLocation(_ tabLocationView: TabLocationView)
    func tabLocationViewDidLongPressLocation(_ tabLocationView: TabLocationView)
    func tabLocationViewDidTapReload(_ tabLocationView: TabLocationView)
    func tabLocationViewDidTapShield(_ tabLocationView: TabLocationView)
    func tabLocationViewDidBeginDragInteraction(_ tabLocationView: TabLocationView)
    func tabLocationViewDidTabShareButton(_ tabLocationView: TabLocationView)

    func tabLocationViewReloadMenu(_ tabLocationView: TabLocationView) -> UIMenu?
    func tabLocationViewLocationAccessibilityActions(_ tabLocationView: TabLocationView) -> [UIAccessibilityCustomAction]?
}

private struct TabLocationViewUX {
    static let LockIconWidth: CGFloat = 16
    static let ShieldButtonWidth: CGFloat = 44
    static let ReloadButtonWidth: CGFloat = 44
    static let ShareButtonWidth: CGFloat = 46
    static let ButtonHeight: CGFloat = 36
    static let Spacer0Width: CGFloat = (ReloadButtonWidth - 14) / 2
}

class TabLocationView: UIView {
    var delegate: TabLocationViewDelegate?
    var longPressRecognizer: UILongPressGestureRecognizer!
    var tapRecognizer: UITapGestureRecognizer!
    var contentView: UIView!
    private var isPrivateMode: Bool = false

    fileprivate let menuBadge = BadgeWithBackdrop(imageName: "menuBadge", backdropCircleSize: 32)

    func showLockIcon(forSecureContent isSecure: Bool) {
        if url?.absoluteString == "about:blank" {
            // Matching the desktop behaviour, we don't mark these pages as secure.
            lockImageView.isHidden = true
            return
        }
        lockImageView.isHidden = !isSecure
    }

    func updateShareButton(_ isPage: Bool) {
        shareButton.isEnabled = isPage
    }

    var url: URL? {
        didSet {
            updateTextWithURL()
            let showSearchIcon = neevaSearchEngine.queryForSearchURL(url) == nil
            searchImageViews.0.isHidden = showSearchIcon
            searchImageViews.1.isHidden = showSearchIcon

            shieldButton.isHidden = !["https", "http"].contains(url?.scheme ?? "")
            setNeedsUpdateConstraints()
        }
    }

    lazy var placeholder: NSAttributedString = {
        return NSAttributedString(string: .TabLocationURLPlaceholder, attributes: [NSAttributedString.Key.foregroundColor: UIColor.Photon.Grey50])
    }()

    lazy var urlTextField: UITextField = {
        let urlTextField = DisplayTextField()

        // Prevent the field from compressing the toolbar buttons on the 4S in landscape.
        urlTextField.setContentCompressionResistancePriority(UILayoutPriority(rawValue: 250), for: .horizontal)
        urlTextField.accessibilityIdentifier = "url"
        urlTextField.accessibilityActionsSource = self
        urlTextField.font = UIConstants.DefaultChromeFont
        urlTextField.backgroundColor = .clear
        urlTextField.accessibilityLabel = "Address Bar"
        urlTextField.font = UIFont.preferredFont(forTextStyle: .body)
        urlTextField.adjustsFontForContentSizeCategory = true
        urlTextField.textAlignment = .center

        // Remove the default drop interaction from the URL text field so that our
        // custom drop interaction on the BVC can accept dropped URLs.
        if let dropInteraction = urlTextField.textDropInteraction {
            urlTextField.removeInteraction(dropInteraction)
        }

        return urlTextField
    }()

    fileprivate lazy var spacer0 = UIView()
    fileprivate lazy var spacer1 = UIView()
    fileprivate lazy var spacer2 = UIView()

    fileprivate lazy var lockImageView: UIImageView = {
        let lockImageView = UIImageView(image: UIImage.templateImageNamed("lock_verified"))
        lockImageView.isAccessibilityElement = true
        lockImageView.contentMode = .center
        lockImageView.accessibilityLabel = .TabLocationLockIconAccessibilityLabel
        lockImageView.tintColor = .black
        return lockImageView
    }()
    
    fileprivate lazy var searchImageViews: (UIView, UIImageView) = {
          let searchImageView = UIImageView(image: UIImage.templateImageNamed("search"))
          searchImageView.isAccessibilityElement = false
          searchImageView.contentMode = .scaleAspectFit
          let space10px = UIView()
          space10px.snp.makeConstraints { make in
              make.width.equalTo(10)
          }
          return (space10px, searchImageView)
    }()

    lazy var shieldButton: UIButton = {
        let shieldButton = UIButton()
        shieldButton.setImage(UIImage.templateImageNamed("tracking-protection"), for: .normal)
        shieldButton.addTarget(self, action: #selector(didPressTPShieldButton(_:)), for: .touchUpInside)
        shieldButton.tintColor = UIColor.Photon.Grey50
        shieldButton.imageView?.contentMode = .scaleAspectFill
        shieldButton.accessibilityIdentifier = "TabLocationView.shieldButton"
        return shieldButton
    }()

    lazy var reloadButton: ReloadButton = {
        let reloadButton = ReloadButton(frame: .zero, state: .disabled)
        reloadButton.addTarget(self, action: #selector(tapReloadButton), for: .touchUpInside)
        reloadButton.setDynamicMenu { self.delegate?.tabLocationViewReloadMenu(self) }
        reloadButton.tintColor = .black
        reloadButton.imageView?.contentMode = .scaleAspectFit
        reloadButton.accessibilityLabel = .TabLocationReloadAccessibilityLabel
        reloadButton.accessibilityIdentifier = "TabLocationView.reloadButton"
        reloadButton.isAccessibilityElement = true
        return reloadButton
    }()

    lazy var shareButton: UIButton = {
        let shareButton = UIButton()
        shareButton.setImage(UIImage(systemName: "square.and.arrow.up", withConfiguration: UIImage.SymbolConfiguration(pointSize: 16, weight: .medium)), for: .normal)
        shareButton.addTarget(self, action: #selector(tapShareButton), for: .touchUpInside)
        shareButton.accessibilityIdentifier = "TabLocationView.shareButton"
        shareButton.tintColor = .black
        shareButton.imageView?.contentMode = .scaleAspectFit
        return shareButton
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)

        register(self, forTabEvents: .didGainFocus, .didToggleDesktopMode, .didChangeContentBlocking)

        longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(longPressLocation))
        longPressRecognizer.delegate = self

        tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapLocation))
        tapRecognizer.delegate = self

        addGestureRecognizer(longPressRecognizer)
        addGestureRecognizer(tapRecognizer)

        let subviews = [spacer0, spacer1, lockImageView, urlTextField, spacer2, reloadButton, shieldButton, shareButton]

        contentView = UIView()
        for view in subviews {
            contentView.addSubview(view)
        }

        addSubview(contentView)

        contentView.snp.makeConstraints { make in
            make.edges.equalTo(self)
        }
        shieldButton.snp.makeConstraints { make in
            make.width.equalTo(TabLocationViewUX.ShieldButtonWidth)
            make.height.equalTo(TabLocationViewUX.ButtonHeight)
            make.leading.equalTo(self)
            make.trailing.equalTo(spacer0.snp.leading)
        }
        spacer0.snp.makeConstraints { make in
            make.leading.equalTo(shieldButton.snp.trailing)
            make.trailing.equalTo(spacer1.snp.leading)
            make.width.equalTo(TabLocationViewUX.Spacer0Width)
            make.height.equalTo(10)
        }
        spacer1.snp.makeConstraints { make in
            make.width.equalTo(spacer2)
            make.height.equalTo(10)
            make.leading.equalTo(spacer0.snp.trailing)
            make.trailing.equalTo(lockImageView.snp.leading)
        }
        lockImageView.snp.makeConstraints { make in
            make.width.equalTo(TabLocationViewUX.LockIconWidth)
            make.trailing.equalTo(urlTextField.snp.leading)
            make.centerY.equalTo(self)
        }
        urlTextField.snp.makeConstraints { make in
            make.width.equalTo(urlTextField.intrinsicContentSize.width)
            make.height.equalTo(urlTextField.intrinsicContentSize.height)
            make.centerY.equalTo(self)
        }
        spacer2.snp.makeConstraints { make in
            make.width.equalTo(spacer1)
            make.height.equalTo(10)
            make.leading.equalTo(urlTextField.snp.trailing)
        }
        reloadButton.snp.makeConstraints { make in
            make.width.equalTo(TabLocationViewUX.ReloadButtonWidth)
            make.height.equalTo(TabLocationViewUX.ButtonHeight)
            make.leading.equalTo(spacer2.snp.trailing)
        }
        shareButton.snp.makeConstraints { make in
            make.leading.equalTo(reloadButton.snp.trailing)
            make.trailing.equalTo(self)
            make.height.equalTo(TabLocationViewUX.ButtonHeight)
            make.width.equalTo(TabLocationViewUX.ShareButtonWidth)
        }

        // Setup UIDragInteraction to handle dragging the location
        // bar for dropping its URL into other apps.
        let dragInteraction = UIDragInteraction(delegate: self)
        dragInteraction.allowsSimultaneousRecognitionDuringLift = true
        self.addInteraction(dragInteraction)

        menuBadge.add(toParent: contentView)
        menuBadge.show(false)
    }

    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func updateConstraints() {
        // This spacer exists to balance out the padding of the reload button
        // (or the shield if somehow only it is visible).
        let currentURL = self.url?.absoluteString ?? ""
        if currentURL.isEmpty {
            spacer0.snp.updateConstraints { make in
                make.width.equalTo(TabLocationViewUX.Spacer0Width * 4)
            }
        } else {
            spacer0.snp.updateConstraints { make in
                make.width.equalTo(
                    reloadButton.isHidden && shieldButton.isHidden ? 0 : TabLocationViewUX.Spacer0Width)
            }
        }

        lockImageView.snp.updateConstraints { make in
            make.width.equalTo(
                lockImageView.isHidden ? 0 : TabLocationViewUX.LockIconWidth)
        }
        urlTextField.snp.updateConstraints { make in
            make.width.equalTo(urlTextField.intrinsicContentSize.width)
        }
        reloadButton.snp.updateConstraints { make in
            make.width.equalTo(
                reloadButton.isHidden ? 0 : TabLocationViewUX.ReloadButtonWidth)
        }
        shieldButton.snp.updateConstraints { make in
            make.width.equalTo(
                shieldButton.isHidden ? 0 : TabLocationViewUX.ShieldButtonWidth)
        }
        shareButton.snp.updateConstraints { make in
            make.width.equalTo(
                shareButton.isHidden ? 0 : TabLocationViewUX.ShareButtonWidth
            )
        }
        super.updateConstraints()
    }

    private lazy var _accessibilityElements = [urlTextField, reloadButton, shieldButton, shareButton]

    override var accessibilityElements: [Any]? {
        get {
            return _accessibilityElements.filter { !$0.isHidden }
        }
        set {
            super.accessibilityElements = newValue
        }
    }

    func overrideAccessibility(enabled: Bool) {
        _accessibilityElements.forEach {
            $0.isAccessibilityElement = enabled
        }
    }

    @objc func tapReloadButton() {
        delegate?.tabLocationViewDidTapReload(self)
    }

    @objc func tapShareButton() {
        delegate?.tabLocationViewDidTabShareButton(self)
    }

    @objc func longPressLocation(_ recognizer: UITapGestureRecognizer) {
        if recognizer.state == .began {
            delegate?.tabLocationViewDidLongPressLocation(self)
        }
    }

    @objc func tapLocation(_ recognizer: UITapGestureRecognizer) {
        delegate?.tabLocationViewDidTapLocation(self)
    }

    @objc func didPressTPShieldButton(_ button: UIButton) {
        delegate?.tabLocationViewDidTapShield(self)
    }

    fileprivate func updateTextWithURL() {
        if let scheme = url?.scheme, let host = url?.host, (scheme == "https" || scheme == "http") {
            urlTextField.text = host
        } else {
            urlTextField.text = url?.absoluteString
        }
        // NOTE: Punycode support was removed
        if let query = neevaSearchEngine.queryForSearchURL(url) {
            urlTextField.text = query
        }
        if let text = urlTextField.text, !text.isEmpty {
            urlTextField.attributedPlaceholder = nil
        } else {
            urlTextField.attributedPlaceholder = self.placeholder
        }
        setNeedsUpdateConstraints()
    }
}

extension TabLocationView: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        // When long pressing a button make sure the textfield's long press gesture is not triggered
        return !(otherGestureRecognizer.view is UIButton)
    }

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        // If the longPressRecognizer is active, fail the tap recognizer to avoid conflicts.
        return gestureRecognizer == longPressRecognizer && otherGestureRecognizer == tapRecognizer
    }
}

@available(iOS 11.0, *)
extension TabLocationView: UIDragInteractionDelegate {
    func dragInteraction(_ interaction: UIDragInteraction, itemsForBeginning session: UIDragSession) -> [UIDragItem] {
        // Ensure we actually have a URL in the location bar and that the URL is not local.
        guard let url = self.url, !InternalURL.isValid(url: url), let itemProvider = NSItemProvider(contentsOf: url) else {
            return []
        }

        TelemetryWrapper.recordEvent(category: .action, method: .drag, object: .locationBar)

        let dragItem = UIDragItem(itemProvider: itemProvider)
        return [dragItem]
    }

    func dragInteraction(_ interaction: UIDragInteraction, sessionWillBegin session: UIDragSession) {
        delegate?.tabLocationViewDidBeginDragInteraction(self)
    }
}

extension TabLocationView: AccessibilityActionsSource {
    func accessibilityCustomActionsForView(_ view: UIView) -> [UIAccessibilityCustomAction]? {
        if view === urlTextField {
            return delegate?.tabLocationViewLocationAccessibilityActions(self)
        }
        return nil
    }
}

extension TabLocationView: PrivateModeUI {
    func applyUIMode(isPrivate: Bool) {
        self.isPrivateMode = isPrivate

        let background = UIColor.TextField.background(isPrivate: isPrivateMode)
        let textAndTint = UIColor.TextField.textAndTint(isPrivate: isPrivateMode)

        backgroundColor = background
        urlTextField.textColor = textAndTint
        lockImageView.tintColor = textAndTint
        reloadButton.tintColor = textAndTint
        shieldButton.tintColor = textAndTint
        shareButton.tintColor = textAndTint

        if isPrivateMode {
            shieldButton.setImage(UIImage.templateImageNamed("incognito"), for: .normal)
        } else {
            shieldButton.setImage(UIImage.templateImageNamed("tracking-protection"), for: .normal)
        }

        let color = ThemeManager.instance.currentName == .dark ?
            UIColor(white: 0.3, alpha: 0.6) :
            background
        menuBadge.badge.tintBackground(color: color)
    }
}

extension TabLocationView: TabEventHandler {
    func tabDidChangeContentBlocking(_ tab: Tab) {
        updateBlockerStatus(forTab: tab)
    }

    private func updateBlockerStatus(forTab tab: Tab) {
        assertIsMainThread("UI changes must be on the main thread")
        guard let blocker = tab.contentBlocker else { return }
        shieldButton.alpha = 1.0
        switch blocker.status {
        case .blocking, .noBlockedURLs, .safelisted:
            shieldButton.tintColor = UIColor.TextField.textAndTint(isPrivate: isPrivateMode)
            break
        case .disabled:
            shieldButton.tintColor = UIColor.TextField.disabledTextAndTint(isPrivate: isPrivateMode)
            break
        }
    }

    func tabDidGainFocus(_ tab: Tab) {
        updateBlockerStatus(forTab: tab)
        menuBadge.show(tab.changedUserAgent)
    }

    func tabDidToggleDesktopMode(_ tab: Tab) {
        menuBadge.show(tab.changedUserAgent)
    }
}

enum ReloadButtonState: String {
    case reload = "Reload"
    case stop = "Stop"
    case disabled = "Disabled"
}

class ReloadButton: UIButton {
    convenience init(frame: CGRect, state: ReloadButtonState) {
        self.init(frame: frame)
        reloadButtonState = state
    }

    required override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private var _reloadButtonState = ReloadButtonState.disabled
    
    var reloadButtonState: ReloadButtonState {
        get {
            return _reloadButtonState
        }
        set (newReloadButtonState) {
            _reloadButtonState = newReloadButtonState
            
            let configuration = UIImage.SymbolConfiguration(weight: .medium)
            switch _reloadButtonState {
            case .reload:
                self.isHidden = false
                setImage(UIImage(systemName: "arrow.clockwise", withConfiguration: configuration), for: .normal)
            case .stop:
                self.isHidden = false
                setImage(UIImage(systemName: "xmark", withConfiguration: configuration), for: .normal)
            case .disabled:
                self.isHidden = true
            }
        }
    }
}

private class DisplayTextField: UITextField {
    weak var accessibilityActionsSource: AccessibilityActionsSource?

    override var accessibilityCustomActions: [UIAccessibilityCustomAction]? {
        get {
            return accessibilityActionsSource?.accessibilityCustomActionsForView(self)
        }
        set {
            super.accessibilityCustomActions = newValue
        }
    }

    fileprivate override var canBecomeFirstResponder: Bool {
        return false
    }
}
