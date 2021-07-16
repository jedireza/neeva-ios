/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import UIKit
import SnapKit
import Storage
import Shared
import Defaults
import SwiftUI

public enum TabTrayControllerUX {
    static let CornerRadius = CGFloat(6.0)
    fileprivate static let TextBoxHeight = CGFloat(32.0)
    fileprivate static let TopBarHeight = UIConstants.TopToolbarPaddingTop + UIConstants.TextFieldHeight + UIConstants.TopToolbarPaddingBottom
    static let FaviconSize = CGFloat(20)
    fileprivate static let Margin = CGFloat(15)
    fileprivate static let CloseButtonSize = CGFloat(32)
    fileprivate static let CloseButtonEdgeInset = CGFloat(7)
    fileprivate static let NumberOfColumnsWide = 3
    fileprivate static let CompactNumberOfColumnsThin = 2
}

protocol TabTrayDelegate: AnyObject {
    func tabTrayDidDismiss(_ tabTray: TabTrayControllerV1)
    func tabTrayDidAddTab(_ tabTray: TabTrayControllerV1, tab: Tab)
    func tabTrayDidAddToReadingList(_ tab: Tab) -> ReadingListItem?
    func tabTrayDidTapLocationBar(_ tabTray: TabTrayControllerV1)
    func tabTrayRequestsPresentationOf(_ viewController: UIViewController)
}

fileprivate struct FakeTabLocationView: View {
    let action: () -> ()
    let isIncognito: Bool

    private struct Style: ButtonStyle {
        @Environment(\.isIncognito) private var isIncognito

        func makeBody(configuration: Configuration) -> some View {
            ZStack {
                let backgroundColor: Color = isIncognito
                    ? configuration.isPressed ? .elevatedDarkBackground : .black
                    : configuration.isPressed ? .tertiarySystemFill : .systemFill

                Capsule().fill(backgroundColor)
                configuration.label
            }
        }
    }

    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        Button(action: action) {
            LocationLabel(url: nil, isSecure: false)
                .environmentObject(GridModel())
        }
        .environment(\.isIncognito, isIncognito)
        .frame(height: TabLocationViewUX.height)
        .colorScheme(isIncognito ? .dark : colorScheme)
        .buttonStyle(Style())
    }
}

class TabTrayControllerV1: UIViewController {
    let tabManager: TabManager
    let profile: Profile
    weak var delegate: TabTrayDelegate?
    var tabDisplayManager: TabDisplayManager!
    var tabCellIdentifer: TabDisplayer.TabCellIdentifer = TabCell.Identifier
    var otherBrowsingModeOffset = CGPoint.zero
    // Backdrop used for displaying greyed background for private tabs
    var webViewContainerBackdrop: UIView!
    var collectionView: UICollectionView!

    let statusBarBG = UIView()
    lazy var toolbar: TrayToolbar = {
        let toolbar = TrayToolbar()
        toolbar.maskButton.addTarget(self, action: #selector(didToggleToolbarIncognitoButton), for: .touchUpInside)

        let menu = TabMenu(tabManager: tabManager, alertPresentViewController: self)
        toolbar.addTabButton.addTarget(self, action: #selector(didTapToolbarAddTabButton), for: .touchUpInside)
        toolbar.addTabButton.setDynamicMenu(menu.createRecentlyClosedTabsMenu)

        toolbar.doneButton.addTarget(self, action: #selector(didTapToolbarDoneButton), for: .touchUpInside)
        toolbar.doneButton.menu = menu.createCloseAllTabsMenu()
        menu.tabsClosed = { isPrivate in
            if isPrivate {
                self.didToggleToolbarIncognitoButton()
            }
        }

        return toolbar
    }()

    fileprivate lazy var locationViewController = UIHostingController(rootView: FakeTabLocationView(action: onTapLocation, isIncognito: tabDisplayManager.isPrivate))
    private func onTapLocation() {
        didTapToolbarAddTabButton()
        delegate?.tabTrayDidTapLocationBar(self)
    }

    var topBarHolder = UIView()

    let line = UIView()

    fileprivate lazy var emptyPrivateTabsView = UIView()

    fileprivate lazy var tabLayoutDelegate: TabLayoutDelegate = {
        let delegate = TabLayoutDelegate(profile: self.profile, traitCollection: self.traitCollection, scrollView: self.collectionView)
        delegate.tabSelectionDelegate = self
        return delegate
    }()

    var numberOfColumns: Int {
        return tabLayoutDelegate.numberOfColumns
    }

    init(tabManager: TabManager, profile: Profile, tabTrayDelegate: TabTrayDelegate? = nil) {
        self.tabManager = tabManager
        self.profile = profile
        self.delegate = tabTrayDelegate

        super.init(nibName: nil, bundle: nil)

        collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        collectionView.register(TabCell.self, forCellWithReuseIdentifier: TabCell.Identifier)
        tabDisplayManager = TabDisplayManager(collectionView: self.collectionView, tabManager: self.tabManager, tabDisplayer: self, reuseID: TabCell.Identifier)
        collectionView.dataSource = tabDisplayManager
        collectionView.delegate = tabLayoutDelegate
        collectionView.contentInset = UIEdgeInsets(top: TabTrayControllerUX.TopBarHeight, left: 0, bottom: 0, right: 0)

        tabDisplayManager.tabDisplayCompletionDelegate = self
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.view.layoutIfNeeded()
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        // When the app enters split screen mode we refresh the collection view layout to show the proper grid
        collectionView.collectionViewLayout.invalidateLayout()
    }
    
    deinit {
        tabManager.removeDelegate(self.tabDisplayManager)
        tabManager.removeDelegate(self)
        tabDisplayManager = nil
    }
    
    func focusTab() {
        guard let currentTab = tabManager.selectedTab, let index = self.tabDisplayManager.dataStore.index(of: currentTab), let rect = self.collectionView.layoutAttributesForItem(at: IndexPath(item: index, section: 0))?.frame else {
            return
        }
        self.collectionView.scrollRectToVisible(rect, animated: false)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc func dynamicFontChanged(_ notification: Notification) {
        guard notification.name == .DynamicFontChanged else { return }
    }

// MARK: View Controller Callbacks
    override func viewDidLoad() {
        super.viewDidLoad()
        tabManager.addDelegate(self)
        view.accessibilityLabel = .TabTrayViewAccessibilityLabel
        
        webViewContainerBackdrop = UIView()
        webViewContainerBackdrop.backgroundColor = UIColor.Photon.Ink90
        webViewContainerBackdrop.alpha = 0

        collectionView.alwaysBounceVertical = true
        collectionView.backgroundColor = UIColor.TabTray.background
        collectionView.keyboardDismissMode = .onDrag

        collectionView.dragInteractionEnabled = true
        collectionView.dragDelegate = tabDisplayManager
        collectionView.dropDelegate = tabDisplayManager

        addChild(locationViewController)
        topBarHolder.addSubview(locationViewController.view)
        locationViewController.didMove(toParent: self)
        topBarHolder.addSubview(line)
        topBarHolder.backgroundColor = UIColor.Browser.background
        [webViewContainerBackdrop, collectionView, toolbar, topBarHolder].forEach { view.addSubview($0) }
        makeConstraints()

        // The statusBar needs a background color
        statusBarBG.backgroundColor = UIColor.Browser.background
        view.addSubview(statusBarBG)
        statusBarBG.snp.makeConstraints { make in
            make.leading.trailing.top.equalTo(self.view)
            make.bottom.equalTo(self.view.safeArea.top)
        }

        view.insertSubview(emptyPrivateTabsView, aboveSubview: collectionView)
        emptyPrivateTabsView.snp.makeConstraints { make in
            make.top.left.right.equalTo(self.collectionView)
            make.bottom.equalTo(self.toolbar.snp.top)
        }

        if let tab = tabManager.selectedTab, tab.isPrivate {
            tabDisplayManager.togglePrivateMode(isOn: true, createTabOnEmptyPrivateMode: false)
            toolbar.applyUIMode(isPrivate: true)
        }

        locationViewController.rootView = .init(action: onTapLocation, isIncognito: tabDisplayManager.isPrivate)

        line.backgroundColor = UIColor.Browser.urlBarDivider

        if traitCollection.forceTouchCapability == .available {
            registerForPreviewing(with: self, sourceView: view)
        }

        emptyPrivateTabsView.isHidden = !privateTabsAreEmpty()

        NotificationCenter.default.addObserver(self, selector: #selector(appWillResignActiveNotification), name: UIApplication.willResignActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(appDidBecomeActiveNotification), name: UIApplication.didBecomeActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(dynamicFontChanged), name: .DynamicFontChanged, object: nil)
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        // Update the trait collection we reference in our layout delegate
        tabLayoutDelegate.traitCollection = traitCollection
    }

    fileprivate func makeConstraints() {
        webViewContainerBackdrop.snp.makeConstraints { make in
            make.edges.equalTo(self.view)
        }
        
        collectionView.snp.makeConstraints { make in
            make.left.equalTo(view.safeArea.left)
            make.right.equalTo(view.safeArea.right)
            make.bottom.equalTo(toolbar.snp.top)
            make.top.equalTo(self.view.safeArea.top)
        }

        toolbar.snp.makeConstraints { make in
            make.left.right.bottom.equalTo(view)
            make.height.equalTo(UIConstants.BottomToolbarHeight)
        }

        topBarHolder.snp.makeConstraints { make in
            make.leading.equalTo(view.snp.leading)
            make.trailing.equalTo(view.snp.trailing)
            make.height.equalTo(TabTrayControllerUX.TopBarHeight)
            self.tabLayoutDelegate.topBarHeightConstraint = make.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.top).constraint
        }

        line.snp.makeConstraints { make in
            make.bottom.leading.trailing.equalTo(topBarHolder)
            make.height.equalTo(0.5)
        }
    }

    override func updateViewConstraints() {
        let centerAlign =
            UIDevice.current.userInterfaceIdiom == .pad ||
            (UIDevice.current.orientation != .portrait && UIDevice.current.orientation != .faceUp)
        locationViewController.view.snp.remakeConstraints { make in
            if centerAlign {
                make.centerY.equalTo(topBarHolder)
            } else {
                make.top.equalTo(topBarHolder).offset(UIConstants.TopToolbarPaddingTop)
            }
            make.leading.equalTo(self.view.safeArea.leading).offset(8)
            make.trailing.equalTo(self.view.safeArea.trailing).offset(-8)
        }
        super.updateViewConstraints()
    }

    override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        super.willTransition(to: newCollection, with: coordinator)
        view.setNeedsUpdateConstraints()
    }

    @objc func didToggleToolbarIncognitoButton() {
        if tabDisplayManager.isDragging {
            return
        }
        if !tabDisplayManager.isPrivate && tabManager.privateTabs.isEmpty {
            tabManager.switchPrivacyMode()
            dismissTabTray()
            return
        }

        toolbar.isUserInteractionEnabled = false

        let scaleDownTransform = CGAffineTransform(scaleX: 0.9, y: 0.9)

        let newOffset = CGPoint(x: 0.0, y: collectionView.contentOffset.y)
        if self.otherBrowsingModeOffset.y > 0 {
            collectionView.setContentOffset(self.otherBrowsingModeOffset, animated: false)
        }
        self.otherBrowsingModeOffset = newOffset
        let fromView: UIView
        if !privateTabsAreEmpty(), let snapshot = collectionView.snapshotView(afterScreenUpdates: false) {
            snapshot.frame = collectionView.frame
            view.insertSubview(snapshot, aboveSubview: collectionView)
            fromView = snapshot
        } else {
            fromView = emptyPrivateTabsView
        }

        if (tabDisplayManager.isPrivate) {
            ClientLogger.shared.logCounter(.TurnOffIncognitoMode, attributes: EnvironmentHelper.shared.getAttributes())
        } else {
            ClientLogger.shared.logCounter(.TurnOnIncognitoMode, attributes: EnvironmentHelper.shared.getAttributes())
        }

        tabManager.willSwitchTabMode(leavingPBM: tabDisplayManager.isPrivate)
        
        tabDisplayManager.togglePrivateMode(isOn: !tabDisplayManager.isPrivate, createTabOnEmptyPrivateMode: false)

        self.tabDisplayManager.refreshStore()

        // If we are exiting private mode and we have the close private tabs option selected, make sure
        // we clear out all of the private tabs
        let exitingPrivateMode = !tabDisplayManager.isPrivate && Defaults[.closePrivateTabs]

        toolbar.maskButton.setSelected(tabDisplayManager.isPrivate, animated: true)
        collectionView.layoutSubviews()

        let toView: UIView
        if !privateTabsAreEmpty(), let newSnapshot = collectionView.snapshotView(afterScreenUpdates: !exitingPrivateMode) {
            emptyPrivateTabsView.isHidden = true
            //when exiting private mode don't screenshot the collectionview (causes the UI to hang)
            newSnapshot.frame = collectionView.frame
            view.insertSubview(newSnapshot, aboveSubview: fromView)
            collectionView.alpha = 0
            toView = newSnapshot
        } else {
            emptyPrivateTabsView.isHidden = false
            toView = emptyPrivateTabsView
        }
        toView.alpha = 0
        toView.transform = scaleDownTransform

        UIView.animate(withDuration: 0.2, delay: 0, options: [], animations: { () -> Void in
            fromView.transform = scaleDownTransform
            fromView.alpha = 0
            toView.transform = .identity
            toView.alpha = 1
        }) { finished in
            if fromView != self.emptyPrivateTabsView {
                fromView.removeFromSuperview()
            }
            if toView != self.emptyPrivateTabsView {
                toView.removeFromSuperview()
            }
            self.collectionView.alpha = 1
            self.toolbar.isUserInteractionEnabled = true

            // A final reload to ensure no animations happen while completing the transition.
            self.tabDisplayManager.refreshStore()
        }

        toolbar.applyUIMode(isPrivate: tabDisplayManager.isPrivate)
        locationViewController.rootView = .init(action: onTapLocation, isIncognito: tabDisplayManager.isPrivate)
    }

    fileprivate func privateTabsAreEmpty() -> Bool {
        return tabDisplayManager.isPrivate && tabManager.privateTabs.isEmpty
    }

    @objc func didTapToolbarAddTabButton() {
        if tabDisplayManager.isDragging {
            return
        }
        openNewTab()
    }

    func openNewTab(_ request: URLRequest? = nil) {
        if tabDisplayManager.isDragging {
            return
        }
        // We dismiss the tab tray once we are done. So no need to re-enable the toolbar
        toolbar.isUserInteractionEnabled = false

        tabDisplayManager.updateWith(animationType: .addTab) { [weak self] in
            guard let me = self else { return }
            me.tabManager.selectTab(me.tabManager.addTab(request, isPrivate: me.tabDisplayManager.isPrivate))
        }
    }
}

extension TabTrayControllerV1: TabManagerDelegate {
    func tabManager(_ tabManager: TabManager, didSelectedTabChange selected: Tab?, previous: Tab?, isRestoring: Bool) {}
    func tabManager(_ tabManager: TabManager, didAddTab tab: Tab, isRestoring: Bool) {}

    func tabManager(_ tabManager: TabManager, didRemoveTab tab: Tab, isRestoring: Bool) { }

    func tabManagerDidRestoreTabs(_ tabManager: TabManager) {
        self.emptyPrivateTabsView.isHidden = !self.privateTabsAreEmpty()
    }
    func tabManagerDidAddTabs(_ tabManager: TabManager) {}
    func tabManagerDidRemoveAllTabs(_ tabManager: TabManager) {
        // No need to handle removeAll toast in TabTray.
        // When closing all normal tabs we automatically focus a tab and show the BVC. Which will handle the Toast.
        // We don't show the removeAll toast in PBM
    }
}

extension TabTrayControllerV1: TabDisplayer {

    func focusSelectedTab() {
        self.focusTab()
    }

    func cellFactory(for cell: UICollectionViewCell, using tab: Tab) -> UICollectionViewCell {
        guard let tabCell = cell as? TabCell else { return cell }
        tabCell.animator.delegate = self
        tabCell.delegate = self
        let selected = tab == tabManager.selectedTab
        tabCell.configureWith(tab: tab, is: selected)
        return tabCell
    }
}

extension TabTrayControllerV1 {
    func closeTabsForCurrentTray() {
        let tabs = tabDisplayManager.dataStore.compactMap { $0 }
        tabManager.removeTabsAndAddNormalTab(tabs, showToast: true)

        closeTabsTrayHelper()
    }
    
    func closeTabsTrayHelper() {
        if self.tabDisplayManager.isPrivate {
            self.emptyPrivateTabsView.isHidden = !self.privateTabsAreEmpty()
            if !self.emptyPrivateTabsView.isHidden {
                // Fade in the empty private tabs message. This slow fade allows time for the closing tab animations to complete.
                self.emptyPrivateTabsView.alpha = 0
                UIView.animate(withDuration: 0.5, animations: {
                    self.emptyPrivateTabsView.alpha = 1
                }, completion: nil)
            }
        } else if self.tabManager.normalTabs.count == 1, let tab = self.tabManager.normalTabs.first {
            self.tabManager.selectTab(tab)
            self.dismissTabTray()
        }
    }

    func changePrivacyMode(_ isPrivate: Bool) {
        if isPrivate != tabDisplayManager.isPrivate {
            didToggleToolbarIncognitoButton()
        }
    }

    func dismissTabTray() {
        collectionView.layer.removeAllAnimations()
        collectionView.cellForItem(at: IndexPath(row: 0, section: 0))?.layer.removeAllAnimations()
        _ = self.navigationController?.popViewController(animated: true)
        TelemetryWrapper.recordEvent(category: .action, method: .close, object: .tabTray)
    }
}

// MARK: - App Notifications
extension TabTrayControllerV1 {
    @objc func appWillResignActiveNotification() {
        if tabDisplayManager.isPrivate {
            webViewContainerBackdrop.alpha = 1
            view.bringSubviewToFront(webViewContainerBackdrop)
            collectionView.alpha = 0
            emptyPrivateTabsView.alpha = 0
        }
    }

    @objc func appDidBecomeActiveNotification() {
        // Re-show any components that might have been hidden because they were being displayed
        // as part of a private mode tab
        UIView.animate(withDuration: 0.2, animations: {
            self.collectionView.alpha = 1
            self.emptyPrivateTabsView.alpha = 1
        }) { _ in
            self.webViewContainerBackdrop.alpha = 0
            self.view.sendSubviewToBack(self.webViewContainerBackdrop)
        }
    }
}

extension TabTrayControllerV1: TabSelectionDelegate {
    func didSelectTabAtIndex(_ index: Int) {
        if let tab = tabDisplayManager.dataStore.at(index) {
            tabManager.selectTab(tab)
            dismissTabTray()
        }
    }
}

extension TabTrayControllerV1: UIScrollViewAccessibilityDelegate {
    func accessibilityScrollStatus(for scrollView: UIScrollView) -> String? {
        guard var visibleCells = collectionView.visibleCells as? [TabCell] else { return nil }
        var bounds = collectionView.bounds
        bounds = bounds.offsetBy(dx: collectionView.contentInset.left, dy: collectionView.contentInset.top)
        bounds.size.width -= collectionView.contentInset.left + collectionView.contentInset.right
        bounds.size.height -= collectionView.contentInset.top + collectionView.contentInset.bottom
        // visible cells do sometimes return also not visible cells when attempting to go past the last cell with VoiceOver right-flick gesture; so make sure we have only visible cells (yeah...)
        visibleCells = visibleCells.filter { !$0.frame.intersection(bounds).isEmpty }

        let cells = visibleCells.map { self.collectionView.indexPath(for: $0)! }
        let indexPaths = cells.sorted { (a: IndexPath, b: IndexPath) -> Bool in
            return a.section < b.section || (a.section == b.section && a.row < b.row)
        }

        guard !indexPaths.isEmpty else {
            return .TabTrayNoTabsAccessibilityHint
        }

        let firstTab = indexPaths.first!.row + 1
        let lastTab = indexPaths.last!.row + 1
        let tabCount = collectionView.numberOfItems(inSection: 0)

        if firstTab == lastTab {
            let format: String = .TabTrayVisibleTabRangeAccessibilityHint
            return String(format: format, NSNumber(value: firstTab as Int), NSNumber(value: tabCount as Int))
        } else {
            let format: String = .TabTrayVisiblePartialRangeAccessibilityHint
            return String(format: format, NSNumber(value: firstTab as Int), NSNumber(value: lastTab as Int), NSNumber(value: tabCount as Int))
        }
    }
}

extension TabTrayControllerV1: SwipeAnimatorDelegate {
    func swipeAnimator(_ animator: SwipeAnimator, viewWillExitContainerBounds: UIView) {
        guard let tabCell = animator.animatingView as? TabCell, let indexPath = collectionView.indexPath(for: tabCell) else { return }
        if let tab = tabDisplayManager.dataStore.at(indexPath.item) {
            self.removeByButtonOrSwipe(tab: tab, cell: tabCell)
            UIAccessibility.post(notification: UIAccessibility.Notification.announcement, argument: String.TabTrayClosingTabAccessibilityMessage)
        }
    }

    // Disable swipe delete while drag reordering
    func swipeAnimatorIsAnimateAwayEnabled(_ animator: SwipeAnimator) -> Bool {
        return !tabDisplayManager.isDragging
    }
}

extension TabTrayControllerV1: TabCellDelegate {
    func tabCellDidClose(_ cell: TabCell) {
        if let indexPath = collectionView.indexPath(for: cell), let tab = tabDisplayManager.dataStore.at(indexPath.item) {
            removeByButtonOrSwipe(tab: tab, cell: cell)
        }
    }
}

extension TabTrayControllerV1: TabPeekDelegate {


    func tabPeekDidAddToReadingList(_ tab: Tab) -> ReadingListItem? {
        return delegate?.tabTrayDidAddToReadingList(tab)
    }

    func tabPeekDidCloseTab(_ tab: Tab) {
        if let index = tabDisplayManager.dataStore.index(of: tab),
            let cell = self.collectionView?.cellForItem(at: IndexPath(item: index, section: 0)) as? TabCell {
            cell.close()
        }
    }

    func tabPeekRequestsPresentationOf(_ viewController: UIViewController) {
        delegate?.tabTrayRequestsPresentationOf(viewController)
    }
}

extension TabTrayControllerV1: UIViewControllerPreviewingDelegate {

    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {

        guard let collectionView = collectionView else { return nil }
        let convertedLocation = self.view.convert(location, to: collectionView)

        guard let indexPath = collectionView.indexPathForItem(at: convertedLocation),
            let cell = collectionView.cellForItem(at: indexPath) else { return nil }

        guard let tab = tabDisplayManager.dataStore.at(indexPath.row) else {
            return nil
        }
        let tabVC = TabPeekViewController(tab: tab, delegate: self)
    
        previewingContext.sourceRect = self.view.convert(cell.frame, from: collectionView)

        return tabVC
    }

    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        guard let tpvc = viewControllerToCommit as? TabPeekViewController else { return }
        tabManager.selectTab(tpvc.tab)
        navigationController?.popViewController(animated: true)
        delegate?.tabTrayDidDismiss(self)
    }
}

extension TabTrayControllerV1: TabDisplayCompletionDelegate {
    func completedAnimation(for type: TabAnimationType) {
        emptyPrivateTabsView.isHidden = !privateTabsAreEmpty()

        switch type {
        case .addTab:
            dismissTabTray()
        case .removedLastTab:
            // when removing the last tab (only in normal mode) we will automatically open a new tab.
            // When that happens focus it by dismissing the tab tray
            if !tabDisplayManager.isPrivate {
                self.dismissTabTray()
            }
        case .removedNonLastTab, .updateTab, .moveTab:
            break
        }
    }
}

extension TabTrayControllerV1 {
    func removeByButtonOrSwipe(tab: Tab, cell: TabCell) {
        tabDisplayManager.tabDisplayCompletionDelegate = self
        tabDisplayManager.closeActionPerformed(forCell: cell)
        if tabDisplayManager.isPrivate && tabManager.privateTabs.isEmpty {
            didToggleToolbarIncognitoButton()
        }
    }
}

extension TabTrayControllerV1 {
    @objc func didTapToolbarDoneButton(_ sender: UIButton) {
        ClientLogger.shared.logCounter(.HideTabTray, attributes: EnvironmentHelper.shared.getAttributes())
        dismissTabTray()
    }
}

fileprivate class TabLayoutDelegate: NSObject, UICollectionViewDelegateFlowLayout, UIGestureRecognizerDelegate {
    weak var tabSelectionDelegate: TabSelectionDelegate?
    var topBarHeightConstraint: Constraint?
    let scrollView: UIScrollView
    var lastYOffset: CGFloat = 0

    enum ScrollDirection {
        case up
        case down
    }

    fileprivate var scrollDirection: ScrollDirection = .down
    fileprivate var traitCollection: UITraitCollection
    fileprivate var numberOfColumns: Int {
        // iPhone 4-6+ portrait
        if traitCollection.horizontalSizeClass == .compact && traitCollection.verticalSizeClass == .regular {
            return TabTrayControllerUX.CompactNumberOfColumnsThin
        } else {
            return TabTrayControllerUX.NumberOfColumnsWide
        }
    }

    init(profile: Profile, traitCollection: UITraitCollection, scrollView: UIScrollView) {
        self.scrollView = scrollView
        self.traitCollection = traitCollection
        super.init()
    }

    func clamp(_ y: CGFloat, min: CGFloat, max: CGFloat) -> CGFloat {
        if y >= max {
            return max
        } else if y <= min {
            return min
        }
        return y
    }

    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if decelerate {
            if scrollDirection == .up {
                hideSearch()
            }
        }
    }

    func checkRubberbandingForDelta(_ delta: CGFloat, for scrollView: UIScrollView) -> Bool {
        if scrollView.contentOffset.y < 0 {
            return true
        } else {
            return false
        }
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let float = scrollView.contentOffset.y

        defer {
            self.lastYOffset = float
        }
        let delta = lastYOffset - float

        if delta > 0 {
            scrollDirection = .down
        } else if delta < 0 {
            scrollDirection = .up
        }
        if checkRubberbandingForDelta(delta, for: scrollView) {

            let offset = clamp(abs(scrollView.contentOffset.y), min: 0, max: TabTrayControllerUX.TopBarHeight)
            topBarHeightConstraint?.update(offset: offset)
            if scrollDirection == .down {
                scrollView.contentInset = UIEdgeInsets(top: offset, left: 0, bottom: 0, right: 0)
            }
        } else {
            self.hideSearch()
        }
    }

    func showSearch() {
        topBarHeightConstraint?.update(offset: TabTrayControllerUX.TopBarHeight)
        scrollView.contentInset = UIEdgeInsets(top: TabTrayControllerUX.TopBarHeight, left: 0, bottom: 0, right: 0)
    }

    func hideSearch() {
        topBarHeightConstraint?.update(offset: 0)
        scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }

    fileprivate func cellHeightForCurrentDevice() -> CGFloat {
        let shortHeight = TabTrayControllerUX.TextBoxHeight * 6

        if self.traitCollection.verticalSizeClass == .compact {
            return shortHeight
        } else if self.traitCollection.horizontalSizeClass == .compact {
            return shortHeight
        } else {
            return TabTrayControllerUX.TextBoxHeight * 8
        }
    }

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }

    @objc func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return TabTrayControllerUX.Margin
    }

    @objc func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cellWidth = floor((collectionView.bounds.width - TabTrayControllerUX.Margin * CGFloat(numberOfColumns + 1)) / CGFloat(numberOfColumns))
        return CGSize(width: cellWidth, height: self.cellHeightForCurrentDevice())
    }

    @objc func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(equalInset: TabTrayControllerUX.Margin)
    }

    @objc func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return TabTrayControllerUX.Margin
    }

    @objc func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        tabSelectionDelegate?.didSelectTabAtIndex(indexPath.row)
    }
}

extension TabTrayControllerV1: UIAdaptivePresentationControllerDelegate, UIPopoverPresentationControllerDelegate {
    // Returning None here makes sure that the Popover is actually presented as a Popover and
    // not as a full-screen modal, which is the default on compact device classes.
    func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        return .none
    }
}

// MARK: - Toolbar
class TrayToolbar: UIView, PrivateModeUI {
    fileprivate let toolbarButtonSize = CGSize(width: 44, height: 44)

    lazy var addTabButton: UIButton = {
        let symbol = UIImage(systemName: "plus.app", withConfiguration: UIImage.SymbolConfiguration(pointSize: 20))
        let button = UIButton()
        button.setImage(symbol, for: .normal)
        button.accessibilityLabel = .TabTrayAddTabAccessibilityLabel
        button.accessibilityIdentifier = "TabTrayController.addTabButton"
        button.isPointerInteractionEnabled = true
        return button
    }()

    lazy var doneButton: UIButton = {
        let button = UIButton()
        let font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        let title = NSAttributedString(string: "Done", attributes: [NSAttributedString.Key.font: font])
        button.setAttributedTitle(title, for: .normal)
        button.accessibilityLabel = .TabTrayDoneAccessibilityLabel
        button.accessibilityIdentifier = "TabTrayController.doneButton"
        button.isPointerInteractionEnabled = true
        return button
    }()

    lazy var maskButton = PrivateModeButton()
    fileprivate let sideOffset: CGFloat = 16

    fileprivate override init(frame: CGRect) {
        super.init(frame: frame)

        addSubview(maskButton)
        addSubview(addTabButton)
        addSubview(doneButton)

        maskButton.accessibilityIdentifier = "TabTrayController.maskButton"

        maskButton.snp.makeConstraints { make in
            make.top.equalTo(self)
            make.leading.equalTo(self).offset(sideOffset)
            make.size.equalTo(toolbarButtonSize)
        }

        addTabButton.snp.makeConstraints { make in
            make.centerX.equalTo(self)
            make.top.equalTo(self)
            make.size.equalTo(toolbarButtonSize)
        }

        doneButton.snp.makeConstraints { make in
            make.top.equalTo(self)
            make.trailing.equalTo(self).offset(-sideOffset)
            make.size.equalTo(toolbarButtonSize)
        }

        let line = UIView()
        addSubview(line)
        line.backgroundColor = UIColor.Browser.urlBarDivider
        line.snp.makeConstraints { make in
            make.top.leading.trailing.equalTo(self)
            make.height.equalTo(0.5)
        }

        backgroundColor = UIColor.Browser.background
        addTabButton.tintColor = .label
        doneButton.setTitleColor(.label, for: .normal)

        maskButton.offTint = UIColor.label
        maskButton.onTint = UIColor.label.swappedForStyle

        applyUIMode(isPrivate: false)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func applyUIMode(isPrivate: Bool) {
        maskButton.applyUIMode(isPrivate: isPrivate)
    }
}

protocol TabCellDelegate: AnyObject {
    func tabCellDidClose(_ cell: TabCell)
}

class TabCell: UICollectionViewCell {
    static let Identifier = "TabCellIdentifier"
    static let SelectedBorderWidth: CGFloat = 3
    static let UnselectedBorderWidth: CGFloat = 1

    let backgroundHolder: UIView = {
        let view = UIView()
        view.layer.cornerRadius = TabTrayControllerUX.CornerRadius
        view.clipsToBounds = true
        view.backgroundColor = .tertiarySystemBackground
        return view
    }()

    let screenshotView: UIImageViewAligned = {
        let view = UIImageViewAligned()
        view.contentMode = .scaleAspectFill
        view.clipsToBounds = true
        view.isUserInteractionEnabled = false
        view.alignLeft = true
        view.alignTop = true
        view.backgroundColor = UIColor.Browser.background
        return view
    }()

    let titleText: UILabel = {
        let label = UILabel()
        label.isUserInteractionEnabled = false
        label.numberOfLines = 1
        label.font = DynamicFontHelper.defaultHelper.DefaultSmallFontBold
        return label
    }()

    let favicon: UIImageView = {
        let favicon = UIImageView()
        favicon.backgroundColor = UIColor.clear
        favicon.layer.cornerRadius = 2.0
        favicon.layer.masksToBounds = true
        return favicon
    }()

    let closeButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage.templateImageNamed("tab_close"), for: [])
        button.accessibilityIdentifier = "closeTabButtonTabTray"
        button.imageView?.contentMode = .scaleAspectFit
        button.contentMode = .center
        button.tintColor = .secondaryLabel
        button.imageEdgeInsets = UIEdgeInsets(equalInset: TabTrayControllerUX.CloseButtonEdgeInset)
        return button
    }()

    var title = UIVisualEffectView(effect: UIBlurEffect(style: .systemChromeMaterial))
    var animator: SwipeAnimator!

    var borderStyleSelected: Bool = false
    var borderStylePrivate: Bool = false

    weak var delegate: TabCellDelegate?

    // Changes depending on whether we're full-screen or not.
    var margin = CGFloat(0)

    override init(frame: CGRect) {
        super.init(frame: frame)

        self.animator = SwipeAnimator(animatingView: self)
        self.closeButton.addTarget(self, action: #selector(close), for: .touchUpInside)

        contentView.addSubview(backgroundHolder)
        backgroundHolder.addSubview(self.screenshotView)

        self.accessibilityCustomActions = [
            UIAccessibilityCustomAction(name: .TabTrayCloseAccessibilityCustomAction, target: self.animator, selector: #selector(SwipeAnimator.closeWithoutGesture))
        ]

        backgroundHolder.addSubview(title)
        title.contentView.addSubview(self.closeButton)
        title.contentView.addSubview(self.titleText)
        title.contentView.addSubview(self.favicon)

        title.snp.makeConstraints { (make) in
            make.top.left.right.equalTo(backgroundHolder)
            make.height.equalTo(TabTrayControllerUX.TextBoxHeight)
        }

        favicon.snp.makeConstraints { make in
            make.leading.equalTo(title.contentView).offset(6)
            make.top.equalTo((TabTrayControllerUX.TextBoxHeight - TabTrayControllerUX.FaviconSize) / 2)
            make.size.equalTo(TabTrayControllerUX.FaviconSize)
        }

        titleText.snp.makeConstraints { (make) in
            make.leading.equalTo(favicon.snp.trailing).offset(6)
            make.trailing.equalTo(closeButton.snp.leading).offset(-6)
            make.centerY.equalTo(title.contentView)
        }

        closeButton.snp.makeConstraints { make in
            make.size.equalTo(TabTrayControllerUX.CloseButtonSize)
            make.centerY.trailing.equalTo(title.contentView)
        }
    }

    func setTabBorder(color: UIColor, width: CGFloat) {
        // This creates a border around a tabcell. Using the shadow craetes a border _outside_ of the tab frame.
        layer.shadowColor = color.cgColor
        layer.shadowOpacity = 1
        layer.shadowRadius = 0 // A 0 radius creates a solid border instead of a gradient blur
        layer.masksToBounds = false
        // create a frame that is "BorderWidth" size bigger than the cell
        layer.shadowOffset = CGSize(width: -width, height: -width)
        let shadowPath = CGRect(width: layer.frame.width + (width * 2), height: layer.frame.height + (width * 2))
        layer.shadowPath = UIBezierPath(roundedRect: shadowPath, cornerRadius: TabTrayControllerUX.CornerRadius+width).cgPath
    }

    func updateTabBorder() {
        let color: UIColor
        let width: CGFloat
        if borderStyleSelected {
            width = TabCell.SelectedBorderWidth
            if borderStylePrivate {
                color = UIColor.Defaults.SystemGray01
            } else {
                color = UIConstants.SystemBlueColor
            }
        } else {
            width = TabCell.UnselectedBorderWidth
            color = UIColor.ui.adaptive.separator
        }
        setTabBorder(color: color, width: width)
    }

    func setTabSelected(_ isPrivate: Bool) {
        borderStyleSelected = true
        borderStylePrivate = isPrivate
    }

    func setTabUnselected(_ isPrivate: Bool) {
        borderStyleSelected = false
        borderStylePrivate = isPrivate
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        backgroundHolder.frame = CGRect(x: margin, y: margin, width: frame.width, height: frame.height)
        screenshotView.frame = CGRect(size: backgroundHolder.frame.size)

        updateTabBorder()
    }

    func configureWith(tab: Tab, is selected: Bool) {
        titleText.text = tab.displayTitle

        if !tab.displayTitle.isEmpty {
            accessibilityLabel = tab.displayTitle
        } else if let url = tab.url, let about = InternalURL(url)?.aboutComponent {
            accessibilityLabel = about
        } else {
            accessibilityLabel = ""
        }

        isAccessibilityElement = true
        accessibilityHint = .TabTraySwipeToCloseAccessibilityHint

        if let favIcon = tab.displayFavicon, let url = URL(string: favIcon.url) {
            favicon.sd_setImage(with: url, placeholderImage: UIImage(named: "defaultFavicon"), options: [], completed: nil)
        } else {
            favicon.image = UIImage(named: "defaultFavicon")
            favicon.tintColor = .label
        }
        if selected {
            setTabSelected(tab.isPrivate)
        } else {
            setTabUnselected(tab.isPrivate)
        }
        screenshotView.image = tab.screenshot
    }

    override func prepareForReuse() {
        // Reset any close animations.
        super.prepareForReuse()
        backgroundHolder.transform = .identity
        backgroundHolder.alpha = 1
        self.titleText.font = DynamicFontHelper.defaultHelper.DefaultSmallFontBold
        layer.shadowOffset = .zero
        layer.shadowPath = nil
        layer.shadowOpacity = 0
        isHidden = false
    }

    override func accessibilityScroll(_ direction: UIAccessibilityScrollDirection) -> Bool {
        var right: Bool
        switch direction {
        case .left:
            right = false
        case .right:
            right = true
        default:
            return false
        }
        animator.close(right: right)
        return true
    }

    @objc func close() {
        delegate?.tabCellDidClose(self)
    }
}
