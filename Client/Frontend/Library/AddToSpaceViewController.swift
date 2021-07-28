// Copyright Neeva. All rights reserved.

import Shared
import SwiftUI

struct AddToSpaceRootView: View {
    var overlaySheetModel = OverlaySheetModel()

    @StateObject var request: AddToSpaceRequest
    var onDismiss: () -> Void
    var onOpenURL: (URL) -> Void

    private var overlaySheetIsFixedHeight: Bool {
        switch request.mode {
        case .saveToNewSpace:
            return true
        case .saveToExistingSpace:
            return false
        }
    }

    var body: some View {
        let config = OverlaySheetConfig(showTitle: true)
        OverlaySheetView(
            model: self.overlaySheetModel, config: config, onDismiss: { self.onDismiss() }
        ) {
            AddToSpaceView(
                request: request,
                onDismiss: {
                    // The user made a selection. Store that and run the animation to hide the
                    // sheet. When that completes, we'll run the provided onDismiss callback.
                    self.overlaySheetModel.hide()
                }
            )
            .environment(\.onOpenURL, { self.onOpenURL($0) })
            .overlaySheetTitle(title: request.mode.title)
            .overlaySheetIsFixedHeight(isFixedHeight: self.overlaySheetIsFixedHeight)
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

class AddToSpaceViewController: UIHostingController<AddToSpaceRootView> {
    init(
        request: AddToSpaceRequest, onDismiss: @escaping () -> Void,
        onOpenURL: @escaping (URL) -> Void
    ) {
        super.init(
            rootView: AddToSpaceRootView(
                request: request, onDismiss: onDismiss, onOpenURL: onOpenURL))
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
