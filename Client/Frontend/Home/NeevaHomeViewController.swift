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
import Defaults

private let log = Logger.browserLogger

// MARK: -  Lifecycle
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

protocol HomePanel {
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
    func getContextMenuActions(for site: Site) -> [PhotonActionSheetItem]?
    func presentContextMenu(for site: Site)
    func presentContextMenu(for site: Site, completionHandler: @escaping () -> PhotonActionSheet?)
}

extension HomePanelContextMenu {
    func presentContextMenu(for site: Site) {
        presentContextMenu(for: site, completionHandler: {
            return self.contextMenu(for: site)
        })
    }

    func contextMenu(for site: Site) -> PhotonActionSheet? {
        guard let actions = self.getContextMenuActions(for: site) else { return nil }

        let contextMenu = PhotonActionSheet(site: site, actions: actions)
        contextMenu.modalPresentationStyle = .overFullScreen
        contextMenu.modalTransitionStyle = .crossDissolve

        let generator = UIImpactFeedbackGenerator(style: .heavy)
        generator.impactOccurred()

        return contextMenu
    }

    func getDefaultContextMenuActions(for site: Site, homePanelDelegate: HomePanelDelegate?) -> [PhotonActionSheetItem]? {
        guard let siteURL = URL(string: site.url) else { return nil }

        let openInNewTabAction = PhotonActionSheetItem(title: Strings.OpenInNewTabContextMenuTitle, iconString: "plus.square", iconType: .SystemImage, iconAlignment: .right) { _, _ in
            homePanelDelegate?.homePanelDidRequestToOpenInNewTab(siteURL, isPrivate: false)
        }

        let openInNewIncognitoTabAction = PhotonActionSheetItem(title: Strings.OpenInNewIncognitoTabContextMenuTitle, iconString: "incognito", iconAlignment: .right) { _, _ in
            homePanelDelegate?.homePanelDidRequestToOpenInNewTab(siteURL, isPrivate: true)
        }

        return [openInNewTabAction, openInNewIncognitoTabAction]
    }
}

class NeevaHomeViewController: UIViewController, HomePanel {
    weak var homePanelDelegate: HomePanelDelegate?
    fileprivate let profile: Profile
    fileprivate let flowLayout = UICollectionViewFlowLayout()

    lazy var homeView: UIView = {
        let home = NeevaHome(viewModel: homeViewModel)
        let controller = UIHostingController(rootView: home
                                                .environmentObject(suggestedSitesViewModel))
        controller.view.backgroundColor = UIColor.HomePanel.topSitesBackground
        view.addSubview(controller.view)
        return controller.view
    }()

    var suggestedSearchesModel = SuggestedSearchesModel()
    var suggestedSitesViewModel = SuggestedSitesViewModel(sites: [Site](), onSuggestedSiteClicked: { _ in }, onSuggestedSiteLongPressed: { _ in })
    var homeViewModel = HomeViewModel()

    init(profile: Profile) {
        self.profile = profile
        super.init(nibName: nil, bundle: nil)

        let refreshEvents: [Notification.Name] = [.DynamicFontChanged, .HomePanelPrefsChanged]
        refreshEvents.forEach { NotificationCenter.default.addObserver(self, selector: #selector(reload), name: $0, object: nil) }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.homeView.snp.makeConstraints { make in
            make.top.bottom.left.right.equalToSuperview()
        }

        self.view.backgroundColor = UIColor.HomePanel.topSitesBackground
        self.profile.panelDataObservers.activityStream.delegate = self
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reloadAll()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        reloadAll()
    }

    @objc func reload(notification: Notification) {
        reloadAll()
    }

    fileprivate func showSiteWithURLHandler(_ url: URL) {
        let visitType = VisitType.bookmark
        homePanelDelegate?.homePanel(didSelectURL: url, visitType: visitType)
    }
}


// MARK: - Data Management
extension NeevaHomeViewController: DataObserverDelegate {
    // Reloads both highlights and top sites data from their respective caches. Does not invalidate the cache.
    // See ActivityStreamDataObserver for invalidation logic.
    func reloadAll() {
        TopSitesHandler.getTopSites(profile: profile).uponQueue(.main) { result in

            self.homeViewModel.signInHandler = {
                self.showSiteWithURLHandler(NeevaConstants.appSigninURL)
            }
            self.homeViewModel.updateState()

            let maxItems = 8

            self.suggestedSitesViewModel.sites = Array(result.prefix(maxItems))

            self.suggestedSitesViewModel.onSuggestedSiteClicked = { [unowned self] url in
                self.showSiteWithURLHandler(url as URL)
            }

            self.suggestedSitesViewModel.onSuggestedSiteLongPressed = { [unowned self] site in
                self.presentContextMenu(for: (site as Site))
            }

            self.suggestedSearchesModel.reload(from: self.profile)

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
        Defaults[.deletedSuggestedSites].append(siteURL)
    }

    func defaultTopSites() -> [Site] {
        TopSitesHandler.defaultTopSites()
    }
}

extension NeevaHomeViewController: HomePanelContextMenu {
    func getSiteDetails(for indexPath: IndexPath) -> Site? {
        return suggestedSitesViewModel.sites[indexPath.item]
    }

    func presentContextMenu(for site: Site, completionHandler: @escaping () -> PhotonActionSheet?) {
        guard let contextMenu = completionHandler() else { return }
        self.present(contextMenu, animated: true, completion: nil)
    }

    func getContextMenuActions(for site: Site) -> [PhotonActionSheetItem]? {
        guard let siteURL = URL(string: site.url) else { return nil }
        var sourceView: UIView?
        sourceView = homeView

        let openInNewTabAction = PhotonActionSheetItem(title: Strings.OpenInNewTabContextMenuTitle, iconString: "plus.square", iconType: .SystemImage, iconAlignment: .right) { _, _ in
            self.homePanelDelegate?.homePanelDidRequestToOpenInNewTab(siteURL, isPrivate: false)
        }

        let openInNewIncognitoTabAction = PhotonActionSheetItem(title: Strings.OpenInNewIncognitoTabContextMenuTitle, iconString: "incognito", iconAlignment: .right) { _, _ in
            self.homePanelDelegate?.homePanelDidRequestToOpenInNewTab(siteURL, isPrivate: true)
        }

        let shareAction = PhotonActionSheetItem(title: Strings.ShareContextMenuTitle, iconString: "square.and.arrow.up", iconType: .SystemImage, iconAlignment: .right, handler: { _, _ in
            let helper = ShareExtensionHelper(url: siteURL, tab: nil)
            let controller = helper.createActivityViewController({ (_, _) in })
            if UI_USER_INTERFACE_IDIOM() == .pad, let popoverController = controller.popoverPresentationController {
                let cellRect = sourceView?.frame ?? .zero
                let cellFrameInSuperview = self.homeView.convert(cellRect, to: self.homeView) ?? .zero

                popoverController.sourceView = sourceView
                popoverController.sourceRect = CGRect(origin: CGPoint(x: cellFrameInSuperview.size.width/2, y: cellFrameInSuperview.height/2), size: .zero)
                popoverController.permittedArrowDirections = [.up, .down, .left]
                popoverController.delegate = self
            }
            self.present(controller, animated: true, completion: nil)
        })

        let removeTopSiteAction = PhotonActionSheetItem(title: Strings.RemoveContextMenuTitle, iconString: "trash", iconType: .SystemImage, iconAlignment: .right, iconTint: .systemRed, handler: { _, _ in
            self.hideURLFromTopSites(site)
        })

        let topSiteActions: [PhotonActionSheetItem]
        if FeatureFlag[.pinToTopSites] {
            let pinTopSite = PhotonActionSheetItem(title: Strings.PinTopsiteActionTitle, iconString: "action_pin", iconAlignment: .right, handler: { _, _ in
                self.pinTopSite(site)
            })
            let removePinTopSite = PhotonActionSheetItem(title: Strings.RemovePinTopsiteActionTitle, iconString: "action_unpin", iconAlignment: .right, handler: { _, _ in
                self.removePinTopSite(site)
            })
            if let _ = site as? PinnedSite {
                topSiteActions = [removePinTopSite]
            } else {
                topSiteActions = [pinTopSite, removeTopSiteAction]
            }
        } else {
            topSiteActions = [removeTopSiteAction]
        }

        var actions = [openInNewTabAction, openInNewIncognitoTabAction, shareAction]

        actions.append(contentsOf: topSiteActions)
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
