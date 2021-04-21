/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import Shared
import UIKit
import Storage
import SDWebImage
import XCGLogger
import SnapKit
import SwiftUI
import NeevaSupport

private let log = Logger.browserLogger

// MARK: -  Lifecycle
struct NeevaHomeUX {
    static let rowSpacing: CGFloat = UIDevice.current.userInterfaceIdiom == .pad ? 30 : 20
    static let highlightCellHeight: CGFloat = UIDevice.current.userInterfaceIdiom == .pad ? 250 : 200
    static let sectionInsetsForSizeClass = UXSizeClasses(compact: 0, regular: 101, other: 20)
    static let numberOfItemsPerRowForSizeClassIpad = UXSizeClasses(compact: 3, regular: 4, other: 2)
    static let SectionInsetsForIpad: CGFloat = 101
    static let SectionInsetsForIphone: CGFloat = 20
    static let MinimumInsets: CGFloat = 20
    static let TopSitesInsets: CGFloat = 6
    static let LibraryShortcutsHeight: CGFloat = 100
    static let LibraryShortcutsMaxWidth: CGFloat = 350
}
/*
 Size classes are the way Apple requires us to specify our UI.
 Split view on iPad can make a landscape app appear with the demensions of an iPhone app
 Use UXSizeClasses to specify things like offsets/itemsizes with respect to size classes
 For a primer on size classes https://useyourloaf.com/blog/size-classes/
 */
struct UXSizeClasses {
    var compact: CGFloat
    var regular: CGFloat
    var unspecified: CGFloat

    init(compact: CGFloat, regular: CGFloat, other: CGFloat) {
        self.compact = compact
        self.regular = regular
        self.unspecified = other
    }

    subscript(sizeClass: UIUserInterfaceSizeClass) -> CGFloat {
        switch sizeClass {
            case .compact:
                return self.compact
            case .regular:
                return self.regular
            case .unspecified:
                return self.unspecified
            @unknown default:
                fatalError()
        }

    }
}

protocol HomePanelDelegate: AnyObject {
    func homePanelDidRequestToOpenInNewTab(_ url: URL, isPrivate: Bool)
    func homePanel(didSelectURL url: URL, visitType: VisitType)
    func homePanelDidRequestToOpenLibrary(panel: LibraryPanelType)
    var homePanelIsPrivate: Bool { get }
}

protocol HomePanel: Themeable {
    var homePanelDelegate: HomePanelDelegate? { get set }
}

enum HomePanelType: Int {
    case topSites = 0

    var internalUrl: URL {
        let aboutUrl: URL! = URL(string: "\(InternalURL.baseUrl)/\(AboutHomeHandler.path)")
        return URL(string: "#panel=\(self.rawValue)", relativeTo: aboutUrl)!
    }
}

protocol HomePanelContextMenu {
    func getSiteDetails(for indexPath: IndexPath) -> Site?
    func getContextMenuActions(for site: Site, with indexPath: IndexPath) -> [PhotonActionSheetItem]?
    func presentContextMenu(for indexPath: IndexPath)
    func presentContextMenu(for site: Site, with indexPath: IndexPath, completionHandler: @escaping () -> PhotonActionSheet?)
}

extension HomePanelContextMenu {
    func presentContextMenu(for indexPath: IndexPath) {
        guard let site = getSiteDetails(for: indexPath) else { return }

        presentContextMenu(for: site, with: indexPath, completionHandler: {
            return self.contextMenu(for: site, with: indexPath)
        })
    }

    func contextMenu(for site: Site, with indexPath: IndexPath) -> PhotonActionSheet? {
        guard let actions = self.getContextMenuActions(for: site, with: indexPath) else { return nil }

        let contextMenu = PhotonActionSheet(site: site, actions: actions)
        contextMenu.modalPresentationStyle = .overFullScreen
        contextMenu.modalTransitionStyle = .crossDissolve

        let generator = UIImpactFeedbackGenerator(style: .heavy)
        generator.impactOccurred()

        return contextMenu
    }

    func getDefaultContextMenuActions(for site: Site, homePanelDelegate: HomePanelDelegate?) -> [PhotonActionSheetItem]? {
        guard let siteURL = URL(string: site.url) else { return nil }

        let openInNewTabAction = PhotonActionSheetItem(title: Strings.OpenInNewTabContextMenuTitle, iconString: "quick_action_new_tab") { _, _ in
            homePanelDelegate?.homePanelDidRequestToOpenInNewTab(siteURL, isPrivate: false)
        }

        let openInNewPrivateTabAction = PhotonActionSheetItem(title: Strings.OpenInNewPrivateTabContextMenuTitle, iconString: "quick_action_new_private_tab") { _, _ in
            homePanelDelegate?.homePanelDidRequestToOpenInNewTab(siteURL, isPrivate: true)
        }

        return [openInNewTabAction, openInNewPrivateTabAction]
    }
}

class NeevaHomeViewController: UICollectionViewController, HomePanel {
    weak var homePanelDelegate: HomePanelDelegate?
    fileprivate let profile: Profile
    fileprivate let flowLayout = UICollectionViewFlowLayout()

    fileprivate lazy var emptyIncognitoDescriptionView = UIView()

    fileprivate lazy var topSitesManager: ASHorizontalScrollCellManager = {
        let manager = ASHorizontalScrollCellManager()
        return manager
    }()

    fileprivate lazy var longPressRecognizer: UILongPressGestureRecognizer = {
        return UILongPressGestureRecognizer(target: self, action: #selector(longPress))
    }()

    // Not used for displaying. Only used for calculating layout.
    lazy var topSiteCell: ASHorizontalScrollCell = {
        let customCell = ASHorizontalScrollCell(frame: CGRect(width: self.view.frame.size.width, height: 0))
        customCell.delegate = self.topSitesManager
        return customCell
    }()

    lazy var defaultBrowserCard: DefaultBrowserCard = {
        let card = DefaultBrowserCard(frame:.zero, isUserLoggedIn: NeevaUserInfo.shared.isUserLoggedIn)
        return card
    }()

    init(profile: Profile) {
        self.profile = profile
        super.init(collectionViewLayout: flowLayout)
        self.collectionView?.delegate = self
        self.collectionView?.dataSource = self

        collectionView?.addGestureRecognizer(longPressRecognizer)

        let refreshEvents: [Notification.Name] = [.DynamicFontChanged, .HomePanelPrefsChanged]
        refreshEvents.forEach { NotificationCenter.default.addObserver(self, selector: #selector(reload), name: $0, object: nil) }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        Section.allValues.forEach { self.collectionView?.register(Section($0.rawValue).cellType, forCellWithReuseIdentifier: Section($0.rawValue).cellIdentifier) }
        self.collectionView?.register(ASHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "Header")
        self.collectionView?.register(ASFooterView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: "Footer")
        collectionView?.keyboardDismissMode = .onDrag

        let isPrivate = BrowserViewController.foregroundBVC().tabManager.selectedTab?.isPrivate ?? false

        if(isPrivate){
            self.view.addSubview(emptyIncognitoDescriptionView)
            emptyIncognitoDescriptionView.layer.cornerRadius = 12
            emptyIncognitoDescriptionView.layer.masksToBounds = true

            emptyIncognitoDescriptionView.snp.makeConstraints { make in
                make.top.equalToSuperview().offset(20)
                make.bottom.equalTo(collectionView.snp.top).offset(-28)
                make.width.equalToSuperview().offset(-30)
                make.centerX.equalTo(self.view)
            }

            collectionView.snp.makeConstraints { make in
                make.top.equalTo(emptyIncognitoDescriptionView.snp.bottom)
                make.bottom.left.right.equalToSuperview()
            }

            addSubSwiftUIView(IncognitoDescriptionView(), to: emptyIncognitoDescriptionView)

        } else if #available(iOS 14.0, *), !UserDefaults.standard.bool(forKey: "DidDismissDefaultBrowserCard") || !NeevaUserInfo.shared.hasLoginCookie() {
            self.view.addSubview(defaultBrowserCard)
            defaultBrowserCard.snp.makeConstraints { make in
                make.top.equalToSuperview()
                make.bottom.equalTo(collectionView.snp.top)
                make.width.equalToSuperview()
                make.centerX.equalTo(self.view)
            }
            collectionView.snp.makeConstraints { make in
                make.top.equalTo(defaultBrowserCard.snp.bottom)
                make.bottom.left.right.equalToSuperview()
            }
            defaultBrowserCard.dismissClosure =  {
                self.defaultBrowserCard.removeFromSuperview()
                self.collectionView.snp.makeConstraints { make in
                    make.top.equalToSuperview()
                    make.bottom.left.right.equalToSuperview()
                }
            }
            defaultBrowserCard.signinHandler = {
                self.showSiteWithURLHandler(NeevaConstants.appSigninURL.asURL!)
            }
        }

        self.view.backgroundColor = UIColor.theme.homePanel.topSitesBackground
        self.profile.panelDataObservers.activityStream.delegate = self

        applyTheme()
    }
    
    public func dismissDefaultBrowserCard()
    {
        self.defaultBrowserCard.removeFromSuperview()
        self.collectionView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.bottom.left.right.equalToSuperview()
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reloadAll()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate(alongsideTransition: {context in
            //The AS context menu does not behave correctly. Dismiss it when rotating.
            if let _ = self.presentedViewController as? PhotonActionSheet {
                self.presentedViewController?.dismiss(animated: true, completion: nil)
            }
            self.collectionViewLayout.invalidateLayout()
            self.collectionView?.reloadData()
        }, completion: { _ in
            // Workaround: label positions are not correct without additional reload
            self.collectionView?.reloadData()
        })
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        self.topSitesManager.currentTraits = self.traitCollection
    }

    @objc func reload(notification: Notification) {
        reloadAll()
    }

    func applyTheme() {
        defaultBrowserCard.applyTheme()
        collectionView?.backgroundColor = UIColor.theme.homePanel.topSitesBackground
        self.view.backgroundColor = UIColor.theme.homePanel.topSitesBackground
        topSiteCell.collectionView.reloadData()
        if let collectionView = self.collectionView, collectionView.numberOfSections > 0, collectionView.numberOfItems(inSection: 0) > 0 {
            collectionView.reloadData()
        }
    }

    func scrollToTop(animated: Bool = false) {
        collectionView?.setContentOffset(.zero, animated: animated)
    }
}

// MARK: -  Section management
extension NeevaHomeViewController {
    enum Section: Int {
        case topSites

        static let allValues = [topSites]
        static let count = allValues.count

        var title: String? {
            switch self {
            case .topSites: return "TOP SITES"
            }
        }

        var headerHeight: CGSize {
            return CGSize(width: 50, height: 40)
        }

        var footerHeight: CGSize {
            return CGSize(width: 50, height: 5)
        }

        func cellHeight(_ traits: UITraitCollection, width: CGFloat) -> CGFloat {
            switch self {
            case .topSites: return 0 //calculated dynamically
            }
        }

        /*
         There are edge cases to handle when calculating section insets
        - An iPhone 7+ is considered regular width when in landscape
        - An iPad in 66% split view is still considered regular width
         */
        func sectionInsets(_ traits: UITraitCollection, frameWidth: CGFloat) -> CGFloat {
            var currentTraits = traits
            if (traits.horizontalSizeClass == .regular && UIScreen.main.bounds.size.width != frameWidth) || UIDevice.current.userInterfaceIdiom == .phone {
                currentTraits = UITraitCollection(horizontalSizeClass: .compact)
            }
            var insets = NeevaHomeUX.sectionInsetsForSizeClass[currentTraits.horizontalSizeClass]

            switch self {
            case .topSites:
                insets += NeevaHomeUX.TopSitesInsets
                return insets
            }
        }

        func cellSize(for traits: UITraitCollection, frameWidth: CGFloat) -> CGSize {
            let height = cellHeight(traits, width: frameWidth)
            let inset = sectionInsets(traits, frameWidth: frameWidth) * 2
            return CGSize(width: frameWidth - inset, height: height)
        }

        var headerView: UIView? {
            let view = ASHeaderView()
            view.title = title
            return view
        }

        var cellIdentifier: String {
            switch self {
            case .topSites: return "TopSiteCell"
            }
        }

        var cellType: UICollectionViewCell.Type {
            switch self {
            case .topSites: return ASHorizontalScrollCell.self
            }
        }

        init(at indexPath: IndexPath) {
            self.init(rawValue: indexPath.section)!
        }

        init(_ section: Int) {
            self.init(rawValue: section)!
        }
    }
}

// MARK: -  Tableview Delegate
extension NeevaHomeViewController: UICollectionViewDelegateFlowLayout {

    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionView.elementKindSectionHeader:
                let view = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "Header", for: indexPath) as! ASHeaderView
                let title = Section(indexPath.section).title
                switch Section(indexPath.section) {
                case .topSites:
                    view.title = title
                    view.titleLabel.accessibilityIdentifier = "topSitesTitle"
                    view.moreButton.isHidden = true
                    return view
            }
        case UICollectionView.elementKindSectionFooter:
                let view = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: "Footer", for: indexPath) as! ASFooterView
                switch Section(indexPath.section) {
                case .topSites:
                    return view
            }
            default:
                return UICollectionReusableView()
        }
    }

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.longPressRecognizer.isEnabled = false
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cellSize = Section(indexPath.section).cellSize(for: self.traitCollection, frameWidth: self.view.frame.width)

        switch Section(indexPath.section) {
        case .topSites:
            return CGSize(width: cellSize.width, height: 120)
        }
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        switch Section(section) {
        case .topSites:
            return Section(section).headerHeight
        }
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        switch Section(section) {
        case .topSites:
            return Section(section).footerHeight
        }
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return NeevaHomeUX.rowSpacing
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        let insets = Section(section).sectionInsets(self.traitCollection, frameWidth: self.view.frame.width)
        return UIEdgeInsets(top: 0, left: insets, bottom: 0, right: insets)
    }

    fileprivate func showSiteWithURLHandler(_ url: URL) {
        let visitType = VisitType.bookmark
        homePanelDelegate?.homePanel(didSelectURL: url, visitType: visitType)
    }
}

// MARK: - Tableview Data Source
extension NeevaHomeViewController {

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return Section.count
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        var numItems: CGFloat = NeevaHomeUX.numberOfItemsPerRowForSizeClassIpad[self.traitCollection.horizontalSizeClass]
        if UIApplication.shared.statusBarOrientation.isPortrait {
            numItems = numItems - 1
        }
        if self.traitCollection.horizontalSizeClass == .compact && UIApplication.shared.statusBarOrientation.isLandscape {
            numItems = numItems - 1
        }
        switch Section(section) {
        case .topSites:
            return topSitesManager.content.isEmpty ? 0 : 1
        }
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let identifier = Section(indexPath.section).cellIdentifier
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath)

        switch Section(indexPath.section) {
        case .topSites:
            return configureTopSitesCell(cell, forIndexPath: indexPath)
        }
    }

    //should all be collectionview
    func configureTopSitesCell(_ cell: UICollectionViewCell, forIndexPath indexPath: IndexPath) -> UICollectionViewCell {
        let topSiteCell = cell as! ASHorizontalScrollCell
        topSiteCell.delegate = self.topSitesManager
        topSiteCell.setNeedsLayout()
        topSiteCell.collectionView.reloadData()
        return cell
    }
}

// MARK: - Data Management
extension NeevaHomeViewController: DataObserverDelegate {

    // Reloads both highlights and top sites data from their respective caches. Does not invalidate the cache.
    // See ActivityStreamDataObserver for invalidation logic.
    func reloadAll() {
        TopSitesHandler.getTopSites(profile: profile).uponQueue(.main) { result in
            // If there is no pending cache update and highlights are empty. Show the onboarding screen
            self.collectionView?.reloadData()
            
            self.topSitesManager.currentTraits = self.view.traitCollection
            
            let numRows = max(self.profile.prefs.intForKey(PrefsKeys.NumberOfTopSiteRows) ?? TopSitesRowCountSettingsController.defaultNumberOfRows, 1)
            
            let maxItems = Int(numRows) * self.topSitesManager.numberOfHorizontalItems()
            
            self.topSitesManager.content = Array(result.prefix(maxItems))
            
            self.topSitesManager.urlPressedHandler = { [unowned self] url, indexPath in
                self.longPressRecognizer.isEnabled = false
                self.showSiteWithURLHandler(url as URL)
            }

            // Refresh the AS data in the background so we'll have fresh data next time we show.
            self.profile.panelDataObservers.activityStream.refreshIfNeeded(forceTopSites: false)
        }
    }

    // Invoked by the ActivityStreamDataObserver when highlights/top sites invalidation is complete.
    func didInvalidateDataSources(refresh forced: Bool, topSitesRefreshed: Bool) {
        // Do not reload panel unless we're currently showing the highlight intro or if we
        // force-reloaded the highlights or top sites. This should prevent reloading the
        // panel after we've invalidated in the background on the first load.
        if forced {
            reloadAll()
        }
    }

    func hideURLFromTopSites(_ site: Site) {
        guard let host = site.tileURL.normalizedHost else {
            return
        }
        let url = site.tileURL.absoluteString
        // if the default top sites contains the siteurl. also wipe it from default suggested sites.
        if defaultTopSites().filter({$0.url == url}).isEmpty == false {
            deleteTileForSuggestedSite(url)
        }
        profile.history.removeHostFromTopSites(host).uponQueue(.main) { result in
            guard result.isSuccess else { return }
            self.profile.panelDataObservers.activityStream.refreshIfNeeded(forceTopSites: true)
        }
    }

    func pinTopSite(_ site: Site) {
        profile.history.addPinnedTopSite(site).uponQueue(.main) { result in
            guard result.isSuccess else { return }
            self.profile.panelDataObservers.activityStream.refreshIfNeeded(forceTopSites: true)
        }
    }

    func removePinTopSite(_ site: Site) {
        profile.history.removeFromPinnedTopSites(site).uponQueue(.main) { result in
            guard result.isSuccess else { return }
            self.profile.panelDataObservers.activityStream.refreshIfNeeded(forceTopSites: true)
        }
    }

    fileprivate func deleteTileForSuggestedSite(_ siteURL: String) {
        var deletedSuggestedSites = profile.prefs.arrayForKey(TopSitesHandler.DefaultSuggestedSitesKey) as? [String] ?? []
        deletedSuggestedSites.append(siteURL)
        profile.prefs.setObject(deletedSuggestedSites, forKey: TopSitesHandler.DefaultSuggestedSitesKey)
    }

    func defaultTopSites() -> [Site] {
        let suggested = SuggestedSites.asArray()
        let deleted = profile.prefs.arrayForKey(TopSitesHandler.DefaultSuggestedSitesKey) as? [String] ?? []
        return suggested.filter({deleted.firstIndex(of: $0.url) == .none})
    }

    @objc fileprivate func longPress(_ longPressGestureRecognizer: UILongPressGestureRecognizer) {
        guard longPressGestureRecognizer.state == .began else { return }

        let point = longPressGestureRecognizer.location(in: self.collectionView)
        guard let indexPath = self.collectionView?.indexPathForItem(at: point) else { return }

        switch Section(indexPath.section) {
        case .topSites:
            let topSiteCell = self.collectionView?.cellForItem(at: indexPath) as! ASHorizontalScrollCell
            let pointInTopSite = longPressGestureRecognizer.location(in: topSiteCell.collectionView)
            guard let topSiteIndexPath = topSiteCell.collectionView.indexPathForItem(at: pointInTopSite) else { return }
            presentContextMenu(for: topSiteIndexPath)
        }
    }
}

extension NeevaHomeViewController: HomePanelContextMenu {
    func presentContextMenu(for site: Site, with indexPath: IndexPath, completionHandler: @escaping () -> PhotonActionSheet?) {
        guard let contextMenu = completionHandler() else { return }
        self.present(contextMenu, animated: true, completion: nil)
    }

    func getSiteDetails(for indexPath: IndexPath) -> Site? {
        switch Section(indexPath.section) {
        case .topSites:
            return topSitesManager.content[indexPath.item]
        }
    }

    func getContextMenuActions(for site: Site, with indexPath: IndexPath) -> [PhotonActionSheetItem]? {
        guard let siteURL = URL(string: site.url) else { return nil }
        var sourceView: UIView?
        switch Section(indexPath.section) {
        case .topSites:
            if let topSiteCell = self.collectionView?.cellForItem(at: IndexPath(row: 0, section: 0)) as? ASHorizontalScrollCell {
                sourceView = topSiteCell.collectionView.cellForItem(at: indexPath)
            }
        }

        let openInNewTabAction = PhotonActionSheetItem(title: Strings.OpenInNewTabContextMenuTitle, iconString: "quick_action_new_tab") { _, _ in
            self.homePanelDelegate?.homePanelDidRequestToOpenInNewTab(siteURL, isPrivate: false)
        }

        let openInNewPrivateTabAction = PhotonActionSheetItem(title: Strings.OpenInNewPrivateTabContextMenuTitle, iconString: "quick_action_new_private_tab") { _, _ in
            self.homePanelDelegate?.homePanelDidRequestToOpenInNewTab(siteURL, isPrivate: true)
        }

        let shareAction = PhotonActionSheetItem(title: Strings.ShareContextMenuTitle, iconString: "action_share", handler: { _, _ in
            let helper = ShareExtensionHelper(url: siteURL, tab: nil)
            let controller = helper.createActivityViewController({ (_, _) in })
            if UI_USER_INTERFACE_IDIOM() == .pad, let popoverController = controller.popoverPresentationController {
                let cellRect = sourceView?.frame ?? .zero
                let cellFrameInSuperview = self.collectionView?.convert(cellRect, to: self.collectionView) ?? .zero

                popoverController.sourceView = sourceView
                popoverController.sourceRect = CGRect(origin: CGPoint(x: cellFrameInSuperview.size.width/2, y: cellFrameInSuperview.height/2), size: .zero)
                popoverController.permittedArrowDirections = [.up, .down, .left]
                popoverController.delegate = self
            }
            self.present(controller, animated: true, completion: nil)
        })

        let removeTopSiteAction = PhotonActionSheetItem(title: Strings.RemoveContextMenuTitle, iconString: "action_remove", handler: { _, _ in
            self.hideURLFromTopSites(site)
        })

        let pinTopSite = PhotonActionSheetItem(title: Strings.PinTopsiteActionTitle, iconString: "action_pin", handler: { _, _ in
            self.pinTopSite(site)
        })

        let removePinTopSite = PhotonActionSheetItem(title: Strings.RemovePinTopsiteActionTitle, iconString: "action_unpin", handler: { _, _ in
            self.removePinTopSite(site)
        })

        let topSiteActions: [PhotonActionSheetItem]
        if let _ = site as? PinnedSite {
            topSiteActions = [removePinTopSite]
        } else {
            topSiteActions = [pinTopSite, removeTopSiteAction]
        }

        var actions = [openInNewTabAction, openInNewPrivateTabAction, shareAction]

        switch Section(indexPath.section) {
            case .topSites: actions.append(contentsOf: topSiteActions)
        }
        return actions
    }
}

extension NeevaHomeViewController: UIPopoverPresentationControllerDelegate {

    // Dismiss the popover if the device is being rotated.
    // This is used by the Share UIActivityViewController action sheet on iPad
    func popoverPresentationController(_ popoverPresentationController: UIPopoverPresentationController, willRepositionPopoverTo rect: UnsafeMutablePointer<CGRect>, in view: AutoreleasingUnsafeMutablePointer<UIView>) {
        popoverPresentationController.presentedViewController.dismiss(animated: false, completion: nil)
    }
}

// MARK: - Section Header View
private struct NeevaHomeHeaderViewUX {
    static var SeparatorColor: UIColor { return UIColor.theme.homePanel.separator }
    // static let TextFont = DynamicFontHelper.defaultHelper.SmallSizeHeavyWeightAS
    static let ButtonFont = DynamicFontHelper.defaultHelper.MediumSizeBoldFontAS
    static let SeparatorHeight = 0.5
    static let Insets: CGFloat = UIDevice.current.userInterfaceIdiom == .pad ? NeevaHomeUX.SectionInsetsForIpad + NeevaHomeUX.MinimumInsets : NeevaHomeUX.MinimumInsets
    static let TitleTopInset: CGFloat = 5
}

class ASFooterView: UICollectionReusableView {

    var separatorLineView: UIView?
    var leftConstraint: Constraint? //This constraint aligns content (Titles, buttons) between all sections.

    override init(frame: CGRect) {
        super.init(frame: frame)

        let separatorLine = UIView()
        self.backgroundColor = UIColor.clear
        addSubview(separatorLine)
        separatorLine.snp.makeConstraints { make in
            make.height.equalTo(NeevaHomeHeaderViewUX.SeparatorHeight)
            leftConstraint = make.leading.equalTo(self.safeArea.leading).inset(insets).constraint
            make.trailing.equalTo(self.safeArea.trailing).inset(insets)
            make.top.equalTo(self.snp.top)
        }
        separatorLineView = separatorLine
        applyTheme()
    }

    var insets: CGFloat {
        return UIScreen.main.bounds.size.width == self.frame.size.width && UIDevice.current.userInterfaceIdiom == .pad ? NeevaHomeHeaderViewUX.Insets : NeevaHomeUX.MinimumInsets
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        separatorLineView?.isHidden = false
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        // update the insets every time a layout happens.Insets change depending on orientation or size (ipad split screen)
        leftConstraint?.update(offset: insets)
    }
}

extension ASFooterView: Themeable {
    func applyTheme() {
        separatorLineView?.backgroundColor = UIColor.clear
    }
}

class ASHeaderView: UICollectionReusableView {
    static let verticalInsets: CGFloat = 4

    lazy fileprivate var titleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.text = self.title
        titleLabel.textColor = UIColor.Neeva.Gray60
        titleLabel.font = UIFont.systemFont(ofSize: 13, weight: UIFont.Weight.bold)
        titleLabel.minimumScaleFactor = 0.6
        titleLabel.numberOfLines = 1
        titleLabel.adjustsFontSizeToFitWidth = true
        return titleLabel
    }()

    lazy var moreButton: UIButton = {
        let button = UIButton()
        button.isHidden = true
        button.titleLabel?.font = NeevaHomeHeaderViewUX.ButtonFont
        button.contentHorizontalAlignment = .right
        button.setTitleColor(UIConstants.SystemBlueColor, for: .normal)
        button.setTitleColor(UIColor.Photon.Grey50, for: .highlighted)
        return button
    }()

    var title: String? {
        willSet(newTitle) {
            titleLabel.text = newTitle
        }
    }

    var leftConstraint: Constraint?
    var rightConstraint: Constraint?

    var titleInsets: CGFloat {
        get {
            return UIScreen.main.bounds.size.width == self.frame.size.width && UIDevice.current.userInterfaceIdiom == .pad ? NeevaHomeHeaderViewUX.Insets : NeevaHomeUX.MinimumInsets
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        moreButton.isHidden = true
        moreButton.setTitle(nil, for: .normal)
        moreButton.accessibilityIdentifier = nil;
        titleLabel.text = nil
        moreButton.removeTarget(nil, action: nil, for: .allEvents)
        titleLabel.textColor = UIColor.Neeva.Gray60
        moreButton.setTitleColor(UIConstants.SystemBlueColor, for: .normal)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(titleLabel)
        addSubview(moreButton)
        moreButton.snp.makeConstraints { make in
            make.top.equalTo(self.snp.top).offset(ASHeaderView.verticalInsets)
            make.bottom.equalToSuperview().offset(-ASHeaderView.verticalInsets)
            self.rightConstraint = make.trailing.equalTo(self.safeArea.trailing).inset(-titleInsets).constraint
        }
        moreButton.setContentCompressionResistancePriority(.required, for: .horizontal)
        titleLabel.snp.makeConstraints { make in
            make.leading.equalTo(NeevaHomeUX.rowSpacing)
            make.trailing.equalTo(moreButton.snp.leading).inset(-NeevaHomeHeaderViewUX.TitleTopInset)
            make.top.equalTo(self.snp.top).offset(ASHeaderView.verticalInsets)
            make.bottom.equalToSuperview().offset(-ASHeaderView.verticalInsets)
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        leftConstraint?.update(offset: titleInsets)
        rightConstraint?.update(offset: -titleInsets)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
