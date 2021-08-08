/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import Combine
import Shared
import SnapKit
import Storage
import SwiftUI

protocol CommonURLBar: PrivateModeUI {
    var model: URLBarModel { get }
    var queryModel: SearchQueryModel { get }
    var suggestionModel: SuggestionModel { get }
    var gridModel: GridModel { get }
    var trackingStatsViewModel: TrackingStatsViewModel { get }
}

private enum LegacyURLBarViewUX {
    static let LocationEdgePadding: CGFloat = 8
    static let Padding: CGFloat = 5.5
    static let ButtonPadding: CGFloat = 12
    static let LocationHeight: CGFloat = UIConstants.TextFieldHeight
    static let ButtonSize: CGFloat = 44  // width and height
    static let TextFieldCornerRadius: CGFloat = UIConstants.TextFieldHeight / 2
    static let ProgressBarHeight: CGFloat = 3
    static let ToolbarEdgePaddding: CGFloat = 24
}

protocol LegacyURLBarDelegate: UIViewController {
    func urlBarDidPressTabs(_ urlBar: LegacyURLBarView)
    func urlBarReloadMenu() -> UIMenu?
    func urlBarDidPressStop()
    func urlBarDidPressReload()
    func urlBarDidEnterOverlayMode()
    func urlBarDidLeaveOverlayMode()
    func urlBarNeevaMenu(_ urlBar: LegacyURLBarView, from button: UIButton)
    func urlBar(didEnterText text: String)
    func urlBar(didSubmitText text: String)
}

class LegacyURLBarView: UIView, LegacyTabToolbarProtocol, CommonURLBar {
    let model = URLBarModel()
    let queryModel = SearchQueryModel()
    let suggestionModel: SuggestionModel
    let gridModel: GridModel
    let trackingStatsViewModel: TrackingStatsViewModel
    var subscriptions: Set<AnyCancellable> = []

    weak var delegate: LegacyURLBarDelegate?

    weak var tabToolbarDelegate: TabToolbarDelegate?
    var helper: LegacyTabToolbarHelper!
    let toolbarModel: TabToolbarModel
    var isTransitioning: Bool = false {
        didSet {
            if isTransitioning {
                // Cancel any pending/in-progress animations related to the progress bar
                self.progressBar.setProgress(1, animated: false)
                self.progressBar.alpha = 0.0
            }
        }
    }

    var toolbarIsShowing = false

    /// Overlay mode is the state where the lock/reader icons are hidden, the zero query panels are shown,
    /// and the Cancel button is visible (allowing the user to leave overlay mode). Overlay mode
    /// is *not* tied to the location text field's editing state; for instance, when selecting
    /// a panel, the first responder will be resigned, yet the overlay mode UI is still active.
    var inOverlayMode = false

    var isPrivateMode = false

    lazy var neevaMenuIcon = UIImage.originalImageNamed("neevaMenuIcon")
    lazy var neevaMenuButton: UIButton = { [unowned self] in
        let neevaMenuButton = UIButton(frame: .zero)
        neevaMenuButton.setImage(neevaMenuIcon, for: .normal)
        neevaMenuButton.adjustsImageWhenHighlighted = false
        neevaMenuButton.isAccessibilityElement = true
        neevaMenuButton.isHidden = false
        neevaMenuButton.imageView?.contentMode = .left
        neevaMenuButton.accessibilityLabel = "Neeva Menu"
        neevaMenuButton.addTarget(
            self, action: #selector(didClickNeevaMenu), for: UIControl.Event.touchUpInside)
        neevaMenuButton.showsMenuAsPrimaryAction = true
        return neevaMenuButton
    }()

    lazy var locationHost: TabLocationHost = { [unowned self] in
        TabLocationHost(
            model: model,
            suggestionModel: suggestionModel,
            queryModel: queryModel,
            gridModel: self.gridModel,
            trackingStatsModel: self.trackingStatsViewModel,
            delegate: self, urlBar: self)
    }()

    lazy var locationContainer: UIView = {
        let locationContainer = TabLocationContainerView()
        locationContainer.translatesAutoresizingMaskIntoConstraints = false
        locationContainer.backgroundColor = .clear
        return locationContainer
    }()

    let line = UIView()

    lazy var newTabButton: UIButton = {
        let symbol = UIImage(
            systemName: "plus.app", withConfiguration: UIImage.SymbolConfiguration(pointSize: 20))
        let newTabButton = UIButton()
        newTabButton.setImage(symbol, for: .normal)
        newTabButton.accessibilityIdentifier = "URLBarView.newTabButton"
        newTabButton.tintColor = UIColor.label
        newTabButton.addAction(
            UIAction { _ in
                BrowserViewController.foregroundBVC().openURLInNewTab(nil)
            }, for: .primaryActionTriggered)
        newTabButton.isPointerInteractionEnabled = true
        return newTabButton
    }()

    lazy var tabsButton: TabsButton = {
        let tabsButton = TabsButton.tabTrayButton()
        tabsButton.accessibilityIdentifier = "URLBarView.tabsButton"
        return tabsButton
    }()

    fileprivate lazy var progressBar: GradientProgressBar = {
        let progressBar = GradientProgressBar()
        progressBar.clipsToBounds = false
        return progressBar
    }()

    var addToSpacesButton = ToolbarButton()

    var forwardButton = ToolbarButton()
    var shareButton = ToolbarButton()
    var backButton = ToolbarButton()

    var toolbarNeevaMenuButton = ToolbarButton()

    lazy var actionButtons: [ToolbarButton] = { [unowned self] in
        [
            self.addToSpacesButton, self.forwardButton, self.backButton, self.shareButton,
        ]
    }()

    var profile: Profile? = nil

    init(
        profile: Profile, toolbarModel: TabToolbarModel,
        gridModel: GridModel, trackingStatsModel: TrackingStatsViewModel
    ) {
        self.profile = profile
        self.suggestionModel = SuggestionModel(  profile: profile, queryModel: self.queryModel)
        self.toolbarModel = toolbarModel
        self.gridModel = gridModel
        self.trackingStatsViewModel = trackingStatsModel
        super.init(frame: CGRect())
        commonInit()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    fileprivate func commonInit() {
        locationContainer.addSubview(locationHost.view)

        [
            line, tabsButton, neevaMenuButton, progressBar, addToSpacesButton,
            forwardButton, backButton, shareButton, locationContainer,
        ].forEach {
            addSubview($0)
        }
        if FeatureFlag[.cardStrip] {
            addSubview(newTabButton)
        }

        helper = LegacyTabToolbarHelper(toolbar: self)
        subscriptions.formUnion(helper.subscribe(to: toolbarModel))
        setupConstraints()

        // Make sure we hide any views that shouldn't be showing in non-overlay mode.
        updateViewsForOverlayModeAndToolbarChanges()

        applyUIMode(isPrivate: isPrivateMode)

        neevaMenuButton.isPointerInteractionEnabled = true

        model.$url.sink { [unowned self] newURL in
            if let url = newURL, InternalURL(url)?.isZeroQueryURL ?? false {
                line.isHidden = true
            } else {
                line.isHidden = false
            }
        }.store(in: &subscriptions)

        model.$showToolbarItems
            .sink { [unowned self] in self.setShowToolbar($0) }
            .store(in: &subscriptions)

        model.$estimatedProgress
            .sink { [unowned self] estimatedProgress in
                if let estimatedProgress = estimatedProgress {
                    self.updateProgressBar(Float(estimatedProgress))
                } else {
                    self.hideProgressBar()
                }
            }
            .store(in: &subscriptions)
    }

    fileprivate func setupConstraints() {

        line.snp.makeConstraints { make in
            (UIConstants.enableBottomURLBar ? make.top : make.bottom).equalTo(self)
            make.leading.trailing.equalTo(self)
            make.height.equalTo(0.5)
        }

        progressBar.snp.makeConstraints { make in
            make.top.equalTo(self.snp.bottom).inset(LegacyURLBarViewUX.ProgressBarHeight / 2)
            make.height.equalTo(LegacyURLBarViewUX.ProgressBarHeight)
            make.left.right.equalTo(self)
        }

        locationHost.view.snp.makeConstraints { make in
            make.edges.equalTo(self.locationContainer)
        }

        backButton.snp.makeConstraints { make in
            if FeatureFlag[.cardStrip] {
                make.leading.equalTo(self.newTabButton.snp.trailing).offset(
                    LegacyURLBarViewUX.ButtonPadding)
            } else {
                make.leading.equalTo(self.safeArea.leading).offset(
                    LegacyURLBarViewUX.ToolbarEdgePaddding)
            }
            make.centerY.equalTo(self.locationContainer)
            make.size.equalTo(LegacyURLBarViewUX.ButtonSize)
        }

        forwardButton.snp.makeConstraints { make in
            make.leading.equalTo(self.backButton.snp.trailing).offset(
                LegacyURLBarViewUX.ButtonPadding)
            make.centerY.equalTo(self.locationContainer)
            make.size.equalTo(LegacyURLBarViewUX.ButtonSize)
        }

        neevaMenuButton.snp.makeConstraints { make in
            make.leading.equalTo(self.forwardButton.snp.trailing).offset(
                LegacyURLBarViewUX.ButtonPadding)
            make.centerY.equalTo(self.locationContainer)
            make.size.equalTo(LegacyURLBarViewUX.ButtonSize)
        }

        shareButton.snp.makeConstraints { make in
            make.centerY.equalTo(self.locationContainer)
            make.size.equalTo(LegacyURLBarViewUX.ButtonSize)
        }

        addToSpacesButton.snp.makeConstraints { make in
            make.leading.equalTo(self.shareButton.snp.trailing).offset(
                LegacyURLBarViewUX.ButtonPadding)
            make.centerY.equalTo(self.locationContainer)
            make.size.equalTo(LegacyURLBarViewUX.ButtonSize)
        }

        if FeatureFlag[.cardStrip] {
            newTabButton.snp.makeConstraints { make in
                make.leading.equalTo(self.safeArea.leading).offset(
                    LegacyURLBarViewUX.ToolbarEdgePaddding)
                make.centerY.equalTo(self.locationContainer)
                make.size.equalTo(LegacyURLBarViewUX.ButtonSize)
            }
        }

        tabsButton.snp.makeConstraints { make in
            make.leading.equalTo(self.addToSpacesButton.snp.trailing).offset(
                LegacyURLBarViewUX.ButtonPadding)
            make.centerY.equalTo(self.locationContainer)
            make.size.equalTo(LegacyURLBarViewUX.ButtonSize)
            make.trailing.equalTo(self.safeArea.trailing).offset(
                -LegacyURLBarViewUX.ToolbarEdgePaddding)
        }
    }

    override func updateConstraints() {
        super.updateConstraints()
        self.locationContainer.snp.remakeConstraints { make in
            if inOverlayMode {
                make.leading.equalTo(self.safeArea.leading).offset(
                    LegacyURLBarViewUX.LocationEdgePadding)
                make.trailing.equalTo(self.safeArea.trailing).offset(
                    toolbarIsShowing
                        ? -LegacyURLBarViewUX.ToolbarEdgePaddding
                        : -LegacyURLBarViewUX.LocationEdgePadding)
            } else if self.toolbarIsShowing {
                make.leading.equalTo(self.neevaMenuButton.snp.trailing).offset(
                    LegacyURLBarViewUX.Padding)
                make.trailing.equalTo(self.shareButton.snp.leading).offset(
                    -LegacyURLBarViewUX.Padding)
            } else {
                make.leading.equalTo(self.safeArea.leading).offset(
                    LegacyURLBarViewUX.LocationEdgePadding)
                make.trailing.equalTo(self.safeArea.trailing).offset(
                    -LegacyURLBarViewUX.LocationEdgePadding)
            }
            make.height.equalTo(LegacyURLBarViewUX.LocationHeight)
            if self.toolbarIsShowing || UIConstants.enableBottomURLBar {
                make.centerY.equalTo(self)
            } else {
                make.top.equalTo(self).offset(UIConstants.TopToolbarPaddingTop)
            }
        }
    }

    @objc func didClickNeevaMenu() {
        self.delegate?.urlBarNeevaMenu(self, from: neevaMenuButton)
    }

    override func becomeFirstResponder() -> Bool {
        model.setEditing(to: true)
        return true
    }

    // Ideally we'd split this implementation in two, one URLBarView with a toolbar and one without
    // However, switching views dynamically at runtime is a difficult. For now, we just use one view
    // that can show in either mode.
    private func setShowToolbar(_ shouldShow: Bool) {
        toolbarIsShowing = shouldShow
        setNeedsUpdateConstraints()
        // when we transition from portrait to landscape, calling this here causes
        // the constraints to be calculated too early and there are constraint errors
        if !toolbarIsShowing {
            updateConstraintsIfNeeded()
            model.includeShareButtonInLocationView = true
        } else {
            model.includeShareButtonInLocationView = false
        }
        updateViewsForOverlayModeAndToolbarChanges()
    }

    func updateAlphaForSubviews(_ alpha: CGFloat) {
        locationContainer.alpha = alpha
        neevaMenuButton.alpha = alpha
        actionButtons.forEach {
            $0.alpha = alpha
        }
        tabsButton.alpha = alpha
        if FeatureFlag[.cardStrip] {
            newTabButton.alpha = alpha
        }
    }

    private func updateProgressBar(_ progress: Float) {
        model.reloadButton = progress == 1 ? .reload : .stop
        progressBar.alpha = 1
        progressBar.isHidden = false
        progressBar.setProgress(progress, animated: !isTransitioning)
    }

    private func hideProgressBar() {
        model.reloadButton = .reload
        progressBar.alpha = 0
        progressBar.resetProgressBar()
    }

    func enterOverlayMode() {
        // Show the overlay mode UI
        animateToOverlayState(overlayMode: true)

        delegate?.urlBarDidEnterOverlayMode()
    }

    func leaveOverlayMode(didCancel cancel: Bool = false) {
        model.setEditing(to: false)
        animateToOverlayState(overlayMode: false, didCancel: cancel)
        delegate?.urlBarDidLeaveOverlayMode()
    }

    func prepareOverlayAnimation() {
        // Make sure everything is showing during the transition (we'll hide it afterwards).
        bringSubviewToFront(self.locationContainer)
        neevaMenuButton.isHidden = !toolbarIsShowing
        progressBar.isHidden = false
        addToSpacesButton.isHidden = !toolbarIsShowing
        forwardButton.isHidden = !toolbarIsShowing
        backButton.isHidden = !toolbarIsShowing
        tabsButton.isHidden = !toolbarIsShowing
        shareButton.isHidden = !toolbarIsShowing
        if FeatureFlag[.cardStrip] {
            newTabButton.isHidden = !toolbarIsShowing
        }
    }

    func transitionToOverlay(_ didCancel: Bool = false) {
        neevaMenuButton.alpha = inOverlayMode ? 0 : 1
        progressBar.alpha = inOverlayMode || didCancel ? 0 : 1
        tabsButton.alpha = inOverlayMode ? 0 : 1
        if FeatureFlag[.cardStrip] {
            newTabButton.alpha = inOverlayMode ? 0 : 1
        }
        addToSpacesButton.alpha = inOverlayMode ? 0 : 1
        forwardButton.alpha = inOverlayMode ? 0 : 1
        backButton.alpha = inOverlayMode ? 0 : 1
        shareButton.alpha = inOverlayMode ? 0 : 1
    }

    func updateViewsForOverlayModeAndToolbarChanges() {
        neevaMenuButton.isHidden = !toolbarIsShowing || inOverlayMode
        progressBar.isHidden = inOverlayMode
        addToSpacesButton.isHidden = !toolbarIsShowing || inOverlayMode
        forwardButton.isHidden = !toolbarIsShowing || inOverlayMode
        backButton.isHidden = !toolbarIsShowing || inOverlayMode
        tabsButton.isHidden = !toolbarIsShowing || inOverlayMode
        if FeatureFlag[.cardStrip] {
            newTabButton.isHidden = !toolbarIsShowing || inOverlayMode
        }
        shareButton.isHidden = !toolbarIsShowing || inOverlayMode
    }

    func animateToOverlayState(overlayMode overlay: Bool, didCancel cancel: Bool = false) {
        prepareOverlayAnimation()
        layoutIfNeeded()

        inOverlayMode = overlay

        UIView.animate(
            withDuration: 0.3, delay: 0.0, usingSpringWithDamping: 0.85, initialSpringVelocity: 0.0,
            options: [],
            animations: {
                self.transitionToOverlay(cancel)
                self.updateConstraints()
                self.layoutIfNeeded()
            },
            completion: { _ in
                self.updateViewsForOverlayModeAndToolbarChanges()
            })
    }
}

extension LegacyURLBarView: LegacyTabLocationViewDelegate {
    func tabLocationViewReloadMenu() -> UIMenu? {
        delegate?.urlBarReloadMenu()
    }

    func tabLocationViewDidTapReload() {
        switch model.reloadButton {
        case .reload:
            delegate?.urlBarDidPressReload()
        case .stop:
            delegate?.urlBarDidPressStop()
        }
    }

    func tabLocationViewDidTap(shareButton: UIView) {
        self.helper?.didPress(shareButton: shareButton)
    }
}

extension LegacyURLBarView: PrivateModeUI {
    func applyUIMode(isPrivate: Bool) {
        isPrivateMode = isPrivate

        locationHost.applyUIMode(isPrivate: isPrivate)

        if isPrivate {
            neevaMenuButton.setImage(
                neevaMenuIcon?.withRenderingMode(.alwaysTemplate), for: .normal)
        } else {
            neevaMenuButton.setImage(neevaMenuIcon, for: .normal)
        }

        neevaMenuButton.tintColor = UIColor.URLBar.neevaMenuTint(isPrivateMode)

        backgroundColor = UIColor.Browser.background
        line.backgroundColor = UIColor.Browser.urlBarDivider

        progressBar.setGradientColors(
            startColor: UIColor.LoadingBar.start(isPrivateMode),
            endColor: UIColor.LoadingBar.end(isPrivateMode))
    }
}

// We need a subclass so we can setup the shadows correctly
// This subclass creates a strong shadow on the URLBar
class TabLocationContainerView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        let layer = self.layer
        // The container needs is used to clip the text field so we can align the
        // 'clear' button within the rounded corners of the container properly.
        layer.cornerRadius = LegacyURLBarViewUX.TextFieldCornerRadius
        layer.masksToBounds = true
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
