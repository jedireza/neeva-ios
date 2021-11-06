// Copyright Neeva. All rights reserved.

import SwiftUI

struct WebViewContainer: UIViewRepresentable {
    let webView: WKWebView

    func makeUIView(context: Context) -> UIView {
        UIView()
    }

    func updateUIView(_ view: UIView, context: Context) {
        guard view.subviews.count != 1 || view.subviews.first != webView else { return }
        view.subviews.forEach { $0.removeFromSuperview() }
        view.addSubview(webView)
        webView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}

struct WebViewContainer_Previews: PreviewProvider {
    static var previews: some View {
        WebViewContainer(
            webView: {
                let wv = WKWebView()
                wv.load(URLRequest(url: "https://neeva.com"))
                return wv
            }())
    }
}
