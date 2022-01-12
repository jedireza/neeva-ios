// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import SwiftUI

struct WebViewContainer: UIViewRepresentable {
    let webView: WKWebView

    func makeUIView(context: Context) -> UIView {
        UIView()
    }

    func updateUIView(_ view: UIView, context: Context) {
        guard view.subviews.count != 1 || view.subviews.first != webView else { return }

        DispatchQueue.main.async {
            view.subviews.forEach { $0.removeFromSuperview() }
            view.addSubview(webView)
            webView.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }
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
