// Copyright Neeva. All rights reserved.

import SwiftUI

struct NeevaMenuOverlaySheetContent: View {
    @Environment(\.hideOverlaySheet) private var hideOverlaySheet

    let menuAction: (NeevaMenuAction) -> Void
    let isIncognito: Bool

    var body: some View {
        NeevaMenuView(noTopPadding: true) { action in
            menuAction(action)
            hideOverlaySheet()
        }
        .environment(\.isIncognito, isIncognito)
        .overlaySheetIsFixedHeight(isFixedHeight: true)
        .padding(.top, 8)
    }
}
