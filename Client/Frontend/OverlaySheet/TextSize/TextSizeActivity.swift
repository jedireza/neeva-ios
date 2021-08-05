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
        UserActivityHandler.presentTextSizeView(
            webView: webView,
            overlayParent: overlayParent)
    }
}
