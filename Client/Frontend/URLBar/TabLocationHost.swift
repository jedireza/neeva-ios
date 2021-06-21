// Copyright Neeva. All rights reserved.

import SwiftUI
import Combine

class TabLocationHost: UIHostingController<TabLocationHost.Content>, PrivateModeUI {
    private let model: URLBarModel
    private weak var delegate: LegacyTabLocationViewDelegate?
    weak var urlBarDelegate: LegacyURLBarDelegate? {
        didSet {
            subscriptions = []
            if urlBarDelegate != nil {
                model.$text.zip(model.$text.dropFirst())
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

    init(model: URLBarModel, delegate: LegacyTabLocationViewDelegate, urlBarDelegate: LegacyURLBarDelegate?) {
        self.model = model
        self.delegate = delegate
        self.urlBarDelegate = urlBarDelegate
        super.init(rootView: Content(isIncognito: false, model: model, onReload: { }, onSubmit: { _ in }, onShare: { _ in }))
        self.view.backgroundColor = .clear
        self.applyUIMode(isPrivate: false)
    }

    func applyUIMode(isPrivate: Bool) {
        self.rootView = Content(
            isIncognito: isPrivate,
            model: model,
            onReload: { [weak self] in self?.delegate?.tabLocationViewDidTapReload() },
            onSubmit: { [weak self] in self?.urlBarDelegate?.urlBar(didSubmitText: $0) },
            onShare: { [weak self] in self?.delegate?.tabLocationViewDidTap(shareButton: $0) }
        )
    }

    struct Content: View {
        let isIncognito: Bool
        let model: URLBarModel
        let onReload: () -> ()
        let onSubmit: (String) -> ()
        let onShare: (UIView) -> ()

        var body: some View {
            TabLocationView(model: model, onReload: onReload, onSubmit: onSubmit, onShare: onShare)
                .environment(\.isIncognito, isIncognito)
        }
    }

    @objc required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
