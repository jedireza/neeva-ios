// Copyright Neeva. All rights reserved.

import Defaults
import Shared
import Storage

class ZeroQueryModel: ObservableObject {
    @Published var isPrivate: Bool = false
    @Published var promoCard: PromoCardType? = nil
    @Published var buttonClickHandler: () -> Void = {}

    var signInHandler: () -> Void = {}
    var referralPromoHandler: () -> Void = {}

    func updateState() {
        isPrivate = BrowserViewController.foregroundBVC().tabManager.selectedTab?.isPrivate ?? false

        // TODO: remove once all users have upgraded
        if UserDefaults.standard.bool(forKey: "DidDismissDefaultBrowserCard") {
            UserDefaults.standard.removeObject(forKey: "DidDismissDefaultBrowserCard")
            Defaults[.didDismissDefaultBrowserCard] = true
        }

        if NeevaFeatureFlags[.referralPromo] && !Defaults[.didDismissReferralPromoCard] {
            promoCard = .referralPromo {
                self.referralPromoHandler()
            } onClose: {
                ClientLogger.shared.logCounter(
                    .CloseDefaultBrowserPromo, attributes: EnvironmentHelper.shared.getAttributes())
                self.promoCard = nil
                Defaults[.didDismissReferralPromoCard] = true
            }
        } else if !NeevaUserInfo.shared.hasLoginCookie() {
            promoCard = .neevaSignIn {
                ClientLogger.shared.logCounter(
                    .PromoSignin, attributes: EnvironmentHelper.shared.getAttributes())
                self.signInHandler()
            }
        } else if !Defaults[.didDismissDefaultBrowserCard] {
            promoCard = .defaultBrowser {
                ClientLogger.shared.logCounter(
                    .PromoDefaultBrowser, attributes: EnvironmentHelper.shared.getAttributes())
                BrowserViewController.foregroundBVC().presentDBOnboardingViewController()

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
    }
}

class SuggestedSitesViewModel: ObservableObject {
    @Published var sites: [Site]

    init(sites: [Site]) {
        self.sites = sites
    }

    #if DEBUG
        static let preview = SuggestedSitesViewModel(
            sites: [
                .init(url: "https://amazon.com", title: "Amazon", id: 1),
                .init(url: "https://youtube.com", title: "YouTube", id: 2),
                .init(url: "https://twitter.com", title: "Twitter", id: 3),
                .init(url: "https://facebook.com", title: "Facebook", id: 4),
                .init(url: "https://facebook.com", title: "Facebook", id: 5),
                .init(url: "https://twitter.com", title: "Twitter", id: 6),
            ]
        )
    #endif
}

class SuggestedSearchesModel: ObservableObject {
    @Published var suggestedQueries = [(query: String, site: Site)]()

    init(suggestedQueries: [(String, Site)]) {
        self.suggestedQueries = suggestedQueries
    }

    var searchUrlForQuery: String {
        return neevaSearchEngine.searchURLForQuery("blank")!.normalizedHostAndPath!
    }

    func reload(from profile: Profile, completion: (() -> Void)? = nil) {
        guard
            let deferredHistory = profile.history.getFrecentHistory().getSites(
                matchingSearchQuery: searchUrlForQuery, limit: 100) as? CancellableDeferred
        else {
            assertionFailure("FrecentHistory query should be cancellable")
            return
        }

        deferredHistory.uponQueue(.main) { result in
            guard !deferredHistory.cancelled else {
                return
            }

            var deferredHistorySites = result.successValue?.asArray().compactMap { $0 } ?? []
            var topFrecentHistorySite: Site?
            if deferredHistorySites.count > 0 {
                topFrecentHistorySite = deferredHistorySites[0]
                deferredHistorySites.removeFirst()
            }
            // TODO: https://github.com/neevaco/neeva-ios-phoenix/issues/1027
            deferredHistorySites.sort { siteA, siteB in
                return siteA.latestVisit?.date ?? 0 > siteB.latestVisit?.date ?? 0
            }
            self.suggestedQueries = deferredHistorySites.compactMap { site in
                if let query = neevaSearchEngine.queryForSearchURL(site.url) {
                    return (query, site)
                } else {
                    return nil
                }
            }
            if let topFrecentHistorySite = topFrecentHistorySite,
                let query = neevaSearchEngine.queryForSearchURL(topFrecentHistorySite.url)
            {
                self.suggestedQueries.insert((query, topFrecentHistorySite), at: 0)
            }

            if let completion = completion {
                completion()
            }
        }
    }
}
