// Copyright Neeva. All rights reserved.

import SwiftUI
import WebKit

class TextSizeActivity: UIActivity {
    private let webView: WKWebView
    private let overlayParent: UIViewController

    init(webView: WKWebView, overlayParent: UIViewController) {
        self.webView = webView
        self.overlayParent = overlayParent
    }

    override var activityTitle: String? { "Text Size" }
    override var activityImage: UIImage {
        UIImage(systemSymbol: .textformatSize)
    }

    override func canPerform(withActivityItems activityItems: [Any]) -> Bool {
        true
    }

    override func perform() {
        let sheet = UIHostingController(
            rootView: TextSizeView(
                model: TextSizeModel(webView: webView),
                onDismiss: { [overlayParent] in
                    overlayParent.presentedViewController?.dismiss(animated: true, completion: nil)
                }
            )
        )
        sheet.modalPresentationStyle = .overFullScreen
        sheet.view.isOpaque = false
        sheet.view.backgroundColor = .clear
        overlayParent.present(sheet, animated: true, completion: nil)
    }
}
