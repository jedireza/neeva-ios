// Copyright Neeva. All rights reserved.

import SwiftUI

class URLBarHost: IncognitoAwareHostingController<URLBarHost.Content>, CommonURLBar {
    let model = URLBarModel()
    let queryModel: SearchQueryModel
    let suggestionModel: SuggestionModel
    let gridModel: GridModel
    let trackingStatsViewModel: TrackingStatsViewModel

    struct Content: View {
        let suggestionModel: SuggestionModel
        let model: URLBarModel
        let queryModel: SearchQueryModel
        let gridModel: GridModel
        let trackingStatsViewModel: TrackingStatsViewModel
        let content: () -> URLBarView

        var body: some View {
            content()
                .environmentObject(suggestionModel)
                .environmentObject(model)
                .environmentObject(queryModel)
                .environmentObject(gridModel)
                .environmentObject(trackingStatsViewModel)
                .ignoresSafeArea()
        }
    }

    init(
        suggestionModel: SuggestionModel,
        queryModel: SearchQueryModel,
        gridModel: GridModel,
        trackingStatsViewModel: TrackingStatsViewModel,
        delegate: LegacyURLBarDelegate
    ) {
        self.queryModel = queryModel
        self.suggestionModel = suggestionModel
        self.gridModel = gridModel
        self.trackingStatsViewModel = trackingStatsViewModel
        super.init()
        setRootView { [model] in
            Content(
                suggestionModel: suggestionModel,
                model: model,
                queryModel: queryModel,
                gridModel: gridModel,
                trackingStatsViewModel: trackingStatsViewModel
            ) {
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

    override func applyUIMode(isPrivate: Bool) {
        super.applyUIMode(isPrivate: isPrivate)
    }
}
