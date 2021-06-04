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

extension EnvironmentValues {
    private struct OpenInNewTabKey: EnvironmentKey {
        static var defaultValue: ((URL, _ isPrivate: Bool) -> ())? = nil
    }

    public var openInNewTab: (URL, _ isPrivate: Bool) -> () {
        get { self[OpenInNewTabKey] ?? { _,_ in fatalError(".environment(\\.openInNewTab) must be specified") } }
        set { self[OpenInNewTabKey] = newValue }
    }

    private struct ShareURLKey: EnvironmentKey {
        static var defaultValue: ((URL) -> ())? = nil
    }

    public var shareURL: (URL) -> () {
        get { self[ShareURLKey] ?? { _ in fatalError(".environment(\\.shareURL) must be specified") } }
        set { self[ShareURLKey] = newValue }
    }

    private struct HideTopSiteKey: EnvironmentKey {
        static var defaultValue: ((Site) -> ())? = nil
    }

    public var hideTopSite: (Site) -> () {
        get { self[HideTopSiteKey] ?? { _ in fatalError(".environment(\\.hideTopSite) must be specified") } }
        set { self[HideTopSiteKey] = newValue }
    }
}

protocol HomePanelDelegate: AnyObject {
    func homePanelDidRequestToOpenInNewTab(_ url: URL, isPrivate: Bool)
    func homePanel(didSelectURL url: URL, visitType: VisitType)
    func homePanelDidRequestToOpenLibrary(panel: LibraryPanelType)
    func homePanel(didEnterQuery query: String)
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

class NeevaHomeViewController: UIViewController, HomePanel {
    weak var homePanelDelegate: HomePanelDelegate?
    fileprivate let profile: Profile
    fileprivate let flowLayout = UICollectionViewFlowLayout()

    lazy var homeView: UIView = {
        let home = NeevaHome(viewModel: homeViewModel)
        let controller = UIHostingController(
            rootView: home
                .environmentObject(suggestedSitesViewModel)
                .environmentObject(suggestedSearchesModel)
                .environment(\.setSearchInput) { [weak self] query in
                    self?.homePanelDelegate?.homePanel(didEnterQuery: query)
                }
                .environment(\.onOpenURL) { [weak self] url in
                    self?.showSiteWithURLHandler(url)
                }
                .environment(\.shareURL) { [weak self] url in
                    let helper = ShareExtensionHelper(url: url, tab: nil)
                    let controller = helper.createActivityViewController({ (_, _) in })
                    controller.modalPresentationStyle = .formSheet
                    self?.present(controller, animated: true, completion: nil)
                }
                .environment(\.hideTopSite) { [weak self] url in
                    self?.hideURLFromTopSites(url)
                }
                .environment(\.openInNewTab) { [weak self] url, isPrivate in
                    self?.homePanelDelegate?.homePanelDidRequestToOpenInNewTab(url, isPrivate: isPrivate)
                }

        )
        controller.view.backgroundColor = UIColor.HomePanel.topSitesBackground
        view.addSubview(controller.view)
        return controller.view
    }()

    var suggestedSearchesModel = SuggestedSearchesModel(suggestedQueries: [])
    var suggestedSitesViewModel = SuggestedSitesViewModel(sites: [])

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

// TODO: remove this extension once pin/unpin is finalized
extension NeevaHomeViewController {
    func getContextMenuActions(for site: Site) -> [PhotonActionSheetItem]? {
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
                topSiteActions = [pinTopSite]
            }
        } else {
            topSiteActions = []
        }

        return topSiteActions
    }
}

extension NeevaHomeViewController: UIPopoverPresentationControllerDelegate {

    // Dismiss the popover if the device is being rotated.
    // This is used by the Share UIActivityViewController action sheet on iPad
    func popoverPresentationController(_ popoverPresentationController: UIPopoverPresentationController, willRepositionPopoverTo rect: UnsafeMutablePointer<CGRect>, in view: AutoreleasingUnsafeMutablePointer<UIView>) {
        popoverPresentationController.presentedViewController.dismiss(animated: false, completion: nil)
    }
}
