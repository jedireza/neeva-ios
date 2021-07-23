// Copyright Neeva. All rights reserved.

import SwiftUI

class URLBarHost: IncognitoAwareHostingController<URLBarHost.Content>, CommonURLBar {
    let model = URLBarModel()
    let queryModel: SearchQueryModel
    let historySuggestionModel: HistorySuggestionModel
    let neevaSuggestionModel: NeevaSuggestionModel
    let gridModel: GridModel
    let trackingStatsViewModel: TrackingStatsViewModel

    struct Content: View {
        let historyModel: HistorySuggestionModel
        let neevaModel: NeevaSuggestionModel
        let model: URLBarModel
        let queryModel: SearchQueryModel
        let gridModel: GridModel
        let trackingStatsViewModel: TrackingStatsViewModel
        let content: () -> URLBarView

        var body: some View {
            content()
                .environmentObject(historyModel)
                .environmentObject(neevaModel)
                .environmentObject(model)
                .environmentObject(queryModel)
                .environmentObject(gridModel)
                .environmentObject(trackingStatsViewModel)
                .ignoresSafeArea()
        }
    }

    init(
        historySuggestionModel: HistorySuggestionModel,
        neevaSuggestionModel: NeevaSuggestionModel,
        queryModel: SearchQueryModel,
        gridModel: GridModel,
        trackingStatsViewModel: TrackingStatsViewModel,
        delegate: LegacyURLBarDelegate
    ) {
        self.queryModel = queryModel
        self.historySuggestionModel = historySuggestionModel
        self.neevaSuggestionModel = neevaSuggestionModel
        self.gridModel = gridModel
        self.trackingStatsViewModel = trackingStatsViewModel
        super.init()
        setRootView { [model] in
            Content(historyModel: historySuggestionModel, neevaModel: neevaSuggestionModel, model: model, queryModel: queryModel, gridModel: gridModel, trackingStatsViewModel: trackingStatsViewModel) {
                URLBarView(
                    onReload: { [weak delegate] in
                        switch model.reloadButton {
                        case .reload:
                            delegate?.urlBarDidPressReload()
                        case .stop:
                            delegate?.urlBarDidPressStop()
                        }
                    },
                    onSubmit: { [weak delegate] in delegate?.urlBar(didSubmitText: $0) },
                    onShare: { _ in fatalError("TODO: implement sharing") },
                    buildReloadMenu: { [weak delegate] in delegate?.urlBarReloadMenu() },
                    showsToolbar: false
                )
            }
        }
        self.view.backgroundColor = .clear
    }

    @objc required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
