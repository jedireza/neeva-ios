// Copyright Neeva. All rights reserved.

import Combine
import Defaults
import SDWebImage
import Shared
import SnapKit
import Storage
import SwiftUI
import UIKit
import XCGLogger

extension EnvironmentValues {
    private struct HideTopSiteKey: EnvironmentKey {
        static var defaultValue: ((Site) -> Void)? = nil
    }

    public var zeroQueryHideTopSite: (Site) -> Void {
        get {
            self[HideTopSiteKey] ?? { _ in
                fatalError(".environment(\\.zeroQueryHideTopSite) must be specified")
            }
        }
        set { self[HideTopSiteKey] = newValue }
    }
}

struct ZeroQueryContent: View {
    @ObservedObject var model: ZeroQueryModel
    @EnvironmentObject var suggestedSitesViewModel: SuggestedSitesViewModel
    @EnvironmentObject var suggestedSearchesModel: SuggestedSearchesModel

    var numSuggestedSites: Int {
        return FeatureFlag[.homeAsSuggestedSite] ? 7 : 8
    }

    var body: some View {
        ZeroQueryView()
            .background(Color(UIColor.HomePanel.topSitesBackground))
            .environmentObject(model)
            .environment(\.setSearchInput) { query in
                model.delegate?.zeroQueryPanel(didEnterQuery: query)
            }
            .environment(\.onOpenURL) { url in
                model.delegate?.zeroQueryPanel(didSelectURL: url, visitType: .bookmark)
            }
            .environment(\.shareURL, model.shareURLHandler)
            .environment(\.zeroQueryHideTopSite, model.hideURLFromTopSites)
            .environment(\.openInNewTab) { url, isPrivate in
                model.delegate?.zeroQueryPanelDidRequestToOpenInNewTab(
                    url, isPrivate: isPrivate)
            }
            .environment(\.saveToSpace) { url, title, description in
                model.delegate?.zeroQueryPanelDidRequestToSaveToSpace(
                    url,
                    title: title,
                    description: description)
            }
            .onAppear {
                self.model.updateState()
                TopSitesHandler.getTopSites(profile: model.profile).uponQueue(.main) { result in
                    self.suggestedSitesViewModel.sites =
                        Array(result.prefix(self.numSuggestedSites))
                }
                self.suggestedSearchesModel.reload(from: self.model.profile)
            }
    }
}
