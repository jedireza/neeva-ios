// Copyright Neeva. All rights reserved.

import SwiftUI
import Combine

struct TabLocationViewWrapper: View {
    let historyModel: HistorySuggestionModel
    let neevaModel: NeevaSuggestionModel
    let content: () -> TabLocationView

    var body: some View {
        content()
            .environmentObject(historyModel)
            .environmentObject(neevaModel)
    }
}
class TabLocationHost: IncognitoAwareHostingController<TabLocationViewWrapper> {
    private let model: URLBarModel
    private weak var delegate: LegacyTabLocationViewDelegate?
    weak var urlBarDelegate: LegacyURLBarDelegate? {
        didSet {
            subscriptions = []
            if urlBarDelegate != nil {
                SearchQueryModel.shared.$value.withPrevious()
                    .sink { [weak urlBarDelegate] oldValue, newValue in
                        if oldValue == nil, newValue != nil {
                            urlBarDelegate?.urlBarDidEnterOverlayMode()
                        } else if oldValue != nil, newValue == nil {
                            urlBarDelegate?.urlBarDidLeaveOverlayMode()
                        }

                        if let newValue = newValue {
                            urlBarDelegate?.urlBar(didEnterText: newValue)
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
            TabLocationViewWrapper(historyModel: historySuggestionModel, neevaModel: neevaSuggestionModel) {
                TabLocationView(
                    model: model,
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
