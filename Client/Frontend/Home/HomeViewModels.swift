// Copyright Neeva. All rights reserved.

import Storage
import Defaults
import Shared

class HomeViewModel: ObservableObject {
    @Published var isPrivate: Bool = false
    @Published var promoCard: PromoCardType? = nil
    @Published var buttonClickHandler: () -> () = {}

    var signInHandler: () -> () = {}

    func updateState() {
        isPrivate = BrowserViewController.foregroundBVC().tabManager.selectedTab?.isPrivate ?? false

        // TODO: remove once all users have upgraded
        if UserDefaults.standard.bool(forKey: "DidDismissDefaultBrowserCard") {
            UserDefaults.standard.removeObject(forKey: "DidDismissDefaultBrowserCard")
            Defaults[.didDismissDefaultBrowserCard] = true
        }

        if !NeevaUserInfo.shared.hasLoginCookie() {
            promoCard = .neevaSignIn {
                ClientLogger.shared.logCounter(.PromoSignin, attributes: EnvironmentHelper.shared.getAttributes())
                self.signInHandler()
            }
        } else if !Defaults[.didDismissDefaultBrowserCard] {
            promoCard = .defaultBrowser {
                ClientLogger.shared.logCounter(.PromoDefaultBrowser, attributes: EnvironmentHelper.shared.getAttributes())
                BrowserViewController.foregroundBVC().presentDBOnboardingViewController(true)

                // Set default browser onboarding did show to true so it will not show again after user clicks this button
                Defaults[.didShowDefaultBrowserOnboarding] = true
            } onClose: {
                ClientLogger.shared.logCounter(.CloseDefaultBrowserPromo, attributes: EnvironmentHelper.shared.getAttributes())
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

    #if DEV
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

    func reload(from profile: Profile) {
        guard let deferredHistory = profile.history.getFrecentHistory().getSites(matchingSearchQuery: searchUrlForQuery, limit: 20) as? CancellableDeferred else {
            assertionFailure("FrecentHistory query should be cancellable")
            return
        }

        deferredHistory.uponQueue(.main) { result in
            guard !deferredHistory.cancelled else {
                return
            }

            let deferredHistorySites = result.successValue?.asArray() ?? []
            self.suggestedQueries = deferredHistorySites.compactMap { site in
                if let query = neevaSearchEngine.queryForSearchURL(URL(string: site.url)) {
                    return (query, site)
                } else {
                    return nil
                }
            }
        }


    }
}
