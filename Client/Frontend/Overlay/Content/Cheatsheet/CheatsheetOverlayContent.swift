// Copyright Neeva. All rights reserved.

import SwiftUI

struct CheatsheetOverlayContent: View {
    @Environment(\.hideOverlay) private var hideOverlay
    private let menuAction: (NeevaMenuAction) -> Void
    private let model: CheatsheetMenuViewModel
    private let isIncognito: Bool
    private let tabManager: TabManager

    init(menuAction: @escaping (NeevaMenuAction) -> Void, tabManager: TabManager) {
        self.menuAction = menuAction
        self.model = CheatsheetMenuViewModel(tabManager: tabManager)
        self.isIncognito = tabManager.isIncognito
        self.tabManager = tabManager
    }

    var body: some View {
        CheatsheetMenuView { action in
            menuAction(action)
            hideOverlay()
        }
        .background(Color.DefaultBackground)
        .overlayIsFixedHeight(isFixedHeight: false)
        .environmentObject(model)
        .environment(\.isIncognito, isIncognito)
        .environment(\.onOpenURL) { url in
            hideOverlay()
            self.tabManager.createOrSwitchToTab(for: url)
        }
    }
}
