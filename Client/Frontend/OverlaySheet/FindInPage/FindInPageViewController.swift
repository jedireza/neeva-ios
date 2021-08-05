// Copyright Neeva. All rights reserved.

import SwiftUI

struct FindInPageRootView: View {
    var overlaySheetModel = OverlaySheetModel()

    var model: FindInPageModel
    let onDismiss: () -> Void

    var body: some View {
        let config = OverlaySheetConfig(showTitle: false, backgroundColor: .systemGroupedBackground)
        OverlaySheetView(model: overlaySheetModel, config: config, onDismiss: onDismiss) {
            FindInPageView(onDismiss: onDismiss)
                .environmentObject(model)
                .overlaySheetIsFixedHeight(isFixedHeight: true)
        }
        .onAppear {
            // It seems to be necessary to delay starting the animation until this point to
            // avoid a visual artifact.
            DispatchQueue.main.async {
                self.overlaySheetModel.show(clearBackground: true)
            }
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
        // By default, a UIHostingController opens as an opaque layer, so we override
        // that behavior here.
        view.backgroundColor = .clear
    }
}
