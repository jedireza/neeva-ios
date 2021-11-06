// Copyright Neeva. All rights reserved.

import Shared
import SwiftUI

struct HTTPAuthPromptOverlayContent: View {
    @Environment(\.hideOverlay) private var hideOverlay

    let url: String
    let onSubmit: (String, String) -> Void

    var body: some View {
        HTTPAuthPromptOverlayView(
            url: url, onSubmit: onSubmit, onCancel: hideOverlay
        )
        .overlayIsFixedHeight(isFixedHeight: true)
        .accessibility(label: Text("HTTP Sign In"))
    }
}
