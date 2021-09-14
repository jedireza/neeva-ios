// Copyright Neeva. All rights reserved.

import SwiftUI

struct OverflowMenuOverlayContent: View {
    @Environment(\.hideOverlay) private var hideOverlay

    let menuAction: (OverflowMenuAction) -> Void
    let changedUserAgent: Bool?
    let chromeModel: TabChromeModel
    let locationModel: LocationViewModel

    var body: some View {
        OverflowMenuView(changedUserAgent: changedUserAgent ?? false) { action in
            hideOverlay()
            menuAction(action)
        }
        .environmentObject(chromeModel)
        .environmentObject(locationModel)
        .overlayIsFixedHeight(isFixedHeight: true)
        .padding(.top, -8)
    }
}
