// Copyright Neeva. All rights reserved.

import WebKit
import SwiftUI

class ZoomActivity: UIActivity {
    private let webView: WKWebView
    private let overlayParent: UIViewController

    init(webView: WKWebView, overlayParent: UIViewController) {
        self.webView = webView
        self.overlayParent = overlayParent
    }

    override var activityTitle: String? { "Zoom Page" }
    override var activityImage: UIImage { UIImage(systemSymbol: .arrowUpLeftAndDownRightMagnifyingglass) }

    override func canPerform(withActivityItems activityItems: [Any]) -> Bool {
        true
    }

    override func perform() {
        let sheet = UIHostingController(
            rootView: ZoomMenuView(
                model: ZoomMenuModel(webView: webView),
                onDismiss: { [overlayParent] in overlayParent.presentedViewController?.dismiss(animated: true, completion: nil) }
            )
        )
        sheet.modalPresentationStyle = .overFullScreen
        sheet.view.isOpaque = false
        sheet.view.backgroundColor = .clear
        overlayParent.present(sheet, animated: true, completion: nil)
    }
}
