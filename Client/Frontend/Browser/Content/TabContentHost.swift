// Copyright Neeva. All rights reserved.

import Combine
import SwiftUI

class TabContentHost: UIHostingController<TabContentHost.Content> {
    let zeroQueryModel: ZeroQueryModel
    var subscription: AnyCancellable? = nil

    struct Content: View {
        let webView: WKWebView?
        @ObservedObject var zeroQueryModel: ZeroQueryModel
        let suggestedSitesViewModel: SuggestedSitesViewModel = SuggestedSitesViewModel(sites: [])
        let suggestedSearchesModel: SuggestedSearchesModel =
            SuggestedSearchesModel(suggestedQueries: [])

        var body: some View {
            ZStack {
                if let webView = webView, zeroQueryModel.isHidden {
                    WebViewContainer(webView: webView)
                        .ignoresSafeArea()
                } else {
                    ZeroQueryContent(model: zeroQueryModel)
                        .environmentObject(suggestedSitesViewModel)
                        .environmentObject(suggestedSearchesModel)
                }
            }.onAppear {
                TopSitesHandler.getTopSites(
                    profile: zeroQueryModel.profile).uponQueue(.main) { result in
                    self.suggestedSitesViewModel.sites = Array(result.prefix(8))
                }
                self.suggestedSearchesModel.reload(from: zeroQueryModel.profile)
            }
        }
    }

    init(tabManager: TabManager, zeroQueryModel: ZeroQueryModel) {
        self.zeroQueryModel = zeroQueryModel
        super.init(
            rootView: Content(
                webView: tabManager.selectedTab?.webView,
                zeroQueryModel: zeroQueryModel
            ))
        self.subscription = tabManager.selectedTabPublisher.sink { [unowned self] tab in
            self.rootView = Content(
                webView: tab?.webView,
                zeroQueryModel: zeroQueryModel)
        }
    }

    @objc required dynamic init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
