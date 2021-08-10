// Copyright Neeva. All rights reserved.

import SwiftUI

class TopBarHost: IncognitoAwareHostingController<TopBarHost.Content>, CommonURLBar {
    let locationModel = LocationViewModel()
    let queryModel: SearchQueryModel
    let suggestionModel: SuggestionModel
    let gridModel: GridModel
    let trackingStatsViewModel: TrackingStatsViewModel

    struct Content: View {
        let suggestionModel: SuggestionModel
        let model: LocationViewModel
        let queryModel: SearchQueryModel
        let gridModel: GridModel
        let trackingStatsViewModel: TrackingStatsViewModel
        let chromeModel: TabChromeModel
        let content: () -> TopBarView

        var body: some View {
            content()
                .environmentObject(suggestionModel)
                .environmentObject(model)
                .environmentObject(queryModel)
                .environmentObject(gridModel)
                .environmentObject(trackingStatsViewModel)
                .environmentObject(chromeModel)
        }
    }

    init(
        suggestionModel: SuggestionModel,
        queryModel: SearchQueryModel,
        gridModel: GridModel,
        trackingStatsViewModel: TrackingStatsViewModel,
        chromeModel: TabChromeModel,
        bvc: BrowserViewController
    ) {
        self.queryModel = queryModel
        self.suggestionModel = suggestionModel
        self.gridModel = gridModel
        self.trackingStatsViewModel = trackingStatsViewModel
        super.init()
        let performTabToolbarAction = bvc.performTabToolbarAction
        setRootView { [locationModel, weak bvc] in
            Content(
                suggestionModel: suggestionModel, model: locationModel, queryModel: queryModel,
                gridModel: gridModel, trackingStatsViewModel: trackingStatsViewModel,
                chromeModel: chromeModel
            ) {
                TopBarView(
                    performTabToolbarAction: performTabToolbarAction,
                    buildTabsMenu: { bvc?.tabToolbarTabsMenu() },
                    onReload: {
                        switch chromeModel.reloadButton {
                        case .reload:
                            bvc?.urlBarDidPressReload()
                        case .stop:
                            bvc?.urlBarDidPressStop()
                        }
                    },
                    onSubmit: { bvc?.urlBar(didSubmitText: $0) },
                    onShare: { shareView in
                        // also update in LegacyTabToolbarHelper
                        ClientLogger.shared.logCounter(
                            .ClickShareButton, attributes: EnvironmentHelper.shared.getAttributes())
                        guard
                            let bvc = bvc,
                            let tab = bvc.tabManager.selectedTab,
                            let url = tab.url
                        else { return }
                        if url.isFileURL {
                            bvc.share(fileURL: url, buttonView: shareView, presentableVC: bvc)
                        } else {
                            bvc.share(tab: tab, from: shareView, presentableVC: bvc)
                        }
                    },
                    buildReloadMenu: { bvc?.urlBarReloadMenu() }
                )
            }
        }
        self.view.backgroundColor = .clear
        self.view.translatesAutoresizingMaskIntoConstraints = false
        self.view.setContentHuggingPriority(.required, for: .vertical)
    }

    @objc required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func applyUIMode(isPrivate: Bool) {
        super.applyUIMode(isPrivate: isPrivate)
    }
}
