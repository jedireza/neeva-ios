// Copyright Neeva. All rights reserved.

import SwiftUI

enum OverflowMenuLocation {
    case tab
    case cardGrid
}

struct OverflowMenuOverlayContent: View {
    @Environment(\.hideOverlay) private var hideOverlay

    let menuAction: (OverflowMenuAction) -> Void
    let changedUserAgent: Bool?
    let chromeModel: TabChromeModel
    let locationModel: LocationViewModel
    let location: OverflowMenuLocation

    @ViewBuilder
    var content: some View {
        if location == .tab {
            OverflowMenuView(changedUserAgent: changedUserAgent ?? false) { action in
                hideOverlay()
                menuAction(action)
            }
        } else {
            CardGridOverflowMenuView(changedUserAgent: changedUserAgent ?? false) { action in
                hideOverlay()
                menuAction(action)
            }
        }
    }

    var body: some View {
        content
            .environmentObject(chromeModel)
            .environmentObject(locationModel)
            .overlayIsFixedHeight(isFixedHeight: true)
            .padding(.top, -8)
    }
}
