// Copyright Neeva. All rights reserved.

import Shared
import SwiftUI

struct OpenInAppOverlaySheetContent: View {
    @Environment(\.hideOverlaySheet) private var hideOverlaySheet

    let url: URL

    var body: some View {
        OpenInAppOverlayView(
            url: url,
            onOpen: {
                hideOverlaySheet()
                UIApplication.shared.open(url, options: [:])
            },
            onCancel: hideOverlaySheet
        )
        .overlaySheetIsFixedHeight(isFixedHeight: true)
    }
}
