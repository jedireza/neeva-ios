// Copyright Neeva. All rights reserved.

import WebKit
import Combine

class ZoomMenuModel: ObservableObject {
    private let webView: WKWebView

    var objectWillChange = ObservableObjectPublisher()
    private var subscription: AnyCancellable?

    init(webView: WKWebView) {
        self.webView = webView
        self.subscription = webView
            .publisher(for: \.pageZoom, options: .new)
            .sink { [unowned self] _ in objectWillChange.send() }

        #if !USE_PRIVATE_WEB_VIEW_ZOOM_API
        webView.evaluateJavaScript("document.body.style.webkitTextSizeAdjust") { amount, _ in
            if let amount = amount as? String,
               amount.hasSuffix("%"),
               let percent = Double(amount.dropLast()) {
                self._suppressUpdate = true
                self.pageZoom = CGFloat(percent / 100)
            }
        }
        #endif
    }

    #if USE_PRIVATE_WEB_VIEW_ZOOM_API
    private var observer: AnyCancellable?
    /// Remove `-DUSE_PRIVATE_WEB_VIEW_ZOOM_API` from `Client/Configuration/Common.xcconfig` to switch to the `-webkit-text-size-adjust`-based zoom implementation
    var pageZoom: CGFloat {
        get {
            webView.neeva_zoomAmount
        }
        set {
            objectWillChange.send()
            webView.neeva_zoomAmount = newValue
            let originalOffset = webView.scrollView.contentOffset
            let newOffset = CGPoint(x: originalOffset.x, y: originalOffset.y * newValue / pageZoom)
            observer = webView.scrollView.publisher(for: \.contentOffset)
                .sink { offset in
                    if offset != originalOffset {
                        self.webView.scrollView.contentOffset = newOffset
                        self.observer = nil
                    }
                }
        }
    }
    #else
    private var _suppressUpdate = false
    var pageZoom: CGFloat = 1 {
        didSet {
            objectWillChange.send()
            if _suppressUpdate {
                _suppressUpdate = false
            } else {
                webView.evaluateJavaScript("document.body.style.webkitTextSizeAdjust = '\(pageZoom * 100)%'")
            }
        }
    }
    #endif

    // observed from Safari on iOS 14.6 (18F72)
    let levels: [CGFloat] = [0.5, 0.75, 0.85, 1, 1.15, 1.25, 1.5, 1.75, 2, 2.5, 3]

    var canZoomIn: Bool { pageZoom != levels.last }
    var canZoomOut: Bool { pageZoom != levels.first }

    func zoomIn() {
        if pageZoom < levels.first! {
            pageZoom = levels.first!
        } else if pageZoom < levels.last! {
            for (lower, upper) in zip(levels, levels.dropFirst()) {
                if lower <= pageZoom, pageZoom < upper {
                    pageZoom = upper
                    return
                }
            }
        }
        // otherwise, keep as-is
    }

    func zoomOut() {
        if pageZoom > levels.last! {
            pageZoom = levels.last!
        } else if pageZoom > levels.first! {
            for (lower, upper) in zip(levels, levels.dropFirst()) {
                if lower < pageZoom, pageZoom <= upper {
                    pageZoom = lower
                    return
                }
            }
        }
        // otherwise, keep as-is
    }

    private let formatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .percent
        return formatter
    }()

    var label: String {
        let percent = formatter.string(from: pageZoom as NSNumber)!
        if !canZoomIn {
            return "maximum, \(percent)"
        }
        if !canZoomOut {
            return "minimum, \(percent)"
        }
        if pageZoom == 1 {
            return "default, \(percent)"
        }
        return percent
    }

}
