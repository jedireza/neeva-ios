/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import Shared
import SnapKit
import Storage
import SwiftUI
import Combine

private enum LegacyURLBarViewUX {
    static let LocationEdgePadding: CGFloat = 8
    static let LocationOverlayLeftPadding: CGFloat = 14
    static let LocationOverlayRightPadding: CGFloat = 2
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
    func urlBarReloadMenu(_ urlBar: LegacyURLBarView) -> UIMenu?
    func urlBarDidPressStop(_ urlBar: LegacyURLBarView)
    func urlBarDidPressReload(_ urlBar: LegacyURLBarView)
    func urlBarDidEnterOverlayMode()
    func urlBarDidLeaveOverlayMode()
    func urlBarDidLongPressLegacyLocation(_ urlBar: LegacyURLBarView)
    func urlBarNeevaMenu(_ urlBar: LegacyURLBarView, from button: UIButton)
    func urlBarDidTapShield(_ urlBar: LegacyURLBarView, from button: UIButton)
    func urlBarLocationAccessibilityActions(_ urlBar: LegacyURLBarView) -> [UIAccessibilityCustomAction]?
    func urlBar(_ urlBar: LegacyURLBarView, didRestoreText text: String)
    func urlBar(didEnterText text: String)
    func urlBar(didSubmitText text: String)
    func urlBarDidBeginDragInteraction(_ urlBar: LegacyURLBarView)
}

class LegacyURLBarView: UIView {
    let model = URLBarModel()
    let historySuggestionModel: HistorySuggestionModel
    let neevaSuggestionModel: NeevaSuggestionModel
    let gridModel: GridModel
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
    var topTabsIsShowing = false

    fileprivate var legacyLocationTextField: ToolbarTextField?

    /// Overlay mode is the state where the lock/reader icons are hidden, the zero query panels are shown,
    /// and the Cancel button is visible (allowing the user to leave overlay mode). Overlay mode
    /// is *not* tied to the location text field's editing state; for instance, when selecting
    /// a panel, the first responder will be resigned, yet the overlay mode UI is still active.
    var inOverlayMode = false

    var isPrivateMode = false

    lazy var neevaMenuIcon = UIImage.originalImageNamed("neevaMenuIcon")
    lazy var neevaMenuButton: UIButton = {
        let neevaMenuButton = UIButton(frame: .zero)
        neevaMenuButton.setImage(neevaMenuIcon, for: .normal)
        neevaMenuButton.adjustsImageWhenHighlighted = false
        neevaMenuButton.isAccessibilityElement = true
        neevaMenuButton.isHidden = false
        neevaMenuButton.imageView?.contentMode = .left
        neevaMenuButton.accessibilityLabel = .TabLocationPageOptionsAccessibilityLabel
        neevaMenuButton.accessibilityIdentifier = "URLBarView.neevaMenuButton"
        neevaMenuButton.addTarget(self, action: #selector(didClickNeevaMenu), for: UIControl.Event.touchUpInside)
        neevaMenuButton.showsMenuAsPrimaryAction = true
        return neevaMenuButton
    }()
    
    lazy var legacyLocationView: LegacyTabLocationView = {
        let locationView = LegacyTabLocationView(model: model)
        locationView.layer.cornerRadius = LegacyURLBarViewUX.TextFieldCornerRadius
        locationView.translatesAutoresizingMaskIntoConstraints = false
        locationView.delegate = self
        return locationView
    }()

    lazy var locationHost: TabLocationHost = {
        TabLocationHost(model: model,
                        historySuggestionModel: historySuggestionModel,
                        neevaSuggestionModel: neevaSuggestionModel,
                        gridModel: self.gridModel,
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
        let symbol = UIImage(systemName: "plus.app", withConfiguration: UIImage.SymbolConfiguration(pointSize: 20))
        let newTabButton = UIButton()
        newTabButton.setImage(symbol, for: .normal)
        newTabButton.accessibilityIdentifier = "URLBarView.newTabButton"
        newTabButton.tintColor = UIColor.label
        newTabButton.addAction(UIAction { _ in
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

    fileprivate lazy var legacyCancelButton: UIButton = {
        let legacyCancelButton = InsetButton()
        legacyCancelButton.setTitle(Strings.CancelString, for: .normal)
        legacyCancelButton.setTitleColor(.systemBlue, for: .normal)
        legacyCancelButton.accessibilityIdentifier = "urlBar-cancel"
        legacyCancelButton.addTarget(self, action: #selector(didClickCancel), for: .touchUpInside)
        legacyCancelButton.alpha = 0
        legacyCancelButton.isPointerInteractionEnabled = true
        return legacyCancelButton
    }()

    var addToSpacesButton = ToolbarButton()

    var forwardButton = ToolbarButton()
    var shareButton = ToolbarButton()
    var backButton = ToolbarButton()

    var toolbarNeevaMenuButton = ToolbarButton()

    lazy var actionButtons: [ToolbarButton] = [self.addToSpacesButton, self.forwardButton, self.backButton, self.shareButton]

    var profile: Profile? = nil
    
    init(profile: Profile, toolbarModel: TabToolbarModel, gridModel: GridModel) {
        self.profile = profile
        self.historySuggestionModel = HistorySuggestionModel(profile: profile)
        self.neevaSuggestionModel = NeevaSuggestionModel(isIncognito: isPrivateMode)
        self.toolbarModel = toolbarModel
        self.gridModel = gridModel
        super.init(frame: CGRect())
        commonInit()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    fileprivate func commonInit() {
        if FeatureFlag[.newURLBar] {
            locationContainer.addSubview(locationHost.view)
        } else {
            locationContainer.addSubview(legacyLocationView)
        }

        if !FeatureFlag[.newURLBar] {
            addSubview(legacyCancelButton)
        }
        [line, tabsButton, neevaMenuButton, progressBar, addToSpacesButton,
         forwardButton, backButton, shareButton, locationContainer].forEach {
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

        if !FeatureFlag[.newURLBar] {
            // Create LocationTextField and update constraints to layout correctly before hiding it
            createLegacyLocationTextField()
            inOverlayMode = true
            updateConstraints()
            legacyLocationTextField?.isHidden = true
            inOverlayMode = false
            updateConstraints()
        }

        applyUIMode(isPrivate: isPrivateMode)

        neevaMenuButton.isPointerInteractionEnabled = true

        model.$url.sink { [unowned self] newURL in
            if let url = newURL, InternalURL(url)?.isZeroQueryURL ?? false {
                line.isHidden = true
            } else {
                line.isHidden = false
            }
        }.store(in: &subscriptions)

        if !FeatureFlag[.newURLBar] {
            neevaSuggestionModel.$activeLensBang.sink { [unowned self] newLensBang in
                if newLensBang != nil {
                    self.createLegacyLeftViewFavicon()
                }
            }.store(in: &subscriptions)
            historySuggestionModel.$completion.sink { [unowned self] completion in
                legacyLocationTextField?.setAutocompleteSuggestion(completion.map { SearchQueryModel.shared.value + $0 })
                createLegacyLeftViewFavicon(completion ?? "")
            }.store(in: &subscriptions)
        }
    }
    
    fileprivate func setupConstraints() {

        line.snp.makeConstraints { make in
            make.bottom.leading.trailing.equalTo(self)
            make.height.equalTo(0.5)
        }

        progressBar.snp.makeConstraints { make in
            make.top.equalTo(self.snp.bottom).inset(LegacyURLBarViewUX.ProgressBarHeight / 2)
            make.height.equalTo(LegacyURLBarViewUX.ProgressBarHeight)
            make.left.right.equalTo(self)
        }
        
        (FeatureFlag[.newURLBar] ? locationHost.view : legacyLocationView).snp.makeConstraints { make in
            make.edges.equalTo(self.locationContainer)
        }

        if !FeatureFlag[.newURLBar] {
            legacyCancelButton.snp.makeConstraints { make in
                make.trailing.equalTo(self.safeArea.trailing).offset(toolbarIsShowing ? -LegacyURLBarViewUX.ToolbarEdgePaddding : -LegacyURLBarViewUX.LocationEdgePadding)
                make.centerY.equalTo(self.locationContainer)
                make.height.equalTo(LegacyURLBarViewUX.ButtonSize)
                make.width.equalTo(legacyCancelButton.intrinsicContentSize.width)
            }
        }

        backButton.snp.makeConstraints { make in
            if FeatureFlag[.cardStrip] {
                make.leading.equalTo(self.newTabButton.snp.trailing).offset(LegacyURLBarViewUX.ButtonPadding)
            } else {
                make.leading.equalTo(self.safeArea.leading).offset(LegacyURLBarViewUX.ToolbarEdgePaddding)
            }
            make.centerY.equalTo(self.locationContainer)
            make.size.equalTo(LegacyURLBarViewUX.ButtonSize)
        }

        forwardButton.snp.makeConstraints { make in
            make.leading.equalTo(self.backButton.snp.trailing).offset(LegacyURLBarViewUX.ButtonPadding)
            make.centerY.equalTo(self.locationContainer)
            make.size.equalTo(LegacyURLBarViewUX.ButtonSize)
        }

        neevaMenuButton.snp.makeConstraints { make in
            make.leading.equalTo(self.forwardButton.snp.trailing).offset(LegacyURLBarViewUX.ButtonPadding)
            make.centerY.equalTo(self.locationContainer)
            make.size.equalTo(LegacyURLBarViewUX.ButtonSize)
        }

        shareButton.snp.makeConstraints { make in
            make.centerY.equalTo(self.locationContainer)
            make.size.equalTo(LegacyURLBarViewUX.ButtonSize)
        }

        addToSpacesButton.snp.makeConstraints { make in
            make.leading.equalTo(self.shareButton.snp.trailing).offset(LegacyURLBarViewUX.ButtonPadding)
            make.centerY.equalTo(self.locationContainer)
            make.size.equalTo(LegacyURLBarViewUX.ButtonSize)
        }

        if FeatureFlag[.cardStrip] {
            newTabButton.snp.makeConstraints { make in
                make.leading.equalTo(self.safeArea.leading).offset(LegacyURLBarViewUX.ToolbarEdgePaddding)
                make.centerY.equalTo(self.locationContainer)
                make.size.equalTo(LegacyURLBarViewUX.ButtonSize)
            }
        }

        tabsButton.snp.makeConstraints { make in
            make.leading.equalTo(self.addToSpacesButton.snp.trailing).offset(LegacyURLBarViewUX.ButtonPadding)
            make.centerY.equalTo(self.locationContainer)
            make.size.equalTo(LegacyURLBarViewUX.ButtonSize)
            make.trailing.equalTo(self.safeArea.trailing).offset(-LegacyURLBarViewUX.ToolbarEdgePaddding)
        }
    }

    override func updateConstraints() {
        super.updateConstraints()
        self.locationContainer.snp.remakeConstraints { make in
            if inOverlayMode {
                make.leading.equalTo(self.safeArea.leading).offset(LegacyURLBarViewUX.LocationEdgePadding)
                if FeatureFlag[.newURLBar] {
                    make.trailing.equalTo(self.safeArea.trailing).offset(toolbarIsShowing ? -LegacyURLBarViewUX.ToolbarEdgePaddding : -LegacyURLBarViewUX.LocationEdgePadding)
                } else {
                    make.trailing.equalTo(self.legacyCancelButton.snp.leading).offset(-2 * LegacyURLBarViewUX.Padding)
                }
            } else if self.toolbarIsShowing {
                make.leading.equalTo(self.neevaMenuButton.snp.trailing).offset(LegacyURLBarViewUX.Padding)
                make.trailing.equalTo(self.shareButton.snp.leading).offset(-LegacyURLBarViewUX.Padding)
            } else {
                make.leading.equalTo(self.safeArea.leading).offset(LegacyURLBarViewUX.LocationEdgePadding)
                make.trailing.equalTo(self.safeArea.trailing).offset(-LegacyURLBarViewUX.LocationEdgePadding)
            }
            make.height.equalTo(LegacyURLBarViewUX.LocationHeight)
            if self.toolbarIsShowing {
                make.centerY.equalTo(self)
            } else {
                make.top.equalTo(self).offset(UIConstants.TopToolbarPaddingTop)
            }
        }
        if inOverlayMode, !FeatureFlag[.newURLBar] {
            self.legacyLocationTextField?.snp.remakeConstraints { make in
                make.edges.equalTo(legacyLocationView).inset(
                    UIEdgeInsets(top: 0, left: LegacyURLBarViewUX.LocationOverlayLeftPadding,
                                 bottom: 0, right: LegacyURLBarViewUX.LocationOverlayRightPadding))
            }
        }
    }

    @objc func didClickNeevaMenu() {
        self.delegate?.urlBarNeevaMenu(self, from: neevaMenuButton)
    }

    func createLegacyLeftViewFavicon(_ suggestion: String = "") {
        legacyLocationTextField.self?.leftViewMode = UITextField.ViewMode.always
        let iconView = UIImageView(frame: CGRect(x: 0, y: 0, width: 20 , height: 20))
        iconView.layer.cornerRadius = 2
        iconView.clipsToBounds = true
        iconView.contentMode = .scaleAspectFill

        let favicons = BrowserViewController.foregroundBVC().tabManager.selectedTab?.favicons
        if let lensOrBang = neevaSuggestionModel.activeLensBang,
           let type = lensOrBang.type {
            iconView.image = Symbol.uiImage(type.defaultSymbol).withTintColor(.label, renderingMode: .alwaysOriginal)
        } else if suggestion == NeevaConstants.appHost || suggestion == "https://\(NeevaConstants.appHost)" || (model.url?.host == NeevaConstants.appHost && suggestion == "") {
            iconView.image = UIImage(named: "neevaMenuIcon")
        } else if (suggestion != "") {
            iconView.image = UIImage(systemName: "globe", withConfiguration: UIImage.SymbolConfiguration(weight: .medium))?.withRenderingMode(.alwaysTemplate).tinted(withColor: UIColor(rgb: 0xB4BAC0))

            let gURL = suggestion.hasPrefix("http") ? URL(string: suggestion)! : URL(string: "https://\(suggestion)")!

            let site = Site(url: gURL.absoluteString, title: "")
            
            let profile = getAppDelegateProfile()
            profile.favicons.getFaviconImage(forSite: site).uponQueue(.main) { result in
                guard let image = result.successValue else {
                    return
                }
                iconView.image = image.createScaled(PhotonActionSheetUX.FaviconSize)
            }
        } else {
            iconView.image = UIImage(named: "neevaMenuIcon")
            let currentURL = BrowserViewController.foregroundBVC().tabManager.selectedTab?.url
            let currentText = legacyLocationTextField?.text

            if currentURL != nil && currentText == "" {
                for fav in favicons! {
                    if (fav.url != "") {
                        let site = Site(url: fav.url, title: "")
                        iconView.setFavicon(forSite: site) {
                            iconView.image = iconView.image?.createScaled(PhotonActionSheetUX.FaviconSize)
                        }
                        break
                    }
                }
            }
        }
        legacyLocationTextField.self?.leftView = iconView
    }

    
    func createLegacyLocationTextField() {
        guard legacyLocationTextField == nil else { return }

        legacyLocationTextField = ToolbarTextField()

        guard let legacyLocationTextField = legacyLocationTextField else { return }

        legacyLocationTextField.font = UIFont.systemFont(ofSize: 16)
        legacyLocationTextField.backgroundColor = .clear
        legacyLocationTextField.adjustsFontForContentSizeCategory = true
        legacyLocationTextField.clipsToBounds = true
        legacyLocationTextField.translatesAutoresizingMaskIntoConstraints = false
        legacyLocationTextField.autocompleteDelegate = self
        legacyLocationTextField.keyboardType = .webSearch
        legacyLocationTextField.autocorrectionType = .no
        legacyLocationTextField.autocapitalizationType = .none
        legacyLocationTextField.returnKeyType = .go
        legacyLocationTextField.clearButtonMode = .whileEditing
        legacyLocationTextField.textAlignment = .left
        legacyLocationTextField.accessibilityIdentifier = "address"
        legacyLocationTextField.accessibilityLabel = .URLBarLocationAccessibilityLabel

        createLegacyLeftViewFavicon()

        locationContainer.addSubview(legacyLocationTextField)

        // Disable dragging urls on iPhones because it conflicts with editing the text
        if UIDevice.current.userInterfaceIdiom != .pad {
            legacyLocationTextField.textDragInteraction?.isEnabled = false
        }

        legacyLocationTextField.applyUIMode(isPrivate: isPrivateMode)
    }

    override func becomeFirstResponder() -> Bool {
        if FeatureFlag[.newURLBar] {
            model.setEditing(to: true)
            return true
        } else {
            return self.legacyLocationTextField?.becomeFirstResponder() ?? false
        }
    }

    func removeLegacyLocationTextField() {
        legacyLocationTextField?.removeFromSuperview()
        legacyLocationTextField = nil
    }

    // Ideally we'd split this implementation in two, one URLBarView with a toolbar and one without
    // However, switching views dynamically at runtime is a difficult. For now, we just use one view
    // that can show in either mode.
    func setShowToolbar(_ shouldShow: Bool) {
        toolbarIsShowing = shouldShow
        setNeedsUpdateConstraints()
        // when we transition from portrait to landscape, calling this here causes
        // the constraints to be calculated too early and there are constraint errors
        if !toolbarIsShowing {
            updateConstraintsIfNeeded()
            if FeatureFlag[.newURLBar] {
                model.includeShareButtonInLocationView = true
            } else {
                legacyLocationView.showShareButton = true
            }
        } else {
            if FeatureFlag[.newURLBar] {
                model.includeShareButtonInLocationView = false
            } else {
                legacyLocationView.showShareButton = false
            }
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

    func updateProgressBar(_ progress: Float) {
        model.reloadButton = progress == 1 ? .reload : .stop
        progressBar.alpha = 1
        progressBar.isHidden = false
        progressBar.setProgress(progress, animated: !isTransitioning)
    }

    func hideProgressBar() {
        progressBar.isHidden = true
        progressBar.setProgress(0, animated: false)
    }

    func setLocation(_ location: String?, search: Bool) {
        if FeatureFlag[.newURLBar] {
            if let location = location {
                SearchQueryModel.shared.value = location
                model.setEditing(to: true)
            }
        } else {
            guard let text = location, !text.isEmpty else {
                legacyLocationTextField?.text = location
                return
            }
            if search {
                legacyLocationTextField?.text = text
                // Not notifying when empty agrees with AutocompleteTextField.textDidChange.
                delegate?.urlBar(self, didRestoreText: text)
            } else {
                legacyLocationTextField?.setTextWithoutSearching(text)
            }
        }
    }

    func enterOverlayMode(_ locationText: String?, pasted: Bool, search: Bool, updateModel: Bool = true) {
        if FeatureFlag[.newURLBar] {
            if updateModel {
                model.setEditing(to: true)
            }
        } else {
            legacyLocationTextField?.isHidden = false
        }

        // Show the overlay mode UI, which includes hiding the locationView and replacing it
        // with the editable locationTextField.
        animateToOverlayState(overlayMode: true)

        delegate?.urlBarDidEnterOverlayMode()

        if !FeatureFlag[.newURLBar] {
            // Bug 1193755 Workaround - Calling becomeFirstResponder before the animation happens
            // won't take the initial frame of the label into consideration, which makes the label
            // look squished at the start of the animation and expand to be correct. As a workaround,
            // we becomeFirstResponder as the next event on UI thread, so the animation starts before we
            // set a first responder.
            if pasted {
                // Clear any existing text, focus the field, then set the actual pasted text.
                // This avoids highlighting all of the text.
                self.legacyLocationTextField?.text = ""
                DispatchQueue.main.async {
                    self.legacyLocationTextField?.becomeFirstResponder()
                    self.setLocation(locationText, search: search)
                }
            } else {
                DispatchQueue.main.async {
                    self.legacyLocationTextField?.becomeFirstResponder()
                    // Need to set location again so text could be immediately selected.
                    self.setLocation(locationText, search: search)
                    if !search {
                        self.legacyLocationTextField?.selectAll(nil)
                    }
                }
            }
        }
    }

    func leaveOverlayMode(didCancel cancel: Bool = false) {
        if FeatureFlag[.newURLBar] {
            model.setEditing(to: false)
        } else {
            legacyLocationTextField?.resignFirstResponder()
        }
        animateToOverlayState(overlayMode: false, didCancel: cancel)
        delegate?.urlBarDidLeaveOverlayMode()
    }

    func prepareOverlayAnimation() {
        // Make sure everything is showing during the transition (we'll hide it afterwards).
        bringSubviewToFront(self.locationContainer)
        if !FeatureFlag[.newURLBar] {
            legacyCancelButton.isHidden = false
        }
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
        if !FeatureFlag[.newURLBar] {
            legacyLocationTextField?.leftView?.alpha = inOverlayMode ? 1 : 0
            legacyCancelButton.alpha = inOverlayMode ? 1 : 0
            legacyLocationView.contentView.alpha = inOverlayMode ? 0 : 1
        }
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
        if !FeatureFlag[.newURLBar] {
            // This ensures these can't be selected as an accessibility element when in the overlay mode.
            legacyLocationView.overrideAccessibility(enabled: !inOverlayMode)
        }

        if !FeatureFlag[.newURLBar] {
            legacyCancelButton.isHidden = !inOverlayMode
        }
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

        if !overlay, !FeatureFlag[.newURLBar] {
            legacyLocationTextField?.isHidden = true
        }

        UIView.animate(withDuration: 0.3, delay: 0.0, usingSpringWithDamping: 0.85, initialSpringVelocity: 0.0, options: [], animations: {
            self.transitionToOverlay(cancel)
            self.updateConstraints()
            self.layoutIfNeeded()
        }, completion: { _ in
            self.updateViewsForOverlayModeAndToolbarChanges()
        })
    }

    func didClickAddTab() {
        delegate?.urlBarDidPressTabs(self)
    }

    @objc func didClickCancel() {
        leaveOverlayMode(didCancel: true)
    }
}

extension LegacyURLBarView: LegacyTabToolbarProtocol {
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

    var access: [Any]? {
        get {
            if inOverlayMode {
                if FeatureFlag[.newURLBar] {
                    return [locationHost]
                } else {
                    guard let locationTextField = legacyLocationTextField else { return nil }
                    return [locationTextField, legacyCancelButton]
                }
            } else {
                if toolbarIsShowing {
                    var list = [backButton, forwardButton, neevaMenuButton, locationContainer, shareButton, addToSpacesButton, tabsButton, progressBar, toolbarNeevaMenuButton]
                    if FeatureFlag[.cardStrip] {
                        list.append(newTabButton)
                    }
                    return list
                } else {
                    return [neevaMenuButton, locationContainer, shareButton, progressBar, toolbarNeevaMenuButton]
                }
            }
        }
        set {
            super.accessibilityElements = newValue
        }
    }
}

extension LegacyURLBarView: LegacyTabLocationViewDelegate {
    func tabLocationViewReloadMenu() -> UIMenu? {
        delegate?.urlBarReloadMenu(self)
    }

    func tabLocationViewDidTapLocation(_ tabLocationView: LegacyTabLocationView) {
        let isSearchQuery = tabLocationView.displayTextIsQuery

        let overlayText: String
        if isSearchQuery {
            overlayText = tabLocationView.displayText
        } else {
            // TODO: Decode punycode hostname.
            overlayText = model.url?.absoluteString ?? ""
        }

        enterOverlayMode(overlayText, pasted: false, search: isSearchQuery)
    }

    func tabLocationViewDidLongPressLocation(_ tabLocationView: LegacyTabLocationView) {
        delegate?.urlBarDidLongPressLegacyLocation(self)
    }

    func tabLocationViewDidTapReload() {
        switch model.reloadButton {
        case .reload:
            delegate?.urlBarDidPressReload(self)
        case .stop:
            delegate?.urlBarDidPressStop(self)
        }
    }

    func tabLocationViewDidTap(shareButton: UIView) {
        self.helper?.didPress(shareButton: shareButton)
    }

    func tabLocationViewDidTapStop(_ tabLocationView: LegacyTabLocationView) {
        delegate?.urlBarDidPressStop(self)
    }

    func tabLocationViewLocationAccessibilityActions(_ tabLocationView: LegacyTabLocationView) -> [UIAccessibilityCustomAction]? {
        return delegate?.urlBarLocationAccessibilityActions(self)
    }

    func tabLocationViewDidBeginDragInteraction(_ tabLocationView: LegacyTabLocationView) {
        delegate?.urlBarDidBeginDragInteraction(self)
    }

    func tabLocationViewDidTapShield(_ tabLocationView: LegacyTabLocationView, from button: UIButton) {
        delegate?.urlBarDidTapShield(self, from: button)
    }
}

extension LegacyURLBarView: LegacyAutocompleteTextFieldDelegate {
    func legacyAutocompleteTextFieldCompletionCleared(_ autocompleteTextField: LegacyAutocompleteTextField) {
        createLegacyLeftViewFavicon()
    }

    func legacyAutocompleteTextFieldShouldReturn(_ autocompleteTextField: LegacyAutocompleteTextField) -> Bool {
        guard let text = legacyLocationTextField?.text else { return true }
        if !text.trimmingCharacters(in: .whitespaces).isEmpty {
            delegate?.urlBar(didSubmitText: text)
            return true
        } else {
            return false
        }
    }

    func legacyAutocompleteTextField(_ autocompleteTextField: LegacyAutocompleteTextField, didEnterText text: String) {
        SearchQueryModel.shared.value = text
        delegate?.urlBar(didEnterText: text)
        if text.isEmpty  {
            createLegacyLeftViewFavicon()
        }
    }

    func legacyAutocompleteTextFieldShouldClear(_ autocompleteTextField: LegacyAutocompleteTextField) -> Bool {
        SearchQueryModel.shared.value = ""
        delegate?.urlBar(didEnterText: "")
        return true
    }

    func legacyAutocompleteTextFieldDidCancel(_ autocompleteTextField: LegacyAutocompleteTextField) {
        leaveOverlayMode(didCancel: true)
    }

    func legacyAutocompletePasteAndGo(_ autocompleteTextField: LegacyAutocompleteTextField) {
        if let pasteboardContents = UIPasteboard.general.string {
            self.delegate?.urlBar(didSubmitText: pasteboardContents)
        }
    }
}

extension LegacyURLBarView: PrivateModeUI {
    func applyUIMode(isPrivate: Bool) {
        isPrivateMode = isPrivate

        neevaSuggestionModel.isIncognito = isPrivate

        if FeatureFlag[.newURLBar] {
            locationHost.applyUIMode(isPrivate: isPrivate)
        } else {
            legacyLocationView.applyUIMode(isPrivate: isPrivate)
        }
        legacyLocationTextField?.applyUIMode(isPrivate: isPrivate)

        if isPrivate {
            neevaMenuButton.setImage(neevaMenuIcon?.withRenderingMode(.alwaysTemplate), for: .normal)
        } else {
            neevaMenuButton.setImage(neevaMenuIcon, for: .normal)
        }

        neevaMenuButton.tintColor = UIColor.URLBar.neevaMenuTint(isPrivateMode)

        backgroundColor = UIColor.Browser.background
        line.backgroundColor = UIColor.Browser.urlBarDivider

        progressBar.setGradientColors(startColor: UIColor.LoadingBar.start(isPrivateMode), endColor: UIColor.LoadingBar.end(isPrivateMode))
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

class ToolbarTextField: LegacyAutocompleteTextField {
    private var isPrivateMode = false

    @objc dynamic var clearButtonTintColor: UIColor? {
        didSet {
            // Clear previous tinted image that's cache and ask for a relayout
            tintedClearImage = nil
            setNeedsLayout()
        }
    }

    fileprivate var tintedClearImage: UIImage?

    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        guard let image = UIImage.templateImageNamed("topTabs-closeTabs") else { return }
        if tintedClearImage == nil {
            if let clearButtonTintColor = clearButtonTintColor {
                tintedClearImage = image.tinted(withColor: clearButtonTintColor)
            } else {
                tintedClearImage = image
            }
        }
        // Since we're unable to change the tint color of the clear image, we need to iterate through the
        // subviews, find the clear button, and tint it ourselves.
        // https://stackoverflow.com/questions/55046917/clear-button-on-text-field-not-accessible-with-voice-over-swift
        if let clearButton = value(forKey: "_clearButton") as? UIButton {
            clearButton.setImage(tintedClearImage, for: [])

        }
    }

    // The default button size is 19x19, make this larger
    override func clearButtonRect(forBounds bounds: CGRect) -> CGRect {
        let r = super.clearButtonRect(forBounds: bounds)
        let grow: CGFloat = 16
        let r2 = CGRect(x: r.minX - grow/2, y:r.minY - grow/2, width: r.width + grow, height: r.height + grow)
        return r2
    }
}

extension ToolbarTextField: PrivateModeUI {
    func applyUIMode(isPrivate: Bool) {
        isPrivateMode = isPrivate
        backgroundColor = .clear
        textColor = UIColor.TextField.textAndTint(isPrivate: isPrivateMode)
        clearButtonTintColor = textColor
        textSelectionColor = UIColor.URLBar.textSelectionHighlight(isPrivateMode)
        tintColor = textSelectionColor.textFieldMode

        if isPrivate {
            attributedPlaceholder =
                NSAttributedString(string: .TabLocationURLPlaceholder, attributes: [NSAttributedString.Key.foregroundColor: UIColor.secondaryLabel.darkVariant])
        } else {
            attributedPlaceholder =
                NSAttributedString(string: .TabLocationURLPlaceholder, attributes: [NSAttributedString.Key.foregroundColor: UIColor.secondaryLabel])
        }
    }
}
