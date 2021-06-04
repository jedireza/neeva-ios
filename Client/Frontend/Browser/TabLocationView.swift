/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import UIKit
import Shared
import SnapKit

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
    static let ButtonWidth: CGFloat = 44
    static let ButtonHeight: CGFloat = 42
    static let IconPadding: CGFloat = -8
}

let EllipsePointerStyleProvider: UIButton.PointerStyleProvider = { button, effect, style in
    UIPointerStyle(effect: effect, shape: .path(UIBezierPath(ovalIn: button.bounds)))
}

class TabLocationView: UIView {
    var delegate: TabLocationViewDelegate?
    var longPressRecognizer: UILongPressGestureRecognizer!
    var tapRecognizer: UITapGestureRecognizer!
    var contentView: UIView!
    private var isPrivateMode: Bool = false

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
            // Report the URL as the accessible value rather than the display text.
            urlLabel.accessibilityValue = url?.absoluteString ?? ""
            updateTextWithURL()
            shieldButton.isHidden = !["https", "http"].contains(url?.scheme ?? "")
            setNeedsUpdateConstraints()
        }
    }

    private var urlLabelTextIsPlaceholder: Bool = false

    // If the URL corresponds to a search, then we extract and display the query.
    var displayText: String {
        urlLabelTextIsPlaceholder ? "" : urlLabel.text ?? ""
    }
    var displayTextIsQuery: Bool = false

    lazy var urlLabel: UILabel = {
        let label = DisplayTextLabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .label
        label.lineBreakMode = .byTruncatingHead
        label.numberOfLines = 1
        label.textAlignment = .left
        label.isAccessibilityElement = true
        label.accessibilityIdentifier = "url"
        label.accessibilityLabel = "Address Bar"
        label.accessibilityHint = .TabLocationURLPlaceholder
        label.accessibilityTraits = .button
        label.accessibilityRespondsToUserInteraction = true
        label.accessibilityActionsSource = self
        label.isUserInteractionEnabled = true  // Needed for KIF-based tests
        return label
    }()

    fileprivate lazy var lockImageView: UIImageView = {
        let lockImageView = UIImageView(image: UIImage(systemName: "lock.fill"))
        lockImageView.isAccessibilityElement = true
        lockImageView.contentMode = .center
        lockImageView.accessibilityLabel = .TabLocationLockIconAccessibilityLabel
        lockImageView.tintColor = .black
        return lockImageView
    }()

    fileprivate lazy var lockAndText = UIView()
    
    lazy var shieldButton: UIButton = {
        let shieldButton = UIButton()
        shieldButton.setImage(UIImage.templateImageNamed("tracking-protection"), for: .normal)
        shieldButton.addTarget(self, action: #selector(didPressTPShieldButton(_:)), for: .touchUpInside)
        shieldButton.tintColor = UIColor.Photon.Grey50
        shieldButton.imageView?.contentMode = .scaleAspectFill
        shieldButton.accessibilityIdentifier = "TabLocationView.shieldButton"
        shieldButton.pointerStyleProvider = EllipsePointerStyleProvider
        return shieldButton
    }()

    lazy var reloadButton: ReloadButton = {
        let reloadButton = ReloadButton(frame: .zero, state: .reload)
        reloadButton.addTarget(self, action: #selector(tapReloadButton), for: .touchUpInside)
        reloadButton.setDynamicMenu { self.delegate?.tabLocationViewReloadMenu(self) }
        reloadButton.tintColor = .black
        reloadButton.imageView?.contentMode = .scaleAspectFit
        reloadButton.accessibilityLabel = .TabLocationReloadAccessibilityLabel
        reloadButton.accessibilityIdentifier = "TabLocationView.reloadButton"
        reloadButton.isAccessibilityElement = true
        reloadButton.isPointerInteractionEnabled = true
        reloadButton.pointerStyleProvider = EllipsePointerStyleProvider
        return reloadButton
    }()

    private lazy var shareButton: UIButton = {
        let shareButton = UIButton()
        shareButton.setImage(UIImage(systemName: "square.and.arrow.up", withConfiguration: UIImage.SymbolConfiguration(pointSize: 16, weight: .medium)), for: .normal)
        shareButton.addTarget(self, action: #selector(tapShareButton), for: .touchUpInside)
        shareButton.accessibilityIdentifier = "TabLocationView.shareButton"
        shareButton.isAccessibilityElement = true
        shareButton.tintColor = .black
        shareButton.imageView?.contentMode = .scaleAspectFit
        shareButton.pointerStyleProvider = EllipsePointerStyleProvider
        return shareButton
    }()

    var showShareButton: Bool = true {
        didSet {
            shareButton.isHidden = !showShareButton
            setNeedsUpdateConstraints()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)

        register(self, forTabEvents: .didGainFocus, .didToggleDesktopMode, .didChangeContentBlocking)

        longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(longPressLocation))
        longPressRecognizer.delegate = self

        tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapLocation))
        tapRecognizer.delegate = self

        addGestureRecognizer(longPressRecognizer)
        addGestureRecognizer(tapRecognizer)

        lockAndText.addSubview(lockImageView)
        lockAndText.addSubview(urlLabel)

        let subviews = [shieldButton, lockAndText, reloadButton, shareButton]

        contentView = UIView()
        for view in subviews {
            contentView.addSubview(view)
        }

        addSubview(contentView)

        contentView.snp.makeConstraints { make in
            make.edges.equalTo(self)
        }

        lockImageView.snp.makeConstraints { make in
            make.width.equalTo(TabLocationViewUX.LockIconWidth)
            make.leading.equalTo(lockAndText.snp.leading).priority(.high)
            make.leading.greaterThanOrEqualTo(shieldButton.snp.trailing).priority(.high)
            make.trailing.equalTo(urlLabel.snp.leading).priority(.high)
            make.centerY.equalTo(self)
        }
        urlLabel.snp.makeConstraints { make in
            make.centerY.equalTo(self)
            make.trailing.equalTo(lockAndText.snp.trailing)
            make.trailing.lessThanOrEqualTo(reloadButton.snp.leading).priority(.high)
            // In case lockImageView is hidden:
            make.leading.greaterThanOrEqualTo(shieldButton.snp.trailing).priority(.high)
        }

        shieldButton.snp.makeConstraints { make in
            make.centerY.equalTo(self)
            make.width.equalTo(TabLocationViewUX.ButtonWidth)
            make.height.equalTo(TabLocationViewUX.ButtonHeight)
            make.leading.equalTo(self)
        }

        lockAndText.snp.makeConstraints { make in
            make.centerX.equalTo(self.snp.centerX).priority(.medium)
            make.centerY.equalTo(self)
            make.height.equalTo(TabLocationViewUX.ButtonHeight)
            make.leading.greaterThanOrEqualTo(shieldButton.snp.trailing).priority(.high)
            make.trailing.lessThanOrEqualTo(reloadButton.snp.leading).priority(.high)
        }

        reloadButton.snp.makeConstraints { make in
            make.centerY.equalTo(self)
            make.width.equalTo(TabLocationViewUX.ButtonWidth)
            make.height.equalTo(TabLocationViewUX.ButtonHeight)
        }
        shareButton.snp.makeConstraints { make in
            make.centerY.equalTo(self)
            make.leading.equalTo(reloadButton.snp.trailing)
            make.trailing.equalTo(self)
            make.height.equalTo(TabLocationViewUX.ButtonHeight)
            make.width.equalTo(TabLocationViewUX.ButtonWidth)
        }

        // Setup UIDragInteraction to handle dragging the location
        // bar for dropping its URL into other apps.
        let dragInteraction = UIDragInteraction(delegate: self)
        dragInteraction.allowsSimultaneousRecognitionDuringLift = true
        self.addInteraction(dragInteraction)
    }

    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func updateConstraints() {
        lockImageView.snp.updateConstraints { make in
            make.width.equalTo(
                lockImageView.isHidden ? 0 : TabLocationViewUX.LockIconWidth)
        }
        reloadButton.snp.updateConstraints { make in
            make.width.equalTo(
                reloadButton.isHidden ? 0 : TabLocationViewUX.ButtonWidth)
        }
        shieldButton.snp.updateConstraints { make in
            make.width.equalTo(
                shieldButton.isHidden ? 0 : TabLocationViewUX.ButtonWidth)
        }
        shareButton.snp.updateConstraints { make in
            make.width.equalTo(
                shareButton.isHidden ? 0 : TabLocationViewUX.ButtonWidth
            )
        }
        super.updateConstraints()
    }

    private lazy var _accessibilityElements = [shieldButton, urlLabel, reloadButton, shareButton]

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
        var text: String
        if let scheme = url?.scheme, let host = url?.host, (scheme == "https" || scheme == "http") {
            text = host
        } else {
            text = url?.absoluteString ?? ""
        }
        // NOTE: Punycode support was removed
        let showQueryInLocationBar = NeevaFeatureFlags[.clientHideSearchBox]
        if showQueryInLocationBar, let query = neevaSearchEngine.queryForSearchURL(url), !NeevaConstants.isNeevaPageWithSearchBox(url: url) {
            displayTextIsQuery = true
            text = query
        } else {
            displayTextIsQuery = false
        }
        if !text.isEmpty {
            urlLabelTextIsPlaceholder = false
            urlLabel.text = text
            shareButton.isHidden = !showShareButton
            reloadButton.isHidden = false

            // show search icon for query and lock for website
            let config = UIImage.SymbolConfiguration(pointSize: 14, weight: .semibold)
            let padding = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: TabLocationViewUX.IconPadding)
            lockImageView.image = UIImage(systemName: displayTextIsQuery ? "magnifyingglass" : "lock.fill", withConfiguration: config)?.withAlignmentRectInsets(padding)
        } else {
            urlLabelTextIsPlaceholder = true
            urlLabel.text = .TabLocationURLPlaceholder
            shareButton.isHidden = true
            reloadButton.isHidden = true
        }
        applyUIMode(isPrivate: isPrivateMode)
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
        if view === urlLabel {
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
        let placeholder = UIColor.TextField.placeholder(isPrivate: isPrivateMode)

        urlLabel.textColor = urlLabelTextIsPlaceholder ? placeholder : textAndTint

        backgroundColor = background
        lockImageView.tintColor = textAndTint
        reloadButton.tintColor = textAndTint
        shieldButton.tintColor = textAndTint
        shareButton.tintColor = textAndTint

        if isPrivateMode {
            shieldButton.setImage(UIImage.templateImageNamed("incognito"), for: .normal)
        } else {
            shieldButton.setImage(UIImage.templateImageNamed("tracking-protection"), for: .normal)
        }
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
    
    private var _reloadButtonState = ReloadButtonState.reload
    
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

private class DisplayTextLabel: UILabel {
    weak var accessibilityActionsSource: AccessibilityActionsSource?

    override var accessibilityCustomActions: [UIAccessibilityCustomAction]? {
        get {
            return accessibilityActionsSource?.accessibilityCustomActionsForView(self)
        }
        set {
            super.accessibilityCustomActions = newValue
        }
    }
}
