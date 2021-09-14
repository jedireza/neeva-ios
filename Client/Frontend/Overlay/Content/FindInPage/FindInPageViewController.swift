// Copyright Neeva. All rights reserved.

import SwiftUI

struct FindInPageRootView: View {
    var model: FindInPageModel
    let onDismiss: () -> Void

    var body: some View {
        VStack {
            FindInPageView(onDismiss: onDismiss)
                .environmentObject(model)

            Spacer()
        }
    }
}

class FindInPageViewController: UIHostingController<FindInPageRootView> {
    var model: FindInPageModel

    init(model: FindInPageModel, onDismiss: @escaping () -> Void) {
        self.model = model

        super.init(
            rootView: FindInPageRootView(model: model, onDismiss: onDismiss))
        self.view.accessibilityViewIsModal = true
    }

    @objc required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        view.backgroundColor = .systemGroupedBackground
        view.layer.cornerRadius = 16
        view.layer.masksToBounds = true
    }
}
