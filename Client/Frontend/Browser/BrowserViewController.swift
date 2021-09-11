/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import Combine
import Defaults
import Foundation
import MobileCoreServices
import Photos
import SDWebImage
import Shared
import SnapKit
import Storage
import SwiftUI
import SwiftyJSON
import UIKit
import WebKit
import XCGLogger

private let ActionSheetTitleMaxLength = 120

private enum BrowserViewControllerUX {
    static let ShowHeaderTapAreaHeight: CGFloat = 32
}

struct UrlToOpenModel {
    var url: URL?
    var isPrivate: Bool
}

class BrowserViewController: UIViewController {
    private(set) var introViewController: IntroViewController?
    private(set) var searchQueryModel = SearchQueryModel()
    private(set) var locationModel = LocationViewModel()
    private(set) lazy var suggestionModel: SuggestionModel = { [unowned self] in
        return SuggestionModel(bvc: self, profile: self.profile, queryModel: self.searchQueryModel)
    }()

    private(set) lazy var zeroQueryModel: ZeroQueryModel = {
        [unowned self] in
        let model = ZeroQueryModel(
            bvc: self,
            profile: profile,
            shareURLHandler: { url in
                let helper = ShareExtensionHelper(url: url, tab: nil)
                let controller = helper.createActivityViewController({ (_, _) in })
                controller.modalPresentationStyle = .formSheet
                self.present(controller, animated: true, completion: nil)
            })
        model.delegate = self
        return model
    }()

    let chromeModel = TabChromeModel()
    lazy var cardGridViewController: CardGridViewController = { [unowned self] in
        let controller = CardGridViewController(
            bvc: self,
            toolbarModel: SwitcherToolbarModel(
                tabManager: tabManager,
                openLazyTab: { openLazyTab(openedFrom: .tabTray) },
                createNewSpace: {
                    self.showAsModalOverlaySheet(style: .grouped) {
                        CreateSpaceOverlaySheetContent()
                            .environmentObject(self.cardGridViewController.gridModel)
                    }
                },
                onNeevaMenuAction: self.perform(neevaMenuAction:)))
        addChild(controller)
        view.addSubview(controller.view)
        controller.didMove(toParent: self)
        controller.view.isHidden = true
        controller.view.isUserInteractionEnabled = false
        return controller
    }()

    private(set) var overlaySheetViewController: UIViewController?
    private(set) lazy var simulateForwardViewController: SimulatedSwipeController? = {
        [unowned self] in
        guard FeatureFlag[.swipePlusPlus] else {
            return nil
        }
        let host = SimulatedSwipeController(
            tabManager: self.tabManager,
            chromeModel: chromeModel,
            swipeDirection: .forward,
            contentView: tabContentHost.view)
        addChild(host)
        view.addSubview(host.view)
        host.view.isHidden = true
        return host
    }()

    private(set) lazy var simulateBackViewController: SimulatedSwipeController? = {
        [unowned self] in
        let host = SimulatedSwipeController(
            tabManager: self.tabManager,
            chromeModel: chromeModel,
            swipeDirection: .back,
            contentView: tabContentHost.view)
        addChild(host)
        view.addSubview(host.view)
        host.view.isHidden = true
        return host
    }()

    private(set) lazy var tabContentHost: TabContentHost = {
        [unowned self] in
        return TabContentHost(bvc: self)
    }()

    var findInPageViewController: FindInPageViewController?
    var overlayWindowManager: WindowManager?

    private(set) var topBar: TopBarHost!

    private var clipboardBarDisplayHandler: ClipboardBarDisplayHandler?
    var readerModeBar: ReaderModeBarView?
    private(set) var readerModeCache: ReaderModeCache
    private(set) var toolbar: TabToolbarHost?
    private(set) var screenshotHelper: ScreenshotHelper!
    private var urlFromAnotherApp: UrlToOpenModel?
    private var isCrashAlertShowing: Bool = false

    // popover rotation handling
    var displayedPopoverController: UIViewController?
    var updateDisplayedPopoverProperties: (() -> Void)?

    let profile: Profile
    let tabManager: TabManager

    // This view wraps the toolbar to allow it to hide without messing up the layout
    private(set) var footer: UIView!
    fileprivate var topTouchArea: UIButton!

    // Backdrop used for displaying greyed background for private tabs
    private(set) var webViewContainerBackdrop: UIView!

    let scrollController: TabScrollingController

    fileprivate var keyboardState: KeyboardState?

    // Tracking navigation items to record history types.
    // TODO: weak references?
    private var ignoredNavigation = Set<WKNavigation>()
    private var typedNavigation = [WKNavigation: VisitType]()

    // Keep track of allowed `URLRequest`s from `webView(_:decidePolicyFor:decisionHandler:)` so
    // that we can obtain the originating `URLRequest` when a `URLResponse` is received. This will
    // allow us to re-trigger the `URLRequest` if the user requests a file to be downloaded.
    var pendingRequests = [String: URLRequest]()

    // This is set when the user taps "Download Link" from the context menu. We then force a
    // download of the next request through the `WKNavigationDelegate` that matches this web view.
    weak var pendingDownloadWebView: WKWebView?

    let downloadQueue = DownloadQueue()

    private(set) var feedbackImage: UIImage?

    /// Update the screenshot sent along with feedback. Called before opening the Neeva Menu.
    func updateFeedbackImage() {
        UIGraphicsBeginImageContextWithOptions(view.window!.bounds.size, true, 0)
        defer { UIGraphicsEndImageContext() }

        if !view.window!.drawHierarchy(in: view.window!.bounds, afterScreenUpdates: false) {
            // ???
            print("failed to draw hierarchy")
        }
        feedbackImage = UIGraphicsGetImageFromCurrentImageContext()
    }

    private var subscriptions: Set<AnyCancellable> = []

    init(profile: Profile, tabManager: TabManager) {
        self.profile = profile
        self.tabManager = tabManager
        self.readerModeCache = DiskReaderModeCache.sharedInstance
        self.scrollController = TabScrollingController(
            tabManager: tabManager, chromeModel: chromeModel)
        super.init(nibName: nil, bundle: nil)
        chromeModel.topBarDelegate = self
        chromeModel.toolbarDelegate = self
        didInit()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var prefersStatusBarHidden: Bool {
        return false
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }

    override func viewWillTransition(
        to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator
    ) {
        super.viewWillTransition(to: size, with: coordinator)

        dismissVisibleMenus()

        coordinator.animate { [self] context in
            scrollController.updateMinimumZoom()

            if let popover = displayedPopoverController {
                updateDisplayedPopoverProperties?()
                present(popover, animated: true, completion: nil)
            }

            if chromeModel.inlineToolbar {
                hideOverlaySheetViewController()
            }
        } completion: { _ in
            self.scrollController.setMinimumZoom()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    fileprivate func didInit() {
        screenshotHelper = ScreenshotHelper(controller: self)
        tabManager.addDelegate(self)
        tabManager.addNavigationDelegate(self)
        downloadQueue.delegate = self
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        .default
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        self.updateViewConstraints()
    }

    func shouldShowFooterForTraitCollection(_ previousTraitCollection: UITraitCollection) -> Bool {
        return previousTraitCollection.verticalSizeClass != .compact
            && previousTraitCollection.horizontalSizeClass != .regular
    }

    func updateToolbarStateForTraitCollection(
        _ newCollection: UITraitCollection,
        withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator? = nil
    ) {
        let showToolbar = shouldShowFooterForTraitCollection(newCollection)

        chromeModel.inlineToolbar = !showToolbar

        toolbar?.willMove(toParent: nil)
        toolbar?.view.removeFromSuperview()
        toolbar = nil

        if showToolbar {
            let toolbar = TabToolbarHost(
                isIncognito: tabManager.isIncognito, chromeModel: chromeModel,
                showNeevaMenuSheet: showNeevaMenuSheet)
            toolbar.willMove(toParent: self)
            toolbar.view.setContentHuggingPriority(.required, for: .vertical)
            footer.addSubview(toolbar.view)
            addChild(toolbar)
            self.toolbar = toolbar
        }

        view.setNeedsUpdateConstraints()

        if let tab = tabManager.selectedTab,
            let webView = tab.webView
        {
            toolbar?.applyUIMode(isPrivate: tabManager.isIncognito)
            updateURLBarDisplayURL(tab)
            chromeModel.canGoBack = webView.canGoBack
            chromeModel.canGoForward = webView.canGoForward
        }
    }

    override func willTransition(
        to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator
    ) {
        super.willTransition(to: newCollection, with: coordinator)

        // During split screen launching on iPad, this callback gets fired before viewDidLoad gets a chance to
        // set things up. Make sure to only update the toolbar state if the view is ready for it.
        if isViewLoaded {
            updateToolbarStateForTraitCollection(
                newCollection, withTransitionCoordinator: coordinator)
        }

        displayedPopoverController?.dismiss(animated: true, completion: nil)
        coordinator.animate { context in
            self.scrollController.showToolbars(animated: false)
        }
    }

    func dismissVisibleMenus() {
        displayedPopoverController?.dismiss(animated: true)
    }

    @objc func appDidEnterBackgroundNotification() {
        displayedPopoverController?.dismiss(animated: false) {
            self.updateDisplayedPopoverProperties = nil
            self.displayedPopoverController = nil
        }
    }

    @objc func tappedTopArea() {
        scrollController.showToolbars(animated: true)
    }

    @objc func appWillResignActiveNotification() {
        // Dismiss any popovers that might be visible
        displayedPopoverController?.dismiss(animated: false) {
            self.updateDisplayedPopoverProperties = nil
            self.displayedPopoverController = nil
        }

        // If we are displying a private tab, hide any elements in the tab that we wouldn't want shown
        // when the app is in the app switcher
        guard tabManager.isIncognito else {
            return
        }

        view.bringSubviewToFront(webViewContainerBackdrop)
        webViewContainerBackdrop.alpha = 1
        tabContentHost.view.alpha = 0
        presentedViewController?.popoverPresentationController?.containerView?.alpha = 0
        presentedViewController?.view.alpha = 0
    }

    @objc func appDidBecomeActiveNotification() {
        // Re-show any components that might have been hidden because they were being displayed
        // as part of a private mode tab
        UIView.animate(
            withDuration: 0.2, delay: 0, options: UIView.AnimationOptions(),
            animations: {
                self.tabContentHost.view.alpha = 1
                self.presentedViewController?.popoverPresentationController?.containerView?.alpha =
                    1
                self.presentedViewController?.view.alpha = 1
                self.view.backgroundColor = UIColor.clear
            },
            completion: { _ in
                self.webViewContainerBackdrop.alpha = 0
                self.view.sendSubviewToBack(self.webViewContainerBackdrop)
            })

        // Re-show toolbar which might have been hidden during scrolling (prior to app moving into the background)
        scrollController.showToolbars(animated: false)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(
            self, selector: #selector(appWillResignActiveNotification),
            name: UIApplication.willResignActiveNotification, object: nil)
        NotificationCenter.default.addObserver(
            self, selector: #selector(appDidBecomeActiveNotification),
            name: UIApplication.didBecomeActiveNotification, object: nil)
        NotificationCenter.default.addObserver(
            self, selector: #selector(appDidEnterBackgroundNotification),
            name: UIApplication.didEnterBackgroundNotification, object: nil)
        KeyboardHelper.defaultHelper.addDelegate(self)

        webViewContainerBackdrop = UIView()
        webViewContainerBackdrop.backgroundColor = UIColor.Photon.Ink90
        webViewContainerBackdrop.alpha = 0
        view.addSubview(webViewContainerBackdrop)

        tabContentHost.willMove(toParent: self)
        view.addSubview(tabContentHost.view)
        addChild(tabContentHost)

        topTouchArea = UIButton()
        topTouchArea.isAccessibilityElement = false
        topTouchArea.addTarget(self, action: #selector(tappedTopArea), for: .touchUpInside)
        view.addSubview(topTouchArea)

        let gridModel = self.cardGridViewController.gridModel
        let topBarHost = TopBarHost(
            isIncognito: tabManager.isIncognito,
            locationViewModel: locationModel,
            suggestionModel: suggestionModel,
            queryModel: searchQueryModel,
            gridModel: gridModel,
            trackingStatsViewModel: TrackingStatsViewModel(tabManager: tabManager),
            chromeModel: chromeModel,
            delegate: self,
            newTab: { self.openURLInNewTab(nil) },
            onCancel: { [unowned self] in
                if zeroQueryModel.isLazyTab {
                    closeLazyTab()
                } else {
                    hideZeroQuery()
                }
            })
        addChild(topBarHost)
        view.addSubview(topBarHost.view)
        topBarHost.didMove(toParent: self)
        self.topBar = topBarHost

        footer = UIView()
        view.addSubview(footer)

        clipboardBarDisplayHandler = ClipboardBarDisplayHandler(tabManager: tabManager)
        clipboardBarDisplayHandler?.bvc = self

        scrollController.readerModeBar = readerModeBar
        scrollController.header = topBar.view
        scrollController.safeAreaView = view
        scrollController.footer = footer

        self.updateToolbarStateForTraitCollection(self.traitCollection)

        setupConstraints()

        // Setup UIDropInteraction to handle dragging and dropping
        // links into the view from other apps.
        let dropInteraction = UIDropInteraction(delegate: self)
        view.addInteraction(dropInteraction)

        setNeedsStatusBarAppearanceUpdate()

        for tab in tabManager.tabs {
            // Update the `background-color` of any blank webviews.
            (tab.webView as? TabWebView)?.applyTheme()
        }
        tabManager.selectedTab?.applyTheme()

        guard
            let contentScript = self.tabManager.selectedTab?.getContentScript(
                name: ReaderMode.name())
        else { return }
        appyThemeForPreferences(contentScript: contentScript)
    }

    fileprivate func setupConstraints() {
        topBar.view.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            if !UIConstants.enableBottomURLBar {
                let headerTopConstraint = make.top.equalToSuperview().constraint
                scrollController.$headerTopOffset
                    .sink { [unowned self] in
                        headerTopConstraint.update(offset: $0)
                        view.setNeedsLayout()
                    }
                    .store(in: &subscriptions)
            }
        }

        footer.snp.makeConstraints { make in
            let footerBottomConstraint = make.bottom.equalTo(self.view.snp.bottom).constraint
            make.leading.trailing.equalTo(self.view)

            scrollController.$footerBottomOffset
                .sink { [unowned self] in
                    footerBottomConstraint.update(offset: $0)
                    view.setNeedsLayout()
                }
                .store(in: &subscriptions)
        }

        webViewContainerBackdrop.snp.makeConstraints { make in
            make.edges.equalTo(self.view)
        }

        if FeatureFlag[.swipePlusPlus] {
            simulateForwardViewController?.view.snp.makeConstraints { make in
                make.top.bottom.equalTo(tabContentHost.view)
                make.width.equalTo(tabContentHost.view).offset(SwipeUX.EdgeWidth)
                make.leading.equalTo(tabContentHost.view.snp.trailing).offset(-SwipeUX.EdgeWidth)
            }
        }

        simulateBackViewController?.view.snp.makeConstraints { make in
            make.top.bottom.equalTo(tabContentHost.view)
            make.width.equalTo(tabContentHost.view).offset(SwipeUX.EdgeWidth)
            make.trailing.equalTo(tabContentHost.view.snp.leading).offset(SwipeUX.EdgeWidth)
        }
    }

    func loadQueuedTabs(receivedURLs: [URL]? = nil) {
        // Chain off of a trivial deferred in order to run on the background queue.
        succeed().upon { res in
            self.dequeueQueuedTabs(receivedURLs: receivedURLs ?? [])
        }
    }

    fileprivate func dequeueQueuedTabs(receivedURLs: [URL]) {
        assert(!Thread.current.isMainThread, "This must be called in the background.")
        self.profile.queue.getQueuedTabs() >>== { cursor in

            // This assumes that the DB returns rows in some kind of sane order.
            // It does in practice, so WFM.
            if cursor.count > 0 {

                // Filter out any tabs received by a push notification to prevent dupes.
                let urls = cursor.compactMap { $0?.url.asURL }.filter { !receivedURLs.contains($0) }
                if !urls.isEmpty {
                    DispatchQueue.main.async {
                        self.tabManager.addTabsForURLs(urls, zombie: false)
                    }
                }

                // Clear *after* making an attempt to open. We're making a bet that
                // it's better to run the risk of perhaps opening twice on a crash,
                // rather than losing data.
                self.profile.queue.clearQueuedTabs()
            }

            // Then, open any received URLs from push notifications.
            if !receivedURLs.isEmpty {
                DispatchQueue.main.async {
                    self.tabManager.addTabsForURLs(receivedURLs, zombie: false)
                }
            }
        }
    }

    // Because crashedLastLaunch is sticky, it does not get reset, we need to remember its
    // value so that we do not keep asking the user to restore their tabs.
    private var displayedRestoreTabsAlert = false

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // On iPhone, if we are about to show the On-Boarding, blank out the tab so that it does
        // not flash before we present. This change of alpha also participates in the animation when
        // the intro view is dismissed.
        if UIDevice.current.userInterfaceIdiom == .phone {
            self.view.alpha = Defaults[.introSeen] ? 1.0 : 0.0
        }

        // config log environment variable
        ClientLogger.shared.env = EnvironmentHelper.shared.env

        if !displayedRestoreTabsAlert && !cleanlyBackgrounded() && crashedLastLaunch() {
            displayedRestoreTabsAlert = true
            showRestoreTabsAlert()
        } else {
            if !tabManager.restoreTabs() {
                if Defaults[.createNewTabOnStart] {
                    tabManager.select(tabManager.addTab())
                } else {
                    showTabTray()
                }
            }
        }

        clipboardBarDisplayHandler?.checkIfShouldDisplayBar()
    }

    fileprivate func crashedLastLaunch() -> Bool {
        return Sentry.crashedLastLaunch
    }

    fileprivate func cleanlyBackgrounded() -> Bool {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return false
        }
        return appDelegate.applicationCleanlyBackgrounded
    }

    fileprivate func showRestoreTabsAlert() {
        guard tabManager.hasTabsToRestoreAtStartup() else {
            tabManager.selectTab(tabManager.addTab())
            return
        }
        let alert = UIAlertController.restoreTabsAlert(
            okayCallback: { _ in
                self.isCrashAlertShowing = false

                if !self.tabManager.restoreTabs(true) {
                    self.showTabTray()
                }
            },
            noCallback: { _ in
                self.isCrashAlertShowing = false
                self.tabManager.selectTab(self.tabManager.addTab())
                self.openUrlAfterRestore()
            }
        )
        self.present(alert, animated: true, completion: nil)
        isCrashAlertShowing = true
    }

    override func viewDidAppear(_ animated: Bool) {
        presentIntroViewController()
        screenshotHelper.viewIsVisible = true
        screenshotHelper.takePendingScreenshots(tabManager.tabs)

        overlayWindowManager = WindowManager(parentWindow: view.window!)

        super.viewDidAppear(animated)

        showQueuedAlertIfAvailable()
    }

    fileprivate func showQueuedAlertIfAvailable() {
        if let queuedAlertInfo = tabManager.selectedTab?.dequeueJavascriptAlertPrompt() {
            let alertController = queuedAlertInfo.alertController()
            alertController.delegate = self
            present(alertController, animated: true, completion: nil)
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        screenshotHelper.viewIsVisible = false
        super.viewWillDisappear(animated)
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }

    override func updateViewConstraints() {
        super.updateViewConstraints()

        if UIConstants.enableBottomURLBar {
            topBar.view.snp.remakeConstraints { make in
                if let keyboardHeight = keyboardState?.intersectionHeightForView(self.view),
                    keyboardHeight > 0
                {
                    make.bottom.equalTo(self.view).offset(-keyboardHeight)
                } else {
                    make.bottom.equalTo(footer.snp.top)
                }
                make.leading.trailing.equalTo(self.view)
            }
        }

        topTouchArea.snp.remakeConstraints { make in
            make.top.left.right.equalTo(self.view)
            make.height.equalTo(BrowserViewControllerUX.ShowHeaderTapAreaHeight)
        }

        readerModeBar?.snp.remakeConstraints { make in
            if UIConstants.enableBottomURLBar {
                make.top.equalTo(self.view.safeArea.top)
            } else {
                make.top.equalTo(self.topBar.view.snp.bottom)
            }
            make.height.equalTo(UIConstants.ToolbarHeight)
            make.leading.trailing.equalTo(self.view)
        }

        tabContentHost.view.snp.remakeConstraints { make in
            make.left.right.equalTo(self.view)

            if let readerModeBarBottom = readerModeBar?.snp.bottom {
                make.top.equalTo(readerModeBarBottom)
            } else {
                if UIConstants.enableBottomURLBar {
                    make.top.equalTo(self.view.safeArea.top)
                } else {
                    make.top.equalTo(self.topBar.view.snp.bottom)
                }
            }

            if UIConstants.enableBottomURLBar {
                make.bottom.equalTo(self.topBar.view.snp.top)
            } else {
                if let toolbar = self.toolbar {
                    make.bottom.equalTo(toolbar.view.snp.top)
                } else {
                    make.bottom.equalTo(self.view)
                }
            }
        }

        // Setup the bottom toolbar
        toolbar?.view.snp.remakeConstraints { make in
            make.edges.equalTo(self.footer)
        }

        topBar.view.setNeedsUpdateConstraints()

        cardGridViewController.view.snp.remakeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            if shouldShowFooterForTraitCollection(traitCollection)
                && !FeatureFlag[.nativeSpaces]
            {
                make.top.equalTo(topBar.view.snp.bottom)
            } else {
                make.top.equalToSuperview()
            }
        }
    }

    public func showZeroQuery(
        openedFrom: ZeroQueryOpenedLocation? = nil,
        isLazyTab: Bool = false
    ) {
        // makes sure zeroQuery isn't already open
        guard zeroQueryModel.openedFrom == nil else { return }

        if !cardGridViewController.gridModel.isHidden {
            hideCardGrid(withAnimation: false)
        }

        if isLazyTab {
            chromeModel.triggerOverlay()
        }

        searchQueryModel.value = ""

        self.tabContentHost.updateContent(
            .showZeroQuery(
                isIncognito: tabManager.isIncognito,
                isLazyTab: isLazyTab,
                openedFrom))
    }

    public func closeLazyTab() {
        // Have to be a lazy tab to close a lazy tab
        guard self.zeroQueryModel.isLazyTab else {
            print("Tried to close lazy tab that wasn't a lazy tab")
            hideZeroQuery()
            return
        }

        DispatchQueue.main.async {
            switch self.zeroQueryModel.openedFrom {
            case .tabTray:
                self.showTabTray()
            case .createdTab:
                self.tabManager.close(self.tabManager.selectedTab!)
            default:
                break
            }

            self.hideZeroQuery()
            self.zeroQueryModel.reset(bvc: self)
        }
    }

    public func hideZeroQuery() {
        guard !(InternalURL(tabManager.selectedTab?.url)?.isZeroQueryURL ?? false) else {
            print("Tried to hide zero query on a zero query tab")
            return
        }

        chromeModel.setEditingLocation(to: false)
        zeroQueryModel.reset(bvc: self)

        DispatchQueue.main.async {
            self.tabContentHost.updateContent(.hideZeroQuery)

            // Refresh the reading view toolbar since the article record may have changed
            if let readerMode = self.tabManager.selectedTab?.getContentScript(
                name: ReaderMode.name()) as? ReaderMode, readerMode.state == .active
            {
                self.showReaderModeBar(animated: false)
            }
        }
    }

    fileprivate func updateInZeroQuery(_ url: URL?) {
        let isZeroQueryURL = url.flatMap { InternalURL($0)?.isZeroQueryURL } ?? false
        if !chromeModel.isEditingLocation {
            guard let url = url else {
                hideZeroQuery()
                return
            }

            if isZeroQueryURL {
                showZeroQuery()
            } else if !url.absoluteString.hasPrefix(
                "\(InternalURL.baseUrl)/\(SessionRestoreHandler.path)")
            {
                hideZeroQuery()
            }
        } else if isZeroQueryURL {
            showZeroQuery()
        }
    }

    private func showOverlaySheetViewController(_ overlaySheetViewController: UIViewController) {
        hideOverlaySheetViewController()

        addChild(overlaySheetViewController)
        setOverrideTraitCollection(
            UITraitCollection(userInterfaceLevel: .elevated), forChild: overlaySheetViewController)
        view.addSubview(overlaySheetViewController.view)

        overlaySheetViewController.view.snp.makeConstraints { make in
            make.edges.equalTo(self.view)
        }

        overlaySheetViewController.didMove(toParent: self)

        self.overlaySheetViewController = overlaySheetViewController

        UIAccessibility.post(
            notification: .screenChanged, argument: overlaySheetViewController.view)
    }

    private func hideOverlaySheetViewController() {
        if let overlaySheetViewController = self.overlaySheetViewController {
            overlaySheetViewController.willMove(toParent: nil)
            overlaySheetViewController.view.removeFromSuperview()
            overlaySheetViewController.removeFromParent()
            self.overlaySheetViewController = nil
        }
    }

    func showAsModalOverlaySheet<Content: View>(
        style: OverlaySheetStyle, content: @escaping () -> Content,
        onDismiss: (() -> Void)? = nil
    ) {
        var controller: UIViewController? = nil
        controller = OverlaySheetViewController(
            style: style, content: { AnyView(erasing: content()) },
            onDismiss: {
                if controller == self.overlaySheetViewController {
                    self.hideOverlaySheetViewController()
                }
                onDismiss?()
            },
            onOpenURL: { url in
                if controller == self.overlaySheetViewController {
                    self.hideOverlaySheetViewController()
                }
                self.openURLInNewTabPreservingIncognitoState(url)
            })
        showOverlaySheetViewController(controller!)
    }

    func finishEditingAndSubmit(_ url: URL, visitType: VisitType, forTab tab: Tab?) {
        if !tabContentHost.promoteToRealTabIfNecessary(
            url: url, tabManager: tabManager, selectedTabIsNil: tab == nil)
        {
            if FeatureFlag[.createOrSwitchToTab] {
                hideZeroQuery()
                tabManager.createOrSwitchToTab(for: url)
            } else if let tab = tab, let nav = tab.loadRequest(URLRequest(url: url)) {
                self.recordNavigationInTab(tab, navigation: nav, visitType: visitType)
            }
        }

        locationModel.url = url
        chromeModel.setEditingLocation(to: false)
    }

    override func accessibilityPerformEscape() -> Bool {
        if chromeModel.isEditingLocation {
            chromeModel.setEditingLocation(to: false)
            return true
        } else if let selectedTab = tabManager.selectedTab, selectedTab.canGoBack {
            selectedTab.goBack()
            return true
        }
        return false
    }

    func updateUIForReaderHomeStateForTab(_ tab: Tab) {
        updateURLBarDisplayURL(tab)
        scrollController.showToolbars(animated: false)

        if let url = tab.url {
            if url.isReaderModeURL {
                showReaderModeBar(animated: false)
                NotificationCenter.default.addObserver(
                    self, selector: #selector(dynamicFontChanged), name: .DynamicFontChanged,
                    object: nil)
            } else {
                hideReaderModeBar(animated: false)
                NotificationCenter.default.removeObserver(
                    self, name: .DynamicFontChanged, object: nil)
            }

            updateInZeroQuery(url as URL)
        }
    }

    /// Updates the URL bar text and button states.
    /// Call this whenever the page URL changes.
    fileprivate func updateURLBarDisplayURL(_ tab: Tab) {
        locationModel.url = tab.url?.displayURL
        chromeModel.isPage = tab.url?.displayURL?.isWebPage() ?? false
    }

    // MARK: Opening New Tabs
    func switchToTabForURLOrOpen(_ url: URL, isPrivate: Bool = false) {
        guard !isCrashAlertShowing else {
            urlFromAnotherApp = UrlToOpenModel(url: url, isPrivate: isPrivate)
            return
        }

        popToBVC()

        if let tab = tabManager.getTabForURL(url) {
            tabManager.selectTab(tab)
        } else {
            openURLInNewTab(url, isPrivate: isPrivate)
        }
    }

    func switchToTabForWidgetURLOrOpen(_ url: URL, uuid: String, isPrivate: Bool = false) {
        guard !isCrashAlertShowing else {
            urlFromAnotherApp = UrlToOpenModel(url: url, isPrivate: isPrivate)
            return
        }
        popToBVC()
        if let tab = tabManager.getTabForUUID(uuid: uuid) {
            tabManager.selectTab(tab)
        } else {
            openURLInNewTab(url, isPrivate: isPrivate)
        }
    }

    func openURLInNewTab(_ url: URL?, isPrivate: Bool = false) {
        if let selectedTab = tabManager.selectedTab {
            screenshotHelper.takeScreenshot(selectedTab)
        }
        let request: URLRequest?
        if let url = url {
            request = URLRequest(url: url)
        } else {
            request = nil
        }

        DispatchQueue.main.async {
            self.tabManager.selectTab(self.tabManager.addTab(request, isPrivate: isPrivate))
            self.cardGridViewController.gridModel.hideWithNoAnimation()
        }
    }

    func openURLInNewTabPreservingIncognitoState(_ url: URL) {
        let isPrivate = tabManager.isIncognito
        self.openURLInNewTab(url, isPrivate: isPrivate)
    }

    func openBlankNewTab(focusLocationField: Bool, isPrivate: Bool = false) {
        popToBVC()

        let newTab = tabManager.addTab(isPrivate: isPrivate)
        tabManager.select(newTab)

        if focusLocationField {
            chromeModel.setEditingLocation(to: true)
        }
    }

    func openLazyTab(
        openedFrom: ZeroQueryOpenedLocation = .openTab(nil), switchToIncognitoMode: Bool? = nil
    ) {
        if let switchToIncognitoMode = switchToIncognitoMode {
            tabManager.setIncognitoMode(to: switchToIncognitoMode)
        }

        showZeroQuery(openedFrom: openedFrom, isLazyTab: true)
    }

    func openSearchNewTab(isPrivate: Bool = false, _ text: String) {
        popToBVC()
        if let searchURL = neevaSearchEngine.searchURLForQuery(text) {
            openURLInNewTab(searchURL, isPrivate: isPrivate)
        } else {
            // We still don't have a valid URL, so something is broken. Give up.
            print("Error handling URL entry: \"\(text)\".")
            assertionFailure("Couldn't generate search URL: \(text)")
        }
    }

    fileprivate func popToBVC() {
        if !cardGridViewController.gridModel.isHidden {
            cardGridViewController.gridModel.hideWithNoAnimation()
        }

        if let presentedViewController = presentedViewController {
            presentedViewController.dismiss(animated: true, completion: nil)
        } else if chromeModel.isEditingLocation {
            chromeModel.setEditingLocation(to: false)
        }
    }

    func presentActivityViewController(
        _ url: URL, tab: Tab? = nil, sourceView: UIView?, sourceRect: CGRect,
        arrowDirection: UIPopoverArrowDirection
    ) {
        let helper = ShareExtensionHelper(url: url, tab: tab)

        var appActivities = [UIActivity]()

        let deferredSites = self.profile.history.isPinnedTopSite(tab?.url?.absoluteString ?? "")

        let isPinned = deferredSites.value.successValue ?? false

        if FeatureFlag[.pinToTopSites] {
            var topSitesActivity: PinToTopSitesActivity
            if isPinned == false {
                topSitesActivity = PinToTopSitesActivity(isPinned: isPinned) { [weak tab] in
                    guard let url = tab?.url?.displayURL,
                        let sql = self.profile.history as? SQLiteHistory
                    else { return }

                    sql.getSites(forURLs: [url.absoluteString]).bind { val -> Success in
                        guard let site = val.successValue?.asArray().first?.flatMap({ $0 }) else {
                            return succeed()
                        }
                        return self.profile.history.addPinnedTopSite(site)
                    }.uponQueue(.main) { result in
                        if result.isSuccess {
                            if let toastManager = self.getSceneDelegate()?.toastViewManager {
                                toastManager.makeToast(
                                    text: Strings.AppMenuAddPinToTopSitesConfirmMessage
                                ).enqueue(manager: toastManager)
                            }
                        }
                    }
                }
            } else {
                topSitesActivity = PinToTopSitesActivity(isPinned: isPinned) { [weak tab] in
                    guard let url = tab?.url?.displayURL,
                        let sql = self.profile.history as? SQLiteHistory
                    else { return }

                    sql.getSites(forURLs: [url.absoluteString]).bind { val -> Success in
                        guard let site = val.successValue?.asArray().first?.flatMap({ $0 }) else {
                            return succeed()
                        }

                        return self.profile.history.removeFromPinnedTopSites(site)
                    }.uponQueue(.main) { result in
                        if result.isSuccess {
                            if let toastManager = self.getSceneDelegate()?.toastViewManager {
                                toastManager.makeToast(
                                    text: Strings.AppMenuRemovePinFromTopSitesConfirmMessage
                                ).enqueue(manager: toastManager)
                            }
                        }
                    }
                }
            }
            appActivities.append(topSitesActivity)
        }

        let controller = helper.createActivityViewController(appActivities: appActivities) {
            [unowned self] completed, _ in
            // After dismissing, check to see if there were any prompts we queued up
            self.showQueuedAlertIfAvailable()

            // Usually the popover delegate would handle nil'ing out the references we have to it
            // on the BVC when displaying as a popover but the delegate method doesn't seem to be
            // invoked on iOS 10. See Bug 1297768 for additional details.
            self.displayedPopoverController = nil
            self.updateDisplayedPopoverProperties = nil
        }

        if let popoverPresentationController = controller.popoverPresentationController {
            popoverPresentationController.sourceView = sourceView
            popoverPresentationController.sourceRect = sourceRect
            popoverPresentationController.permittedArrowDirections = arrowDirection
            popoverPresentationController.delegate = self
        }

        present(controller, animated: true, completion: nil)
    }

    fileprivate func postLocationChangeNotificationForTab(_ tab: Tab, navigation: WKNavigation?) {
        let notificationCenter = NotificationCenter.default
        var info = [AnyHashable: Any]()
        info["url"] = tab.url?.displayURL
        info["title"] = tab.title
        if let visitType = self.getVisitTypeForTab(tab, navigation: navigation)?.rawValue {
            info["visitType"] = visitType
        }
        info["isPrivate"] = tabManager.isIncognito
        notificationCenter.post(name: .OnLocationChange, object: self, userInfo: info)
    }

    /// Enum to represent the WebView observation or delegate that triggered calling `navigateInTab`
    enum WebViewUpdateStatus {
        case title
        case url
        case finishedNavigation
    }

    func navigateInTab(
        tab: Tab, to navigation: WKNavigation? = nil, webViewStatus: WebViewUpdateStatus
    ) {
        guard let webView = tab.webView else {
            print("Cannot navigate in tab without a webView")
            return
        }

        if let url = webView.url {
            if tab === tabManager.selectedTab {
                chromeModel.isPage = tab.url?.displayURL?.isWebPage() ?? false
            }

            if !InternalURL.isValid(url: url) || url.isReaderModeURL, !url.isFileURL {
                postLocationChangeNotificationForTab(tab, navigation: navigation)

                webView.evaluateJavascriptInDefaultContentWorld(
                    "\(ReaderModeNamespace).checkReadability()")
            }

            TabEvent.post(.didChangeURL(url), for: tab)
        }

        // Represents WebView observation or delegate update that called this function
        switch webViewStatus {
        case .title, .url, .finishedNavigation:
            // Workaround for issue #1562. It's not safe to insert a WebView into a View hierarchy
            // directly from a property change event. There could be a lot of WebKit code on the
            // stack at this point.
            DispatchQueue.main.async {
                if tab !== self.tabManager.selectedTab, let webView = tab.webView {
                    // To Screenshot a tab that is hidden we must add the webView,
                    // then wait enough time for the webview to render.
                    self.view.insertSubview(webView, at: 0)

                    // This is kind of a hacky fix for Bug 1476637 to prevent webpages from focusing
                    // the touch-screen keyboard from the background even though they shouldn't be
                    // able to.
                    webView.resignFirstResponder()

                    // We need a better way of identifying when webviews are finished rendering
                    // There are cases in which the page will still show a loading animation or
                    // nothing when the screenshot is being taken, depending on internet connection
                    // Issue created: https://github.com/mozilla-mobile/firefox-ios/issues/7003
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        self.screenshotHelper.takeScreenshot(tab)
                        if webView.superview == self.view {
                            webView.removeFromSuperview()
                        }
                    }
                }
            }
        }
    }

    func showTabTray() {
        // log show tap tray
        ClientLogger.shared.logCounter(
            .ShowTabTray, attributes: EnvironmentHelper.shared.getAttributes())

        Sentry.shared.clearBreadcrumbs()

        updateFindInPageVisibility(visible: false)
        cardGridViewController.gridModel.pickerHeight =
            topBar.view.frame.height - view.safeAreaInsets.top

        cardGridViewController.gridModel.show()

        if let tab = tabManager.selectedTab {
            screenshotHelper.takeScreenshot(tab)
        }
    }

    func hideCardGrid(withAnimation: Bool) {
        if withAnimation {
            cardGridViewController.gridModel.hideWithAnimation()
        } else {
            cardGridViewController.gridModel.hideWithNoAnimation()
        }
    }
}

// MARK: URL Bar Delegate support code
extension BrowserViewController {
    func urlBarDidEnterOverlayMode() {
        if !cardGridViewController.gridModel.isHidden {
            openLazyTab(openedFrom: .tabTray)
        } else {
            showZeroQuery(openedFrom: .openTab(tabManager.selectedTab))
        }
    }

    func urlBarDidLeaveOverlayMode() {
        updateInZeroQuery(tabManager.selectedTab?.url as URL?)
    }
}

/// History visit management.
/// TODO: this should be expanded to track various visit types; see Bug 1166084.
extension BrowserViewController {
    func ignoreNavigationInTab(_ tab: Tab, navigation: WKNavigation) {
        self.ignoredNavigation.insert(navigation)
    }

    func recordNavigationInTab(_ tab: Tab, navigation: WKNavigation, visitType: VisitType) {
        self.typedNavigation[navigation] = visitType
    }

    /// Untrack and do the right thing.
    func getVisitTypeForTab(_ tab: Tab, navigation: WKNavigation?) -> VisitType? {
        guard let navigation = navigation else {
            // See https://github.com/WebKit/webkit/blob/master/Source/WebKit2/UIProcess/Cocoa/NavigationState.mm#L390
            return VisitType.link
        }

        if let _ = self.ignoredNavigation.remove(navigation) {
            return nil
        }

        return self.typedNavigation.removeValue(forKey: navigation) ?? VisitType.link
    }
}

extension BrowserViewController: TabDelegate {

    private func subscribe(to webView: WKWebView, for tab: Tab) {
        let updateGestureHandler = {
            if let helper = tab.getContentScript(name: ContextMenuHelper.name())
                as? ContextMenuHelper
            {
                // This is zero-cost if already installed. It needs to be checked frequently (hence every event here triggers this function), as when a new tab is created it requires multiple attempts to setup the handler correctly.
                helper.replaceGestureHandlerIfNeeded()
            }
        }

        let tabManager = tabManager

        // Observers that live as long as the tab. They are all cancelled in Tab/close(),
        // so it is safe to use a strong reference to self.

        let estimatedProgressPub = webView.publisher(for: \.estimatedProgress, options: .new)
        let isLoadingPub = webView.publisher(for: \.isLoading, options: .new)
        estimatedProgressPub.combineLatest(isLoadingPub)
            .forEach(updateGestureHandler)
            .filter { _ in tab === tabManager.selectedTab }
            .sink { [self] (estimatedProgress, isLoading) in
                // When done loading, we want to set progress to 1 so that we allow the progress
                // complete animation to happen. But we want to avoid showing incomplete progress
                // when no longer loading (as may happen when a page load is interrupted).
                if let url = webView.url, !InternalURL.isValid(url: url) {
                    if isLoading {
                        chromeModel.estimatedProgress = estimatedProgress
                    } else if estimatedProgress == 1 && chromeModel.estimatedProgress != 1 {
                        chromeModel.estimatedProgress = 1
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                            if chromeModel.estimatedProgress == 1 {
                                chromeModel.estimatedProgress = nil
                            }
                        }
                    } else {
                        chromeModel.estimatedProgress = nil
                    }
                } else {
                    chromeModel.estimatedProgress = nil
                }
            }
            .store(in: &tab.webViewSubscriptions)

        webView.publisher(for: \.url, options: .new)
            .forEach(updateGestureHandler)
            // Special case for "about:blank" popups, if the webView.url is nil, keep the tab url as "about:blank"
            .filter { tab.url != .aboutBlank || $0 != nil }
            // To prevent spoofing, only change the URL immediately if the new URL is on
            // the same origin as the current URL. Otherwise, do nothing and wait for
            // didCommitNavigation to confirm the page load.
            .filter { tab.url?.origin == $0?.origin }
            .sink { [self] url in
                tab.setURL(url)

                if tab === tabManager.selectedTab && !tab.restoring {
                    updateUIForReaderHomeStateForTab(tab)
                }
                // Catch history pushState navigation, but ONLY for same origin navigation,
                // for reasons above about URL spoofing risk.
                navigateInTab(tab: tab, webViewStatus: .url)
            }
            .store(in: &tab.webViewSubscriptions)

        webView.publisher(for: \.title, options: .new)
            .forEach(updateGestureHandler)
            .compactMap { $0 }
            // Ensure that the tab title *actually* changed to prevent repeated calls
            // to navigateInTab(tab:).
            .filter { !$0.isEmpty && $0 != tab.lastTitle }
            .sink { [self] title in
                tab.lastTitle = title
                navigateInTab(tab: tab, webViewStatus: .title)
            }
            .store(in: &tab.webViewSubscriptions)

        webView.publisher(for: \.canGoBack, options: .new)
            .forEach(updateGestureHandler)
            .filter { _ in tab === tabManager.selectedTab }
            .assign(to: \.canGoBack, on: chromeModel)
            .store(in: &tab.webViewSubscriptions)

        webView.publisher(for: \.canGoForward, options: .new)
            .forEach(updateGestureHandler)
            .filter { _ in tab === tabManager.selectedTab }
            .assign(to: \.canGoForward, on: chromeModel)
            .store(in: &tab.webViewSubscriptions)

        webView.scrollView
            .publisher(for: \.contentSize, options: .new)
            .sink { _ in
                self.scrollController.contentSizeDidChange()
            }
            .store(in: &tab.webViewSubscriptions)
    }

    func tab(_ tab: Tab, didCreateWebView webView: WKWebView) {
        webView.frame = tabContentHost.view.frame
        webView.uiDelegate = self

        self.subscribe(to: webView, for: tab)

        let formPostHelper = FormPostHelper(tab: tab)
        tab.addContentScript(formPostHelper, name: FormPostHelper.name())

        let readerMode = ReaderMode(tab: tab)
        readerMode.delegate = self
        tab.addContentScript(readerMode, name: ReaderMode.name())

        // only add the logins helper if the tab is not a private browsing tab
        if !tabManager.isIncognito {
            let logins = LoginsHelper(tab: tab, profile: profile)
            tab.addContentScript(logins, name: LoginsHelper.name())
        }

        let contextMenuHelper = ContextMenuHelper(tab: tab)
        contextMenuHelper.delegate = self
        tab.addContentScript(contextMenuHelper, name: ContextMenuHelper.name())

        let errorHelper = ErrorPageHelper(certStore: profile.certStore)
        tab.addContentScript(errorHelper, name: ErrorPageHelper.name())

        let sessionRestoreHelper = SessionRestoreHelper(tab: tab)
        sessionRestoreHelper.delegate = self
        tab.addContentScript(sessionRestoreHelper, name: SessionRestoreHelper.name())

        let findInPageHelper = FindInPageHelper(tab: tab)
        findInPageHelper.delegate = self
        tab.addContentScript(findInPageHelper, name: FindInPageHelper.name())

        let downloadContentScript = DownloadContentScript(tab: tab)
        tab.addContentScript(downloadContentScript, name: DownloadContentScript.name())

        let printHelper = PrintHelper(tab: tab)
        tab.addContentScript(printHelper, name: PrintHelper.name())

        tab.addContentScript(LocalRequestHelper(), name: LocalRequestHelper.name())

        let blocker = NeevaTabContentBlocker(tab: tab)
        tab.contentBlocker = blocker
        tab.addContentScript(blocker, name: NeevaTabContentBlocker.name())

        tab.addContentScript(FocusHelper(tab: tab), name: FocusHelper.name())

        let webuiMessageHelper = WebUIMessageHelper(tab: tab, webView: webView)
        tab.addContentScript(webuiMessageHelper, name: WebUIMessageHelper.name())
    }

    func tab(_ tab: Tab, didSelectAddToSpaceForSelection selection: String) {
        showAddToSpacesSheet(url: tab.url!, title: tab.displayTitle, description: selection)
    }

    func tab(_ tab: Tab, didSelectFindInPageForSelection selection: String) {
        updateFindInPageVisibility(visible: true, query: selection)
    }

    func tab(_ tab: Tab, didSelectSearchWithNeevaForSelection selection: String) {
        openSearchNewTab(isPrivate: tabManager.isIncognito, selection)
    }
}

extension BrowserViewController: HistoryPanelDelegate {
    func libraryPanel(didSelectURL url: URL, visitType: VisitType) {
        finishEditingAndSubmit(url, visitType: visitType, forTab: tabManager.selectedTab)
        presentedViewController?.dismiss(animated: true, completion: nil)
    }
}

extension BrowserViewController: ZeroQueryPanelDelegate {
    func zeroQueryPanelDidRequestToSaveToSpace(_ url: URL, title: String?, description: String?) {
        chromeModel.setEditingLocation(to: false)
        showAddToSpacesSheet(url: url, title: title, description: description)
    }

    func zeroQueryPanel(didSelectURL url: URL, visitType: VisitType) {
        finishEditingAndSubmit(url, visitType: visitType, forTab: tabManager.selectedTab)
    }

    func zeroQueryPanelDidRequestToOpenInNewTab(_ url: URL, isPrivate: Bool) {
        hideZeroQuery()

        let tab = self.tabManager.addTab(
            URLRequest(url: url), afterTab: self.tabManager.selectedTab, isPrivate: isPrivate)

        // We're not showing the top tabs; show a toast to quick switch to the fresh new tab.
        if let toastManager = getSceneDelegate()?.toastViewManager {
            toastManager.makeToast(
                text: Strings.ContextMenuButtonToastNewTabOpenedLabelText,
                buttonText: Strings.ContextMenuButtonToastNewTabOpenedButtonText,
                buttonAction: {
                    self.tabManager.selectTab(tab)
                }
            ).enqueue(manager: toastManager)
        }
    }

    func zeroQueryPanel(didEnterQuery query: String) {
        searchQueryModel.value = query
        chromeModel.setEditingLocation(to: true)
    }
}

extension BrowserViewController: TabManagerDelegate {
    func tabManager(
        _ tabManager: TabManager, didSelectedTabChange selected: Tab?, previous: Tab?,
        isRestoring: Bool, updateZeroQuery: Bool
    ) {
        presentedViewController?.dismiss(animated: false, completion: nil)

        // Remove the old accessibilityLabel. Since this webview shouldn't be visible, it doesn't need it
        // and having multiple views with the same label confuses tests.
        if let wv = previous?.webView {
            wv.endEditing(true)
            wv.accessibilityLabel = nil
            wv.accessibilityElementsHidden = true
            wv.accessibilityIdentifier = nil
        }

        if let tab = selected, let webView = tab.webView {
            updateURLBarDisplayURL(tab)

            if previous == nil || tab.isIncognito != previous?.isIncognito {
                let ui: [PrivateModeUI?] = [toolbar, topBar, tabContentHost]
                ui.forEach { $0?.applyUIMode(isPrivate: tab.isIncognito) }
            }

            readerModeCache =
                tab.isIncognito
                ? MemoryReaderModeCache.sharedInstance : DiskReaderModeCache.sharedInstance
            ReaderModeHandlers.readerModeCache = readerModeCache

            // This is a terrible workaround for a bad iOS 12 bug where PDF
            // content disappears any time the view controller changes (i.e.
            // the user taps on the tabs tray). It seems the only way to get
            // the PDF to redraw is to either reload it or revisit it from
            // back/forward list. To try and avoid hitting the network again
            // for the same PDF, we revisit the current back/forward item and
            // restore the previous scrollview zoom scale and content offset
            // after a short 100ms delay. *facepalm*
            //
            // https://bugzilla.mozilla.org/show_bug.cgi?id=1516524
            if tab.temporaryDocument?.mimeType == MIMEType.PDF {
                let previousZoomScale = webView.scrollView.zoomScale
                let previousContentOffset = webView.scrollView.contentOffset

                if let currentItem = webView.backForwardList.currentItem {
                    webView.go(to: currentItem)
                }

                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    webView.scrollView.setZoomScale(previousZoomScale, animated: false)
                    webView.scrollView.setContentOffset(previousContentOffset, animated: false)
                }
            }

            webView.accessibilityLabel = .WebViewAccessibilityLabel
            webView.accessibilityIdentifier = "contentView"
            webView.accessibilityElementsHidden = false

            if webView.url == nil {
                // The web view can go gray if it was zombified due to memory pressure.
                // When this happens, the URL is nil, so try restoring the page upon selection.
                tab.reload()
            }
        }

        updateFindInPageVisibility(visible: false, tab: previous)
        chromeModel.canGoBack =
            (simulateBackViewController?.canGoBack() ?? false
                || selected?.canGoBack ?? false)
        chromeModel.canGoForward =
            (simulateForwardViewController?.canGoForward() ?? false
                || selected?.canGoForward ?? false)
        if let url = selected?.webView?.url, !InternalURL.isValid(url: url) {
            if selected?.isLoading ?? false {
                chromeModel.estimatedProgress = selected?.estimatedProgress
            } else {
                chromeModel.estimatedProgress = nil
            }
        }

        if let readerMode = selected?.getContentScript(name: ReaderMode.name()) as? ReaderMode {
            locationModel.readerMode = readerMode.state
            if readerMode.state == .active {
                showReaderModeBar(animated: false)
            } else {
                hideReaderModeBar(animated: false)
            }
        } else {
            locationModel.readerMode = .unavailable
        }

        if updateZeroQuery {
            updateInZeroQuery(selected?.url as URL?)
        }
    }

    func tabManager(_: TabManager, didAddTab tab: Tab, isRestoring: Bool) {
        tab.tabDelegate = self
    }

    func tabManager(_ tabManager: TabManager, didRemoveTab tab: Tab, isRestoring: Bool) {}

    func tabManagerDidAddTabs(_ tabManager: TabManager) {

    }

    func tabManagerDidRestoreTabs(_ tabManager: TabManager) {
        openUrlAfterRestore()
    }

    func openUrlAfterRestore() {
        guard let url = urlFromAnotherApp?.url else { return }
        openURLInNewTab(url, isPrivate: urlFromAnotherApp?.isPrivate ?? false)
        urlFromAnotherApp = nil
    }

    func tabManagerDidRemoveAllTabs(_ tabManager: TabManager) {}

    func getSceneDelegate() -> SceneDelegate? {
        SceneDelegate.getCurrentSceneDelegate(for: self.view)
    }
}

// MARK: - UIPopoverPresentationControllerDelegate

extension BrowserViewController: UIPopoverPresentationControllerDelegate {
    func popoverPresentationControllerDidDismissPopover(
        _ popoverPresentationController: UIPopoverPresentationController
    ) {
        displayedPopoverController = nil
        updateDisplayedPopoverProperties = nil
    }
}

extension BrowserViewController: UIAdaptivePresentationControllerDelegate {
    // Returning None here makes sure that the Popover is actually presented as a Popover and
    // not as a full-screen modal, which is the default on compact device classes.
    func adaptivePresentationStyle(
        for controller: UIPresentationController, traitCollection: UITraitCollection
    ) -> UIModalPresentationStyle {
        return .none
    }
}

extension BrowserViewController {
    func presentIntroViewController(_ alwaysShow: Bool = false) {
        if alwaysShow || !Defaults[.introSeen] {
            showProperIntroVC()
        }
    }

    // Default browser onboarding
    func presentDBOnboardingViewController(_ force: Bool = false) {
        let onboardingVC = DefaultBrowserOnboardingViewController(didOpenSettings: {
            [unowned self] in
            zeroQueryModel.updateState()
        })

        onboardingVC.modalPresentationStyle = .formSheet
        present(onboardingVC, animated: true, completion: nil)
    }

    private func showProperIntroVC() {
        introViewController = IntroViewController()

        introViewController!.didFinishClosure = { controller in
            Defaults[.introSeen] = true
            controller.dismiss(animated: true)
            self.introViewController = nil
        }

        introViewController!.visitHomePage = visitHomePage
        introViewController!.visitSigninPage = visitSigninPage
        introViewController!.visitAppleAuthPage = visitAppleAuthPage(authURL:)
        introViewController!.skipToBrowser = skipToBrowser

        self.introVCPresentHelper(introViewController: introViewController!)
    }

    private func visitHomePage() {
        openURLInNewTab(NeevaConstants.appSignupURL)
    }

    private func visitSigninPage() {
        openURLInNewTab(NeevaConstants.appSigninURL)
    }

    private func visitAppleAuthPage(authURL: URL) {
        if let tab = self.tabManager.selectedTab {
            tab.loadRequest(URLRequest(url: authURL))
        }
    }

    private func skipToBrowser() {
        openURLInNewTab(URL(string: "https://neeva.com"))
    }

    private func introVCPresentHelper(introViewController: UIViewController) {
        // On iPad we present it modally in a controller
        if traitCollection.horizontalSizeClass == .regular
            && traitCollection.verticalSizeClass == .regular
        {
            introViewController.preferredContentSize = CGSize(width: 375, height: 667)
            introViewController.modalPresentationStyle = .formSheet
        } else {
            introViewController.modalPresentationStyle = .fullScreen
        }
        present(introViewController, animated: true)
    }

}

extension BrowserViewController: ContextMenuHelperDelegate {
    func contextMenuHelper(
        _ contextMenuHelper: ContextMenuHelper,
        didLongPressElements elements: ContextMenuHelper.Elements,
        gestureRecognizer: UIGestureRecognizer
    ) {
        // locationInView can return (0, 0) when the long press is triggered in an invalid page
        // state (e.g., long pressing a link before the document changes, then releasing after a
        // different page loads).
        let touchPoint = gestureRecognizer.location(in: view)
        guard touchPoint != CGPoint.zero else { return }

        let touchSize = CGSize(width: 0, height: 16)

        let actionSheetController = AlertController(
            title: nil, message: nil, preferredStyle: .actionSheet)
        var dialogTitle: String?

        if let url = elements.link, let currentTab = tabManager.selectedTab {
            dialogTitle = url.absoluteString
            let isPrivate = tabManager.isIncognito
            screenshotHelper.takeDelayedScreenshot(currentTab)

            let addTab = { (rURL: URL, isPrivate: Bool) in
                let tab = self.tabManager.addTab(
                    URLRequest(url: rURL as URL), afterTab: currentTab, isPrivate: isPrivate)

                // We're not showing the top tabs; show a toast to quick switch to the fresh new tab.
                if let toastManager = self.getSceneDelegate()?.toastViewManager {
                    toastManager.makeToast(
                        text: Strings.ContextMenuButtonToastNewTabOpenedLabelText,
                        buttonText: Strings.ContextMenuButtonToastNewTabOpenedButtonText,
                        buttonAction: {
                            self.tabManager.selectTab(tab)
                        }
                    ).enqueue(manager: toastManager)
                }
            }

            if !isPrivate {
                let openNewTabAction = UIAlertAction(
                    title: Strings.ContextMenuOpenInNewTab, style: .default
                ) { _ in
                    addTab(url, false)
                }
                actionSheetController.addAction(
                    openNewTabAction, accessibilityIdentifier: "linkContextMenu.openInNewTab")
            }

            let openNewPrivateTabAction = UIAlertAction(
                title: Strings.ContextMenuOpenInNewIncognitoTab, style: .default
            ) { _ in
                addTab(url, true)
            }
            actionSheetController.addAction(
                openNewPrivateTabAction,
                accessibilityIdentifier: "linkContextMenu.openInNewPrivateTab")

            let downloadAction = UIAlertAction(
                title: Strings.ContextMenuDownloadLink, style: .default
            ) { _ in
                // This checks if download is a blob, if yes, begin blob download process
                if !DownloadContentScript.requestBlobDownload(url: url, tab: currentTab) {
                    //if not a blob, set pendingDownloadWebView and load the request in the webview, which will trigger the WKWebView navigationResponse delegate function and eventually downloadHelper.open()
                    self.pendingDownloadWebView = currentTab.webView
                    let request = URLRequest(url: url)
                    currentTab.webView?.load(request)
                }
            }
            actionSheetController.addAction(
                downloadAction, accessibilityIdentifier: "linkContextMenu.download")

            let copyAction = UIAlertAction(title: Strings.ContextMenuCopyLink, style: .default) {
                _ in
                UIPasteboard.general.url = url as URL
            }
            actionSheetController.addAction(
                copyAction, accessibilityIdentifier: "linkContextMenu.copyLink")

            let shareAction = UIAlertAction(title: Strings.ContextMenuShareLink, style: .default) {
                _ in
                self.presentActivityViewController(
                    url as URL, sourceView: self.view,
                    sourceRect: CGRect(origin: touchPoint, size: touchSize), arrowDirection: .any)
            }
            actionSheetController.addAction(
                shareAction, accessibilityIdentifier: "linkContextMenu.share")
        }

        if let url = elements.image {
            if dialogTitle == nil {
                dialogTitle = elements.title ?? url.absoluteString
            }

            let saveImageAction = UIAlertAction(
                title: Strings.ContextMenuSaveImage, style: .default
            ) { _ in
                self.getImageData(url) { data in
                    guard let image = UIImage(data: data) else { return }
                    self.writeToPhotoAlbum(image: image)
                }
            }
            actionSheetController.addAction(
                saveImageAction, accessibilityIdentifier: "linkContextMenu.saveImage")

            let copyAction = UIAlertAction(title: Strings.ContextMenuCopyImage, style: .default) {
                _ in
                // put the actual image on the clipboard
                // do this asynchronously just in case we're in a low bandwidth situation
                let pasteboard = UIPasteboard.general
                pasteboard.url = url as URL
                let changeCount = pasteboard.changeCount
                let application = UIApplication.shared
                var taskId = UIBackgroundTaskIdentifier(rawValue: 0)
                taskId = application.beginBackgroundTask(expirationHandler: {
                    application.endBackgroundTask(taskId)
                })

                makeURLSession(
                    userAgent: UserAgent.getUserAgent(),
                    configuration: URLSessionConfiguration.default
                ).dataTask(with: url) { (data, response, error) in
                    guard let _ = validatedHTTPResponse(response, statusCode: 200..<300) else {
                        application.endBackgroundTask(taskId)
                        return
                    }

                    // Only set the image onto the pasteboard if the pasteboard hasn't changed since
                    // fetching the image; otherwise, in low-bandwidth situations,
                    // we might be overwriting something that the user has subsequently added.
                    if changeCount == pasteboard.changeCount, let imageData = data, error == nil {
                        pasteboard.addImageWithData(imageData, forURL: url)
                    }

                    application.endBackgroundTask(taskId)
                }.resume()

            }
            actionSheetController.addAction(
                copyAction, accessibilityIdentifier: "linkContextMenu.copyImage")

            let copyImageLinkAction = UIAlertAction(
                title: Strings.ContextMenuCopyImageLink, style: .default
            ) { _ in
                UIPasteboard.general.url = url as URL
            }
            actionSheetController.addAction(
                copyImageLinkAction, accessibilityIdentifier: "linkContextMenu.copyImageLink")
        }

        let setupPopover = { [unowned self] in
            // If we're showing an arrow popup, set the anchor to the long press location.
            if let popoverPresentationController = actionSheetController
                .popoverPresentationController
            {
                popoverPresentationController.sourceView = self.view
                popoverPresentationController.sourceRect = CGRect(
                    origin: touchPoint, size: touchSize)
                popoverPresentationController.permittedArrowDirections = .any
                popoverPresentationController.delegate = self
            }
        }
        setupPopover()

        if actionSheetController.popoverPresentationController != nil {
            displayedPopoverController = actionSheetController
            updateDisplayedPopoverProperties = setupPopover
        }

        if let dialogTitle = dialogTitle {
            if let _ = dialogTitle.asURL {
                actionSheetController.title = dialogTitle.ellipsize(
                    maxLength: ActionSheetTitleMaxLength)
            } else {
                actionSheetController.title = dialogTitle
            }
        }

        let cancelAction = UIAlertAction(
            title: Strings.CancelString, style: UIAlertAction.Style.cancel, handler: nil)
        actionSheetController.addAction(cancelAction)
        self.present(actionSheetController, animated: true, completion: nil)
    }

    fileprivate func getImageData(_ url: URL, success: @escaping (Data) -> Void) {
        makeURLSession(
            userAgent: UserAgent.getUserAgent(), configuration: URLSessionConfiguration.default
        ).dataTask(with: url) { (data, response, error) in
            if let _ = validatedHTTPResponse(response, statusCode: 200..<300), let data = data {
                success(data)
            }
        }.resume()
    }

    func contextMenuHelper(
        _ contextMenuHelper: ContextMenuHelper, didCancelGestureRecognizer: UIGestureRecognizer
    ) {
        displayedPopoverController?.dismiss(animated: true) {
            self.displayedPopoverController = nil
        }
    }
}

extension BrowserViewController {
    @objc func image(
        _ image: UIImage, didFinishSavingWithError error: NSError?, contextInfo: UnsafeRawPointer
    ) {
    }
}

extension BrowserViewController: KeyboardHelperDelegate {
    func keyboardHelper(
        _ keyboardHelper: KeyboardHelper, keyboardWillShowWithState state: KeyboardState
    ) {
        keyboardState = state
        updateViewConstraints()
    }

    func keyboardHelper(
        _ keyboardHelper: KeyboardHelper, keyboardDidShowWithState state: KeyboardState
    ) {

    }

    func keyboardHelper(
        _ keyboardHelper: KeyboardHelper, keyboardWillHideWithState state: KeyboardState
    ) {
        keyboardState = nil
        updateViewConstraints()
    }

    func keyboardHelper(
        _ keyboardHelper: KeyboardHelper, keyboardDidHideWithState state: KeyboardState
    ) {

    }
}

extension BrowserViewController: SessionRestoreHelperDelegate {
    func sessionRestoreHelper(_ helper: SessionRestoreHelper, didRestoreSessionForTab tab: Tab) {
        tab.restoring = false

        if let tab = tabManager.selectedTab, tab.webView === tab.webView {
            updateUIForReaderHomeStateForTab(tab)
        }

        clipboardBarDisplayHandler?.didRestoreSession()
    }
}

extension BrowserViewController: JSPromptAlertControllerDelegate {
    func promptAlertControllerDidDismiss(_ alertController: JSPromptAlertController) {
        showQueuedAlertIfAvailable()
    }
}

extension BrowserViewController {
    func showAddToSpacesSheet(
        url: URL, title: String?,
        webView: WKWebView,
        importData: SpaceImportHandler? = nil
    ) {
        webView.evaluateJavaScript("document.querySelector('meta[name=\"description\"]').content") {
            [unowned self]
            (result, error) in
            showAddToSpacesSheet(
                url: url, title: title, description: result as? String, importData: importData)
        }
    }

    func showAddToSpacesSheet(
        url: URL, title: String?,
        description: String?,
        importData: SpaceImportHandler? = nil
    ) {
        let title = (title ?? "").isEmpty ? url.absoluteString : title!
        let request = AddToSpaceRequest(title: title, description: description, url: url)

        self.showAsModalOverlaySheet(style: .withTitle) {
            AddToSpaceOverlaySheetContent(
                request: request,
                importData: importData)
        } onDismiss: {
            if request.state != .initial {
                ToastDefaults().showToastForSpace(bvc: self, request: request)
            }
        }
    }
}

extension BrowserViewController {
    func showNeevaMenuSheet() {
        TourManager.shared.userReachedStep(tapTarget: .neevaMenu)

        updateFeedbackImage()

        if NeevaFeatureFlags[.cheatsheetQuery] {
            showAsModalOverlaySheet(style: .grouped) { [self] in
                CheatsheetOverlaySheetContent(
                    menuAction: perform(neevaMenuAction:),
                    tabManager: tabManager)
            }
        } else {
            showAsModalOverlaySheet(style: .grouped) { [self] in
                NeevaMenuOverlaySheetContent(
                    menuAction: perform(neevaMenuAction:),
                    isIncognito: tabManager.isIncognito)
            }
        }
        self.dismissVC()
    }
}

extension UIViewController {
    @objc func dismissVC() {
        self.dismiss(animated: true, completion: nil)
    }
}

extension BrowserViewController {
    func showShareSheet(buttonView: UIView) {
        guard
            let tab = tabManager.selectedTab,
            let url = tab.url
        else { return }

        if url.isFileURL {
            share(fileURL: url, buttonView: buttonView, presentableVC: self)
        } else {
            share(tab: tab, from: buttonView, presentableVC: self)
        }
    }

    func showBackForwardList() {
        let generator = UIImpactFeedbackGenerator(style: .heavy)
        generator.impactOccurred()
        if let backForwardList = self.tabManager.selectedTab?.webView?.backForwardList {
            let backForwardViewController = BackForwardListViewController(
                profile: self.profile, backForwardList: backForwardList)
            backForwardViewController.tabManager = self.tabManager
            backForwardViewController.bvc = self
            backForwardViewController.modalPresentationStyle = .overCurrentContext
            backForwardViewController.backForwardTransitionDelegate =
                BackForwardListAnimator()
            self.present(backForwardViewController, animated: true, completion: nil)
        }
    }
}
