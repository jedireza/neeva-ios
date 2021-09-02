// Copyright Neeva. All rights reserved.

import Shared
import SwiftUI

struct HTTPAuthPromptOverlaySheetContent: View {
    @Environment(\.hideOverlaySheet) private var hideOverlaySheet

    let url: String
    let onSubmit: (String, String) -> Void

    var body: some View {
        HTTPAuthPromptOverlayView(
            url: url, onSubmit: onSubmit, onCancel: hideOverlaySheet
        )
        .overlaySheetIsFixedHeight(isFixedHeight: true)
        .accessibility(label: Text("HTTP Sign In"))
    }
}
