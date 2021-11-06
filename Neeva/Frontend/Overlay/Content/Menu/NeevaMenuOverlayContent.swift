// Copyright Neeva. All rights reserved.

import SwiftUI

struct NeevaMenuOverlayContent: View {
    @Environment(\.hideOverlay) private var hideOverlay

    let menuAction: (NeevaMenuAction) -> Void
    let isIncognito: Bool

    var body: some View {
        NeevaMenuView(noTopPadding: true) { action in
            menuAction(action)
            hideOverlay()
        }
        .environment(\.isIncognito, isIncognito)
        .overlayIsFixedHeight(isFixedHeight: true)
        .padding(.top, 8)
    }
}
