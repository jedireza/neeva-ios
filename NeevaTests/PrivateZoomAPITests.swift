// Copyright Neeva. All rights reserved.

import WebKit
import XCTest

@testable import Client

class PrivateZoomAPITests: XCTestCase {
    let webView = WKWebView()

    func testZoom() {
        XCTAssertEqual(webView.neeva_zoomAmount, CGFloat(1))
        let amounts: [CGFloat] = [3, 1, 0.5, 1.5, 0.25, 4 / 3]
        for amount in amounts {
            webView.neeva_zoomAmount = amount
            XCTAssertEqual(webView.neeva_zoomAmount, amount)
        }
    }
}
