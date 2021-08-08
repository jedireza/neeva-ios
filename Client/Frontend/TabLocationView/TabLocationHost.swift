// Copyright Neeva. All rights reserved.

import Combine
import SwiftUI

protocol LegacyTabLocationViewDelegate: AnyObject {
    func tabLocationViewDidTapReload()
    func tabLocationViewDidTap(shareButton: UIView)
    func tabLocationViewReloadMenu() -> UIMenu?
}

struct TabLocationViewWrapper: View {
    let suggestionModel: SuggestionModel
    let model: URLBarModel
    let queryModel: SearchQueryModel
    let gridModel: GridModel
    let trackingStatsModel: TrackingStatsViewModel

    let content: () -> TabLocationView

    var body: some View {
        content()
            .environmentObject(suggestionModel)
            .environmentObject(model)
            .environmentObject(queryModel)
            .environmentObject(gridModel)
            .environmentObject(trackingStatsModel)
            .ignoresSafeArea()
    }
}

class TabLocationHost: IncognitoAwareHostingController<TabLocationViewWrapper> {
    private let model: URLBarModel
    private weak var delegate: LegacyTabLocationViewDelegate?

    private var subscriptions: Set<AnyCancellable> = []

    init(
        model: URLBarModel,
        suggestionModel: SuggestionModel,
        queryModel: SearchQueryModel,
        gridModel: GridModel,
        trackingStatsModel: TrackingStatsViewModel,
        delegate: LegacyTabLocationViewDelegate,
        urlBar: LegacyURLBarView?
    ) {
        self.model = model
        self.delegate = delegate
        super.init()
        setRootView {
            TabLocationViewWrapper(suggestionModel: suggestionModel,
                model: model, queryModel: queryModel, gridModel: gridModel,
                trackingStatsModel: trackingStatsModel
            ) {
                TabLocationView(
                    onReload: { [weak delegate] in delegate?.tabLocationViewDidTapReload() },
                    onSubmit: { [weak urlBar] in urlBar?.delegate?.urlBar(didSubmitText: $0) },
                    onShare: { [weak delegate] in delegate?.tabLocationViewDidTap(shareButton: $0)
                    },
                    buildReloadMenu: { [weak delegate] in delegate?.tabLocationViewReloadMenu() }
                )
            }
        }
        self.view.backgroundColor = .clear

        model.$isEditing
            .withPrevious()
            .sink { [weak urlBar] change in
                switch change {
                case (false, true):
                    urlBar?.enterOverlayMode()
                case (true, false):
                    urlBar?.leaveOverlayMode()
                default: break
                }
            }
            .store(in: &subscriptions)
        model.$isEditing
            .combineLatest(queryModel.$value)
            .withPrevious()
            .sink { [weak urlBar] (prev, current) in
                let (prevEditing, _) = prev
                let (isEditing, query) = current
                if (prevEditing, isEditing) == (true, true) {
                    urlBar?.delegate?.urlBar(didEnterText: query)
                }
            }
            .store(in: &subscriptions)
    }

    @objc required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
