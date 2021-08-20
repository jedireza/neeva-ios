// Copyright Neeva. All rights reserved.

import SwiftUI

struct HTTPAuthPromptRootView: View {
    let overlaySheetModel = OverlaySheetModel()

    let url: String
    let onSubmit: (String, String) -> Void
    let onDismiss: () -> Void

    var body: some View {
        let config = OverlaySheetConfig(showTitle: false, backgroundColor: .systemGroupedBackground)
        OverlaySheetView(model: overlaySheetModel, config: config, onDismiss: onDismiss) {
            HTTPAuthPromptOverlayView(url: url, onSubmit: onSubmit, onDismiss: onDismiss)
                .overlaySheetIsFixedHeight(isFixedHeight: true)
                .accessibility(label: Text("HTTP Sign In"))
        }
        .onAppear {
            // It seems to be necessary to delay starting the animation until this point to
            // avoid a visual artifact.
            DispatchQueue.main.async {
                self.overlaySheetModel.show()
            }
        }
    }
}

class HTTPAuthPromptViewController: UIHostingController<HTTPAuthPromptRootView> {
    init(url: String, onSubmit: @escaping (String, String) -> Void, onDismiss: @escaping () -> Void) {
        super.init(
            rootView: HTTPAuthPromptRootView(url: url, onSubmit: onSubmit, onDismiss: onDismiss))
        self.view.accessibilityViewIsModal = true
    }

    @objc required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        view.backgroundColor = .clear
    }
}
