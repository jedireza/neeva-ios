// Copyright Neeva. All rights reserved.

import SwiftUI
import Combine

struct TabLocationViewWrapper: View {
    let historyModel: HistorySuggestionModel
    let neevaModel: NeevaSuggestionModel
    let model: URLBarModel
    let gridModel: GridModel

    let content: () -> TabLocationView

    var body: some View {
        content()
            .environmentObject(historyModel)
            .environmentObject(neevaModel)
            .environmentObject(model)
            .environmentObject(SearchQueryModel.shared)
            .environmentObject(gridModel)
            .ignoresSafeArea()
    }
}

class TabLocationHost: IncognitoAwareHostingController<TabLocationViewWrapper> {
    private let model: URLBarModel
    private weak var delegate: LegacyTabLocationViewDelegate?

    private var subscriptions: Set<AnyCancellable> = []

    init(
        model: URLBarModel,
        historySuggestionModel: HistorySuggestionModel,
        neevaSuggestionModel: NeevaSuggestionModel,
        gridModel: GridModel,
        delegate: LegacyTabLocationViewDelegate,
        urlBar: LegacyURLBarView?
    ) {
        self.model = model
        self.delegate = delegate
        super.init()
        setRootView {
            TabLocationViewWrapper(historyModel: historySuggestionModel, neevaModel: neevaSuggestionModel, model: model, gridModel: gridModel) {
                TabLocationView(
                    onReload: { [weak delegate] in delegate?.tabLocationViewDidTapReload() },
                    onSubmit: { [weak urlBar] in urlBar?.delegate?.urlBar(didSubmitText: $0) },
                    onShare: { [weak delegate] in delegate?.tabLocationViewDidTap(shareButton: $0) },
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
                    urlBar?.enterOverlayMode(nil, pasted: false, search: false, updateModel: false)
                case (true, false):
                    urlBar?.leaveOverlayMode()
                default: break
                }
            }
            .store(in: &subscriptions)
        model.$isEditing
            .withPrevious()
            .combineLatest(SearchQueryModel.shared.$value)
            .sink { [weak urlBar] isEditing, query in
                if isEditing == (true, true) {
                    urlBar?.delegate?.urlBar(didEnterText: query)
                }
            }
            .store(in: &subscriptions)
    }

    @objc required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
