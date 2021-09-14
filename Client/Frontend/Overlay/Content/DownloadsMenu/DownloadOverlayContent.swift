// Copyright Neeva. All rights reserved.

import Shared
import SwiftUI

struct DownloadOverlayContent: View {
    @Environment(\.hideOverlay) private var hideOverlay

    let fileName: String
    let fileURL: String
    let fileSize: String?
    let onDownload: () -> Void

    var body: some View {
        DownloadMenuView(
            fileName: fileName, fileURL: fileURL, fileSize: fileSize,
            onDownload: {
                hideOverlay()
                onDownload()
            },
            onCancel: hideOverlay
        )
        .overlayIsFixedHeight(isFixedHeight: true)
    }
}
