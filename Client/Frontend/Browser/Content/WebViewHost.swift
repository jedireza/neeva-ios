// Copyright Neeva. All rights reserved.

import SwiftUI

class WebViewHost: UIHostingController<WebViewHost.Content> {
    struct Content: View {
        let webView: WKWebView?
        var body: some View {
            if let webView = webView {
                WebViewContainer(webView: webView)
            }
        }
    }

    init(webView: WKWebView?) {
        super.init(rootView: Content(webView: webView))
    }

    @objc required dynamic init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setWebView(_ webView: WKWebView?) {
        self.rootView = Content(webView: webView)
    }
}
