// Copyright Neeva. All rights reserved.

import SwiftUI
import Combine

struct TabLocationViewWrapper: View {
    let historyModel: HistorySuggestionModel
    let neevaModel: NeevaSuggestionModel
    let model: URLBarModel
    let content: () -> TabLocationView

    var body: some View {
        content()
            .environmentObject(historyModel)
            .environmentObject(neevaModel)
            .environmentObject(model)
            .environmentObject(SearchQueryModel.shared)
    }
}
class TabLocationHost: IncognitoAwareHostingController<TabLocationViewWrapper> {
    private let model: URLBarModel
    private weak var delegate: LegacyTabLocationViewDelegate?
    weak var urlBarDelegate: LegacyURLBarDelegate? {
        didSet {
            subscriptions = []
            if urlBarDelegate != nil {
                model.$isEditing
                    .withPrevious()
                    .sink { [weak urlBarDelegate] change in
                        switch change {
                        case (false, true):
                            urlBarDelegate?.urlBarDidEnterOverlayMode()
                        case (true, false):
                            urlBarDelegate?.urlBarDidLeaveOverlayMode()
                        default: break
                        }
                    }
                    .store(in: &subscriptions)
                model.$isEditing
                    .combineLatest(SearchQueryModel.shared.$value)
                    .sink { [weak urlBarDelegate] isEditing, query in
                        if isEditing {
                            urlBarDelegate?.urlBar(didEnterText: query)
                        }
                    }
                    .store(in: &subscriptions)
            }
        }
    }

    private var subscriptions: Set<AnyCancellable> = []

    init(
        model: URLBarModel,
        historySuggestionModel: HistorySuggestionModel,
        neevaSuggestionModel: NeevaSuggestionModel,
        delegate: LegacyTabLocationViewDelegate,
        urlBarDelegate: LegacyURLBarDelegate?
    ) {
        self.model = model
        self.delegate = delegate
        self.urlBarDelegate = urlBarDelegate
        super.init()
        setRootView {
            TabLocationViewWrapper(historyModel: historySuggestionModel, neevaModel: neevaSuggestionModel, model: model) {
                TabLocationView(
                    onReload: { [weak self] in self?.delegate?.tabLocationViewDidTapReload() },
                    onSubmit: { [weak self] in self?.urlBarDelegate?.urlBar(didSubmitText: $0) },
                    onShare: { [weak self] in self?.delegate?.tabLocationViewDidTap(shareButton: $0) },
                    buildReloadMenu: { [weak self] in self?.delegate?.tabLocationViewReloadMenu() }
                )
            }
        }
        self.view.backgroundColor = .clear
    }

    @objc required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
