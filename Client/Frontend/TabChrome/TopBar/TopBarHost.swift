// Copyright Neeva. All rights reserved.

import Combine
import SwiftUI

// For sharing to work, this must currently be the BrowserViewController
protocol TopBarDelegate: ToolbarDelegate {
    func urlBarReloadMenu() -> UIMenu?
    func urlBarDidPressStop()
    func urlBarDidPressReload()
    func urlBarDidEnterOverlayMode()
    func urlBarDidLeaveOverlayMode()
    func urlBar(didSubmitText text: String)

    func perform(neevaMenuAction: NeevaMenuAction)
    func updateFeedbackImage()

    var tabContentHost: TabContentHost { get }
    var tabManager: TabManager { get }
}

class TopBarHost: IncognitoAwareHostingController<TopBarHost.Content> {
    let locationModel = LocationViewModel()
    let queryModel: SearchQueryModel
    let suggestionModel: SuggestionModel

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
        delegate: TopBarDelegate
    ) {
        self.queryModel = queryModel
        self.suggestionModel = suggestionModel
        super.init()
        let performTabToolbarAction = delegate.performTabToolbarAction
        setRootView { [locationModel, weak delegate] in
            Content(
                suggestionModel: suggestionModel, model: locationModel, queryModel: queryModel,
                gridModel: gridModel, trackingStatsViewModel: trackingStatsViewModel,
                chromeModel: chromeModel
            ) {
                TopBarView(
                    performTabToolbarAction: performTabToolbarAction,
                    buildTabsMenu: { delegate?.tabToolbarTabsMenu() },
                    onReload: {
                        switch chromeModel.reloadButton {
                        case .reload:
                            delegate?.urlBarDidPressReload()
                        case .stop:
                            delegate?.urlBarDidPressStop()
                        }
                    },
                    onSubmit: { delegate?.urlBar(didSubmitText: $0) },
                    onShare: { shareView in
                        // also update in LegacyTabToolbarHelper
                        ClientLogger.shared.logCounter(
                            .ClickShareButton, attributes: EnvironmentHelper.shared.getAttributes())
                        guard
                            let bvc = delegate as? BrowserViewController,
                            let tab = bvc.tabManager.selectedTab,
                            let url = tab.url
                        else { return }
                        if url.isFileURL {
                            bvc.share(fileURL: url, buttonView: shareView, presentableVC: bvc)
                        } else {
                            bvc.share(tab: tab, from: shareView, presentableVC: bvc)
                        }
                    },
                    buildReloadMenu: { delegate?.urlBarReloadMenu() },
                    onNeevaMenuAction: { delegate?.perform(neevaMenuAction: $0) },
                    didTapNeevaMenu: { delegate?.updateFeedbackImage() },
                    onOverflowMenuAction: { delegate?.perform(overflowMenuAction: $0, targetButtonView: $1) },
                    changedUserAgent: delegate?.tabManager.selectedTab?.changedUserAgent
                )
            }
        }
        self.view.backgroundColor = .clear
        self.view.translatesAutoresizingMaskIntoConstraints = false
        self.view.setContentHuggingPriority(.required, for: .vertical)

        chromeModel.$isEditingLocation
            .withPrevious()
            .sink { [weak delegate] change in
                switch change {
                case (false, true):
                    delegate?.urlBarDidEnterOverlayMode()
                case (true, false):
                    delegate?.urlBarDidLeaveOverlayMode()
                default: break
                }
            }
            .store(in: &subscriptions)
        chromeModel.$isEditingLocation
            .combineLatest(queryModel.$value)
            .withPrevious()
            .sink { [weak delegate] (prev, current) in
                let (prevEditing, _) = prev
                let (isEditing, query) = current
                if let delegate = delegate, (prevEditing, isEditing) == (true, true) {
                    if query.isEmpty {
                        delegate.tabContentHost.updateContent(.hideSuggestions)
                    } else {
                        delegate.tabContentHost.updateContent(.showSuggestions)
                    }
                }
            }
            .store(in: &subscriptions)
    }

    private var subscriptions: Set<AnyCancellable> = []

    @objc required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
