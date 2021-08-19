// Copyright Neeva. All rights reserved.

import Shared
import SwiftUI

struct CheatsheetRootView: View {
    @StateObject var overlaySheetModel = OverlaySheetModel()

    let onDismiss: () -> Void
    let menuAction: (NeevaMenuAction) -> Void
    let model: CheatsheetMenuViewModel
    let openInNewTab: (URL, Bool) -> Void

    var body: some View {
        let config = OverlaySheetConfig(showTitle: false, backgroundColor: .systemGroupedBackground)
        OverlaySheetView(model: overlaySheetModel, config: config, onDismiss: onDismiss) {
            CheatsheetMenuView { action in
                menuAction(action)
                overlaySheetModel.hide()
            }
            .overlaySheetIsFixedHeight(isFixedHeight: false)
            .environmentObject(model)
            .environment(\.openInNewTab, openInNewTab)
        }
        .onAppear {
            DispatchQueue.main.async {
                self.overlaySheetModel.show()
            }
        }
    }
}

class CheatsheetViewController: IncognitoAwareHostingController<CheatsheetRootView> {
    public init(
        menuAction: @escaping (NeevaMenuAction) -> Void,
        onDismiss: @escaping () -> Void,
        openInNewTab: @escaping (URL, Bool) -> Void,
        tabManager: TabManager,
        isPrivate: Bool
    ) {
        let model = CheatsheetMenuViewModel(tabManager: tabManager)

        super.init(isIncognito: isPrivate)

        setRootView {
            CheatsheetRootView(
                onDismiss: onDismiss,
                menuAction: menuAction,
                model: model,
                openInNewTab: openInNewTab)
        }
    }

    @objc required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        view.backgroundColor = .clear
    }
}
