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
    private struct HideTopSiteKey: EnvironmentKey {
        static var defaultValue: ((Site) -> ())? = nil
    }

    public var zeroQueryHideTopSite: (Site) -> () {
        get { self[HideTopSiteKey] ?? { _ in fatalError(".environment(\\.zeroQueryHideTopSite) must be specified") } }
        set { self[HideTopSiteKey] = newValue }
    }
}

protocol ZeroQueryPanelDelegate: AnyObject {
    func zeroQueryPanelDidRequestToOpenInNewTab(_ url: URL, isPrivate: Bool)
    func zeroQueryPanel(didSelectURL url: URL, visitType: VisitType)
    func zeroQueryPanelDidRequestToOpenLibrary(panel: LibraryPanelType)
    func zeroQueryPanel(didEnterQuery query: String)
}

class ZeroQueryViewController: UIViewController {
    weak var delegate: ZeroQueryPanelDelegate?
    fileprivate let profile: Profile
    fileprivate let flowLayout = UICollectionViewFlowLayout()

    lazy var zeroQueryView: UIView = {
        let controller = UIHostingController(
            rootView: ZeroQueryView(viewModel: model)
                .environmentObject(suggestedSitesViewModel)
                .environmentObject(suggestedSearchesModel)
                .environment(\.setSearchInput) { [weak self] query in
                    self?.delegate?.zeroQueryPanel(didEnterQuery: query)
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
                .environment(\.zeroQueryHideTopSite) { [weak self] url in
                    self?.hideURLFromTopSites(url)
                }
                .environment(\.openInNewTab) { [weak self] url, isPrivate in
                    self?.delegate?.zeroQueryPanelDidRequestToOpenInNewTab(url, isPrivate: isPrivate)
                }

        )
        controller.view.backgroundColor = UIColor.HomePanel.topSitesBackground
        view.addSubview(controller.view)
        return controller.view
    }()

    var suggestedSearchesModel = SuggestedSearchesModel(suggestedQueries: [])
    var suggestedSitesViewModel = SuggestedSitesViewModel(sites: [])

    var model = ZeroQueryModel()

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

        self.zeroQueryView.snp.makeConstraints { make in
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
        delegate?.zeroQueryPanel(didSelectURL: url, visitType: visitType)
    }
}


// MARK: - Data Management
extension ZeroQueryViewController: DataObserverDelegate {
    // Reloads both highlights and top sites data from their respective caches. Does not invalidate the cache.
    // See ActivityStreamDataObserver for invalidation logic.
    func reloadAll() {
        TopSitesHandler.getTopSites(profile: profile).uponQueue(.main) { result in

            self.model.signInHandler = {
                self.showSiteWithURLHandler(NeevaConstants.appSigninURL)
            }
            self.model.updateState()

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
extension ZeroQueryViewController {
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

extension ZeroQueryViewController: UIPopoverPresentationControllerDelegate {

    // Dismiss the popover if the device is being rotated.
    // This is used by the Share UIActivityViewController action sheet on iPad
    func popoverPresentationController(_ popoverPresentationController: UIPopoverPresentationController, willRepositionPopoverTo rect: UnsafeMutablePointer<CGRect>, in view: AutoreleasingUnsafeMutablePointer<UIView>) {
        popoverPresentationController.presentedViewController.dismiss(animated: false, completion: nil)
    }
}
