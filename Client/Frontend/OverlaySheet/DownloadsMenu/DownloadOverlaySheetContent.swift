// Copyright Neeva. All rights reserved.

import Shared
import SwiftUI

struct DownloadOverlaySheetContent: View {
    @Environment(\.hideOverlaySheet) private var hideOverlaySheet

    let fileName: String
    let fileURL: String
    let fileSize: String?
    let onDownload: () -> Void

    var body: some View {
        DownloadMenuView(
            fileName: fileName, fileURL: fileURL, fileSize: fileSize,
            onDownload: {
                hideOverlaySheet()
                onDownload()
            },
            onCancel: hideOverlaySheet
        )
        .overlaySheetIsFixedHeight(isFixedHeight: true)
    }
}
