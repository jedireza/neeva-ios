// Copyright Neeva. All rights reserved.

import SwiftUI

class TabLocationHost: UIHostingController<TabLocationHost.Content>, PrivateModeUI {
    private let model: URLBarModel
    private weak var delegate: LegacyTabLocationViewDelegate?
    weak var urlBarDelegate: LegacyURLBarDelegate?

    init(model: URLBarModel, delegate: LegacyTabLocationViewDelegate, urlBarDelegate: LegacyURLBarDelegate?) {
        self.model = model
        self.delegate = delegate
        self.urlBarDelegate = urlBarDelegate
        super.init(rootView: Content(isIncognito: false, model: model, onReload: { }, onSubmit: { _ in }))
        self.applyUIMode(isPrivate: false)
    }

    func applyUIMode(isPrivate: Bool) {
        self.rootView = Content(
            isIncognito: isPrivate,
            model: model,
            onReload: { [weak self] in self?.delegate?.tabLocationViewDidTapReload() },
            onSubmit: { [weak self] in self?.urlBarDelegate?.urlBar(didSubmitText: $0) }
        )
    }

    struct Content: View {
        let isIncognito: Bool
        let model: URLBarModel
        let onReload: () -> ()
        let onSubmit: (String) -> ()

        var body: some View {
            TabLocationView(model: model, onReload: onReload, onSubmit: onSubmit)
                .environment(\.isIncognito, isIncognito)
        }
    }

    @objc required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
