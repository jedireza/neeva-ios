// Copyright Neeva. All rights reserved.

import Defaults
import Shared
import Storage

protocol ZeroQueryPanelDelegate: AnyObject {
    func zeroQueryPanelDidRequestToOpenInNewTab(_ url: URL, isPrivate: Bool)
    func zeroQueryPanel(didSelectURL url: URL, visitType: VisitType)
    func zeroQueryPanel(didEnterQuery query: String)
    func zeroQueryPanelDidRequestToSaveToSpace(_ url: URL, title: String?, description: String?)
}

enum ZeroQueryOpenedLocation: Equatable {
    case tabTray
    case openTab(Tab?)
    case createdTab

    var openedTab: Tab? {
        switch self {
        case .openTab(let tab):
            return tab
        default:
            return nil
        }
    }
}

class ZeroQueryModel: ObservableObject {
    @Published var isPrivate = false
    @Published var promoCard: PromoCardType?
    @Published var showRatingsCard: Bool = false
    @Published var openedFrom: ZeroQueryOpenedLocation?

    let bvc: BrowserViewController
    let profile: Profile
    let shareURLHandler: (URL) -> Void
    var delegate: ZeroQueryPanelDelegate?
    var isLazyTab = false

    init(bvc: BrowserViewController, profile: Profile, shareURLHandler: @escaping (URL) -> Void) {
        self.bvc = bvc
        self.profile = profile
        self.shareURLHandler = shareURLHandler
        updateState()
        profile.panelDataObservers.activityStream.refreshIfNeeded(forceTopSites: true)
    }

    func signIn() {
        self.delegate?.zeroQueryPanel(
            didSelectURL: NeevaConstants.appSigninURL,
            visitType: .bookmark)
    }

    func handleReferralPromo() {
        // log click referral promo from zero query page
        var attributes = EnvironmentHelper.shared.getAttributes()
        attributes.append(ClientLogCounterAttribute(key: "source", value: "zero query"))
        ClientLogger.shared.logCounter(
            .OpenReferralPromo, attributes: attributes)
        self.delegate?.zeroQueryPanel(
            didSelectURL: NeevaConstants.appReferralsURL,
            visitType: .bookmark)
    }

    func updateState() {
        isPrivate = bvc.tabManager.isIncognito

        // TODO: remove once all users have upgraded
        if UserDefaults.standard.bool(forKey: "DidDismissDefaultBrowserCard") {
            UserDefaults.standard.removeObject(forKey: "DidDismissDefaultBrowserCard")
            Defaults[.didDismissDefaultBrowserCard] = true
        }

        if NeevaFeatureFlags[.referralPromo] && !Defaults[.didDismissReferralPromoCard] {
            promoCard = .referralPromo {
                self.handleReferralPromo()
            } onClose: {
                // log closing referral promo from zero query
                var attributes = EnvironmentHelper.shared.getAttributes()
                attributes.append(ClientLogCounterAttribute(key: "source", value: "zero query"))
                ClientLogger.shared.logCounter(
                    .CloseReferralPromo, attributes: attributes)
                self.promoCard = nil
                Defaults[.didDismissReferralPromoCard] = true
            }
        } else if !NeevaUserInfo.shared.hasLoginCookie() {
            promoCard = .neevaSignIn {
                ClientLogger.shared.logCounter(
                    .PromoSignin, attributes: EnvironmentHelper.shared.getAttributes())
                self.signIn()
            }
        } else if !Defaults[.didDismissDefaultBrowserCard] {
            promoCard = .defaultBrowser {
                ClientLogger.shared.logCounter(
                    .PromoDefaultBrowser, attributes: EnvironmentHelper.shared.getAttributes())
                self.bvc.presentDBOnboardingViewController()

                // Set default browser onboarding did show to true so it will not show again after user clicks this button
                Defaults[.didShowDefaultBrowserOnboarding] = true
            } onClose: {
                ClientLogger.shared.logCounter(
                    .CloseDefaultBrowserPromo, attributes: EnvironmentHelper.shared.getAttributes())
                self.promoCard = nil
                Defaults[.didDismissDefaultBrowserCard] = true
            }
        } else {
            promoCard = nil
        }

        // In case the ratings card server update was unsuccessful: each time we enter a ZeroQueryPage, check whether local change has been synced to server
        // The check is only performed once the local ratings card has been hidden
        if Defaults[.ratingsCardHidden] && UserFlagStore.shared.state == .ready
            && !UserFlagStore.shared.hasFlag(.dismissedRatingPromo)
        {
            UserFlagStore.shared.setFlag(.dismissedRatingPromo, action: {})
        }

        showRatingsCard =
            NeevaFeatureFlags[.appStoreRatingPromo]
            && promoCard == nil
            && Defaults[.loginLastWeekTimeStamp].count == 10
            && (!Defaults[.ratingsCardHidden]
                || (UserFlagStore.shared.state == .ready
                    && !UserFlagStore.shared.hasFlag(.dismissedRatingPromo)))
    }

    func hideURLFromTopSites(_ site: Site) {
        guard let host = site.tileURL.normalizedHost else {
            return
        }
        let url = site.tileURL
        // if the default top sites contains the siteurl. also wipe it from default suggested sites.
        if TopSitesHandler.defaultTopSites().filter({ $0.url == url }).isEmpty == false {
            Defaults[.deletedSuggestedSites].append(url.absoluteString)
        }
        profile.history.removeHostFromTopSites(host).uponQueue(.main) { result in
            guard result.isSuccess else { return }
            self.profile.panelDataObservers.activityStream.refreshIfNeeded(forceTopSites: true)
        }
    }

    @discardableResult public func promoteToRealTabIfNecessary(
        url: URL, tabManager: TabManager
    ) -> Bool {
        guard isLazyTab else {
            return false
        }
        tabManager.select(tabManager.addTab(URLRequest(url: url), isPrivate: isPrivate))
        reset(bvc: nil, createdLazyTab: true)
        return true
    }

    public func reset(bvc: BrowserViewController?, createdLazyTab: Bool = false) {
        if let bvc = bvc, bvc.tabManager.isIncognito, isLazyTab && !createdLazyTab {
            bvc.cardGridViewController.toolbarModel.onToggleIncognito()
        }

        isLazyTab = false
        openedFrom = nil
    }
}
