// Copyright Neeva. All rights reserved.

import Shared
import SwiftUI

struct OpenInAppOverlayContent: View {
    @Environment(\.hideOverlay) private var hideOverlay

    let url: URL

    var body: some View {
        OpenInAppOverlayView(
            url: url,
            onOpen: {
                hideOverlay()
                UIApplication.shared.open(url, options: [:])
            },
            onCancel: hideOverlay
        )
        .overlayIsFixedHeight(isFixedHeight: true)
    }
}
