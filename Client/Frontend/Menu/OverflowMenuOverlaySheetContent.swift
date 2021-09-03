// Copyright Neeva. All rights reserved.

import SwiftUI

struct OverflowMenuOverlaySheetContent: View {
    @Environment(\.hideOverlaySheet) private var hideOverlaySheet

    let menuAction: (OverflowMenuAction) -> Void
    let changedUserAgent: Bool?
    let chromeModel: TabChromeModel
    let locationModel: LocationViewModel

    var body: some View {
        OverflowMenuView(changedUserAgent: changedUserAgent ?? false) { action in
            hideOverlaySheet()
            menuAction(action)
        }
        .environmentObject(chromeModel)
        .environmentObject(locationModel)
        .overlaySheetIsFixedHeight(isFixedHeight: true)
        .padding(.top, -8)
    }
}
