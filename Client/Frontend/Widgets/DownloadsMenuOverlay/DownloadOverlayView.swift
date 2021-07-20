// Copyright Neeva. All rights reserved.

import UIKit
import SwiftUI
import Shared

struct DownloadMenuView: View {
    let fileName: String
    let fileURL: String
    let fileSize: String?
    
    let onDownload: () -> ()
    let onDismiss: () -> ()

    public var body: some View {
        VStack(alignment: .leading, spacing: 26) {
            VStack(alignment: .leading, spacing: 4) {
                Text(fileName)
                    .withFont(.bodyLarge)
                    .truncationMode(.middle)
                    .foregroundColor(.primary)

                Text(fileURL)
                    .withFont(.labelMedium)
                    .truncationMode(.head)
                    .foregroundColor(.secondary)
            }

            VStack(alignment: .center, spacing: 12) {
                OverlaySheetButton(fileSize != nil ? "Download (\(fileSize!))" : "Download", action: onDownload)
                OverlaySheetButton("Cancel", action: onDismiss)
            }
            .foregroundColor(.ui.adaptive.blue)
        }.padding()
    }
}

struct DownloadMenuView_Previews: PreviewProvider {
    static var previews: some View {
        DownloadMenuView(fileName: "markus-spiske-jsqrSfrtjB80-unsplash.jpg", fileURL: "www.unsplash.com", fileSize: "2.2 MB", onDownload: {}, onDismiss: {})
    }
}
