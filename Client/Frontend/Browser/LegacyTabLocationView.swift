/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import UIKit
import Shared
import SnapKit
import Combine

protocol LegacyTabLocationViewDelegate: AnyObject {
    func tabLocationViewDidTapLocation(_ tabLocationView: LegacyTabLocationView)
    func tabLocationViewDidLongPressLocation(_ tabLocationView: LegacyTabLocationView)
    func tabLocationViewDidTapReload()
    func tabLocationViewDidTapShield(_ tabLocationView: LegacyTabLocationView, from button: UIButton)
    func tabLocationViewDidBeginDragInteraction(_ tabLocationView: LegacyTabLocationView)
    func tabLocationViewDidTap(shareButton: UIView)

    func tabLocationViewReloadMenu() -> UIMenu?
    func tabLocationViewLocationAccessibilityActions(_ tabLocationView: LegacyTabLocationView) -> [UIAccessibilityCustomAction]?
}

private enum LegacyTabLocationViewUX {
    static let LockIconWidth: CGFloat = 16
    static let ButtonWidth: CGFloat = 44
    static let ButtonHeight: CGFloat = 42
    static let IconPadding: CGFloat = -8
}

let EllipsePointerStyleProvider: UIButton.PointerStyleProvider = { button, effect, style in
    UIPointerStyle(effect: effect, shape: .path(UIBezierPath(ovalIn: button.bounds)))
}

class LegacyTabLocationView: UIView {
    let model: URLBarModel
    private var subscriptions: Set<AnyCancellable> = []

    var delegate: LegacyTabLocationViewDelegate?
    private var longPressRecognizer: UILongPressGestureRecognizer!
    private var tapRecognizer: UITapGestureRecognizer!
    var contentView: UIView!
    private var isPrivateMode: Bool = false

    func updateShareButton(_ isPage: Bool) {
        shareButton.isEnabled = isPage
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

    private lazy var lockImageView: UIImageView = {
        let lockImageView = UIImageView(image: UIImage(systemName: "lock.fill"))
        lockImageView.isAccessibilityElement = true
        lockImageView.contentMode = .center
        lockImageView.accessibilityLabel = .TabLocationLockIconAccessibilityLabel
        lockImageView.tintColor = .black
        return lockImageView
    }()

    private lazy var lockAndText = UIView()
    
    private lazy var shieldButton: UIButton = {
        let shieldButton = UIButton()
        shieldButton.setImage(UIImage.templateImageNamed("tracking-protection"), for: .normal)
        shieldButton.addTarget(self, action: #selector(didPressTPShieldButton(_:)), for: .touchUpInside)
        shieldButton.tintColor = UIColor.Photon.Grey50
        shieldButton.imageView?.contentMode = .scaleAspectFill
        shieldButton.accessibilityIdentifier = "TabLocationView.shieldButton"
        shieldButton.pointerStyleProvider = EllipsePointerStyleProvider
        return shieldButton
    }()

    private lazy var reloadButton: ReloadButton = {
        let reloadButton = ReloadButton(frame: .zero, state: model.$reloadButton, readerMode: model.$readerMode)
        reloadButton.addTarget(self, action: #selector(tapReloadButton), for: .touchUpInside)
        reloadButton.setDynamicMenu { self.delegate?.tabLocationViewReloadMenu() }
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
    
    init(model: URLBarModel) {
        self.model = model
        super.init(frame: .zero)

        // safe to use unowned instead of weak here because deallocating the location view
        // causes the subscription to be cancelled
        model.$url.sink { [unowned self] url in
            // Report the URL as the accessible value rather than the display text.
            urlLabel.accessibilityValue = url?.absoluteString ?? ""
            updateTextWithURL(url)
            shieldButton.isHidden = !["https", "http"].contains(url?.scheme ?? "")
            setNeedsUpdateConstraints()
        }.store(in: &subscriptions)
        model.$isSecure.sink { [unowned self] isSecure in
            if model.url?.absoluteString == "about:blank" {
                // Matching the desktop behaviour, we don't mark these pages as secure.
                lockImageView.isHidden = true
                return
            }
            lockImageView.isHidden = !isSecure
        }.store(in: &subscriptions)

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
            make.width.equalTo(LegacyTabLocationViewUX.LockIconWidth)
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
            make.width.equalTo(LegacyTabLocationViewUX.ButtonWidth)
            make.height.equalTo(LegacyTabLocationViewUX.ButtonHeight)
            make.leading.equalTo(self)
        }

        lockAndText.snp.makeConstraints { make in
            make.centerX.equalTo(self.snp.centerX).priority(.medium)
            make.centerY.equalTo(self)
            make.height.equalTo(LegacyTabLocationViewUX.ButtonHeight)
            make.leading.greaterThanOrEqualTo(shieldButton.snp.trailing).priority(.high)
            make.trailing.lessThanOrEqualTo(reloadButton.snp.leading).priority(.high)
        }

        reloadButton.snp.makeConstraints { make in
            make.centerY.equalTo(self)
            make.width.equalTo(LegacyTabLocationViewUX.ButtonWidth)
            make.height.equalTo(LegacyTabLocationViewUX.ButtonHeight)
        }
        shareButton.snp.makeConstraints { make in
            make.centerY.equalTo(self)
            make.leading.equalTo(reloadButton.snp.trailing)
            make.trailing.equalTo(self)
            make.height.equalTo(LegacyTabLocationViewUX.ButtonHeight)
            make.width.equalTo(LegacyTabLocationViewUX.ButtonWidth)
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
                lockImageView.isHidden ? 0 : LegacyTabLocationViewUX.LockIconWidth)
        }
        reloadButton.snp.updateConstraints { make in
            make.width.equalTo(
                reloadButton.isHidden ? 0 : LegacyTabLocationViewUX.ButtonWidth)
        }
        shieldButton.snp.updateConstraints { make in
            make.width.equalTo(
                shieldButton.isHidden ? 0 : LegacyTabLocationViewUX.ButtonWidth)
        }
        shareButton.snp.updateConstraints { make in
            make.width.equalTo(
                shareButton.isHidden ? 0 : LegacyTabLocationViewUX.ButtonWidth
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
        delegate?.tabLocationViewDidTapReload()
    }

    @objc func tapShareButton() {
        delegate?.tabLocationViewDidTap(shareButton: shareButton)
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
        delegate?.tabLocationViewDidTapShield(self, from: button)
    }

    fileprivate func updateTextWithURL(_ url: URL?) {
        var text: String
        if let scheme = url?.scheme, let host = url?.host, (scheme == "https" || scheme == "http") {
            text = host
        } else {
            text = url?.absoluteString ?? ""
        }
        // NOTE: Punycode support was removed
        if let query = neevaSearchEngine.queryForLocationBar(from: url) {
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
            let padding = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: LegacyTabLocationViewUX.IconPadding)
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

extension LegacyTabLocationView: UIGestureRecognizerDelegate {
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
extension LegacyTabLocationView: UIDragInteractionDelegate {
    func dragInteraction(_ interaction: UIDragInteraction, itemsForBeginning session: UIDragSession) -> [UIDragItem] {
        // Ensure we actually have a URL in the location bar and that the URL is not local.
        guard let url = model.url, !InternalURL.isValid(url: url), let itemProvider = NSItemProvider(contentsOf: model.url) else {
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

extension LegacyTabLocationView: AccessibilityActionsSource {
    func accessibilityCustomActionsForView(_ view: UIView) -> [UIAccessibilityCustomAction]? {
        if view === urlLabel {
            return delegate?.tabLocationViewLocationAccessibilityActions(self)
        }
        return nil
    }
}

extension LegacyTabLocationView: PrivateModeUI {
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

extension LegacyTabLocationView: TabEventHandler {
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

fileprivate class ReloadButton: UIButton {
    private var subscription: AnyCancellable?
    convenience init(frame: CGRect, state: Published<ReloadButtonState>.Publisher, readerMode: Published<ReaderModeState>.Publisher) {
        self.init(frame: frame)
        subscription = state.combineLatest(readerMode)
            .sink { [unowned self] state, readerMode in
                guard readerMode != .active else {
                    self.isHidden = true
                    return
                }

                let configuration = UIImage.SymbolConfiguration(weight: .medium)
                switch state {
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

    required override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
