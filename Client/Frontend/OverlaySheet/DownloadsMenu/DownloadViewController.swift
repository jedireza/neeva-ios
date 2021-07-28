// Copyright Neeva. All rights reserved.

import SwiftUI
import UIKit

struct DownloadRootView: View {
    var overlaySheetModel = OverlaySheetModel()
    let fileName: String
    let fileURL: String
    let fileSize: String?

    let onDownload: () -> Void
    let onDismiss: () -> Void

    var body: some View {
        let config = OverlaySheetConfig(showTitle: false, backgroundColor: .systemGroupedBackground)
        OverlaySheetView(model: self.overlaySheetModel, config: config, onDismiss: { onDismiss() })
        {
            DownloadMenuView(
                fileName: fileName, fileURL: fileURL, fileSize: fileSize,
                onDownload: { onDownload() }, onDismiss: { onDismiss() }
            )
            .overlaySheetIsFixedHeight(isFixedHeight: true)
        }
        .onAppear {
            // It seems to be necessary to delay starting the animation until this point to
            // avoid a visual artifact.
            DispatchQueue.main.async {
                self.overlaySheetModel.show()
            }
        }
    }
}

class DownloadViewController: UIHostingController<DownloadRootView> {
    init(
        fileName: String, fileURL: String, fileSize: String?, onDownload: @escaping () -> Void,
        onDismiss: @escaping () -> Void
    ) {
        super.init(
            rootView: DownloadRootView(
                fileName: fileName, fileURL: fileURL, fileSize: fileSize, onDownload: onDownload,
                onDismiss: onDismiss))
        self.view.accessibilityViewIsModal = true
    }

    @objc required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // By default, a UIHostingController opens as an opaque layer, so we override
        // that behavior here.
        view.backgroundColor = .clear
    }
}
