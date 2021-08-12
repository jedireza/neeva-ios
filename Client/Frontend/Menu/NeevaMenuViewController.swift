// Copyright Neeva. All rights reserved.

import Shared
import SwiftUI

struct NeevaMenuRootView: View {
    @StateObject var overlaySheetModel = OverlaySheetModel()
    let onDismiss: () -> Void
    let menuAction: (NeevaMenuAction) -> Void
    let isIncognito: Bool

    var body: some View {
        let config = OverlaySheetConfig(showTitle: false, backgroundColor: .systemGroupedBackground)
        OverlaySheetView(model: overlaySheetModel, config: config, onDismiss: onDismiss) {
            NeevaMenuView(noTopPadding: true) { action in
                menuAction(action)
                overlaySheetModel.hide()
            }
            .environment(\.isIncognito, isIncognito)
            .overlaySheetIsFixedHeight(isFixedHeight: true)
            .padding(.top, 8)
        }
        .onAppear {
            DispatchQueue.main.async {
                self.overlaySheetModel.show()
            }
        }
    }
}

class NeevaMenuViewController: UIHostingController<NeevaMenuRootView> {
    public init(
        menuAction: @escaping (NeevaMenuAction) -> Void, onDismiss: @escaping () -> Void,
        isPrivate: Bool
    ) {
        super.init(
            rootView: NeevaMenuRootView(
                onDismiss: onDismiss, menuAction: menuAction, isIncognito: isPrivate))
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
