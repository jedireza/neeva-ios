// Copyright Neeva. All rights reserved.

import SwiftUI
import UIKit

struct OpenInAppRootView: View {
    var overlaySheetModel = OverlaySheetModel()

    let url: URL
    let onOpen: () -> Void
    let onDismiss: () -> Void

    var body: some View {
        let config = OverlaySheetConfig(showTitle: false, backgroundColor: .systemGroupedBackground)
        OverlaySheetView(model: overlaySheetModel, config: config, onDismiss: onDismiss) {
            OpenInAppView(url: url, onOpen: onOpen, onDismiss: onDismiss)
                .overlaySheetIsFixedHeight(isFixedHeight: true)
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

class OpenInAppViewController: UIHostingController<OpenInAppRootView> {
    init(url: URL, onOpen: @escaping () -> Void, onDismiss: @escaping () -> Void) {
        super.init(rootView: OpenInAppRootView(url: url, onOpen: onOpen, onDismiss: onDismiss))
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
