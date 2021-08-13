// Copyright Neeva. All rights reserved.

import Shared
import SwiftUI

struct CheatsheetRootView: View {
    @StateObject var overlaySheetModel = OverlaySheetModel()

    let onDismiss: () -> Void
    var embeddedView: CheatsheetMenuView

    var body: some View {
        let config = OverlaySheetConfig(showTitle: false, backgroundColor: .systemGroupedBackground)
        OverlaySheetView(model: overlaySheetModel, config: config, onDismiss: onDismiss) {
            self.embeddedView
                .overlaySheetIsFixedHeight(isFixedHeight: false)
        }
        .onAppear {
            DispatchQueue.main.async {
                self.overlaySheetModel.show()
            }
        }
    }
}

class CheatsheetViewController: UIHostingController<CheatsheetRootView> {
    public init(onDismiss: @escaping () -> Void) {
        super.init(
            rootView: CheatsheetRootView(
                onDismiss: onDismiss,
                embeddedView: CheatsheetMenuView()
            )
        )
    }

    @objc required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        view.backgroundColor = .clear
    }
}
