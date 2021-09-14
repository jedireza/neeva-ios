// Copyright Neeva. All rights reserved.

import SwiftUI

struct CheatsheetOverlayContent: View {
    @Environment(\.hideOverlay) private var hideOverlay
    private let menuAction: (NeevaMenuAction) -> Void
    private let model: CheatsheetMenuViewModel
    private let isIncognito: Bool

    init(menuAction: @escaping (NeevaMenuAction) -> Void, tabManager: TabManager) {
        self.menuAction = menuAction
        self.model = CheatsheetMenuViewModel(tabManager: tabManager)
        self.isIncognito = tabManager.isIncognito
    }

    var body: some View {
        CheatsheetMenuView { action in
            menuAction(action)
            hideOverlay()
        }
        .overlayIsFixedHeight(isFixedHeight: false)
        .environmentObject(model)
        .environment(\.isIncognito, isIncognito)
    }
}
