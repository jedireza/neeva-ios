// Copyright Neeva. All rights reserved.

import Shared
import SwiftUI

struct OverflowMenuRootView: View {
    @StateObject var overlaySheetModel = OverlaySheetModel()
    let onDismiss: () -> Void
    let menuAction: (OverflowMenuAction) -> Void
    let changedUserAgent: Bool?
    let chromeModel: TabChromeModel
    let locationModel: LocationViewModel

    var body: some View {
        let config = OverlaySheetConfig(showTitle: false, backgroundColor: .systemGroupedBackground)
        OverlaySheetView(model: overlaySheetModel, config: config, onDismiss: onDismiss) {
            OverflowMenuView(changedUserAgent: changedUserAgent ?? false) { action in
                onDismiss()
                menuAction(action)
                overlaySheetModel.hide()
            }
            .environmentObject(chromeModel)
            .environmentObject(locationModel)
            .overlaySheetIsFixedHeight(isFixedHeight: true)
            .padding(.top, -8)
        }
        .onAppear {
            DispatchQueue.main.async {
                self.overlaySheetModel.show()
            }
        }
    }
}

class OverflowMenuViewController: UIHostingController<OverflowMenuRootView> {

    public init(
        onDismiss: @escaping () -> Void,
        chromeModel: TabChromeModel,
        locationModel: LocationViewModel,
        changedUserAgent: Bool?,
        menuAction: @escaping (OverflowMenuAction) -> Void
    ) {
        super.init(
            rootView: OverflowMenuRootView(
                onDismiss: onDismiss,
                menuAction: menuAction,
                changedUserAgent: changedUserAgent,
                chromeModel: chromeModel,
                locationModel: locationModel))
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
