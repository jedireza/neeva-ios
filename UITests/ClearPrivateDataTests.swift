/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import Defaults
import GCDWebServers
import Shared
import UIKit
import WebKit

@testable import Client

class ClearPrivateDataTests: UITestBase, UITextFieldDelegate {
    fileprivate var webRoot: String!

    override func setUp() {
        super.setUp()
        webRoot = SimplePageServer.start()
    }

    func visitSites(noOfSites: Int) -> [(
        title: String, domain: String, dispDomain: String, url: String
    )] {
        var urls: [(title: String, domain: String, dispDomain: String, url: String)] = []
        for pageNo in 1...noOfSites {
            let url = "\(webRoot!)/numberedPage.html?page=\(pageNo)"
            openNewTab(to: url)

            tester().waitForAnimationsToFinish()
            tester().waitForWebViewElementWithAccessibilityLabel("Page \(pageNo)")
            let dom = URL(string: url)!.normalizedHost!
            let dispDom = String(dom.prefix(7))  // On IPhone, it only displays first 8 chars
            let tuple: (title: String, domain: String, dispDomain: String, url: String) = (
                "Page \(pageNo)", dom, dispDom, url
            )
            urls.append(tuple)
        }

        resetToHome()

        // Restore the initial tab.
        tester().waitForAnimationsToFinish()
        tester().tapView(withAccessibilityLabel: "Add Tab")
        openURL()
        tester().waitForAnimationsToFinish()

        return urls
    }

    func testRemembersToggles() throws {
        try skipTest(issue: 3216, "KIF cannot recognize SwiftUI Toggles as UISwitches")

        clearPrivateData([Clearable.history])

        goToClearData()

        // Ensure the toggles match our settings.
        [
            (Clearable.cache, "0"), (Clearable.cookies, "0"), (Clearable.history, "1"),
        ].forEach { clearable, switchValue in
            XCTAssertNotNil(
                tester()
                    .waitForView(
                        withAccessibilityLabel: clearable.label(), value: switchValue,
                        traits: UIAccessibilityTraits.none))
        }

        closeClearPrivateData()
    }

    func testClearsHistoryPanel() throws {
        try skipTest(issue: 3216, "KIF cannot recognize SwiftUI Toggles as UISwitches")
        tester().waitForAnimationsToFinish(withTimeout: 3)
        let urls = visitSites(noOfSites: 2)

        let url1 = urls[0].url
        let url2 = urls[1].url

        goToHistory()
        tester().waitForView(withAccessibilityLabel: url1)
        tester().waitForView(withAccessibilityLabel: url2)
        closeHistory()

        clearPrivateData([Clearable.history])

        goToHistory()
        tester().waitForAbsenceOfView(withAccessibilityLabel: url1)
        tester().waitForAbsenceOfView(withAccessibilityLabel: url2)
        closeHistory()
    }

    func testDisabledHistoryDoesNotClearHistoryPanel() throws {
        try skipTest(issue: 3216, "KIF cannot recognize SwiftUI Toggles as UISwitches")
        tester().waitForAnimationsToFinish(withTimeout: 3)
        let urls = visitSites(noOfSites: 2)

        let url1 = urls[0].url
        let url2 = urls[1].url
        clearPrivateData(excluding: [.history])

        goToHistory()

        tester().waitForView(withAccessibilityLabel: url1)
        tester().waitForView(withAccessibilityLabel: url2)
        closeHistory()
    }

    func testClearsCookies() throws {
        try skipTest(issue: 1385, "Can’t find the cookie toggle")
        let url = "\(webRoot!)/numberedPage.html?page=1"
        tester().waitForAnimationsToFinish(withTimeout: 5)
        openURL(url)
        tester().waitForWebViewElementWithAccessibilityLabel("Page 1")

        let webView = tester().waitForView(withAccessibilityLabel: "Web content") as! WKWebView

        // Set and verify a dummy cookie value.
        setCookies(webView, cookie: "foo=bar")
        var cookies = getCookies(webView)
        XCTAssertEqual(cookies.cookie, "foo=bar")
        XCTAssertEqual(cookies.localStorage, "foo=bar")
        XCTAssertEqual(cookies.sessionStorage, "foo=bar")

        // Verify that cookies are not cleared when Cookies is deselected.
        clearPrivateData(excluding: [.cookies])

        tester().waitForAnimationsToFinish(withTimeout: 5)
        cookies = getCookies(webView)
        XCTAssertEqual(cookies.cookie, "foo=bar")
        XCTAssertEqual(cookies.localStorage, "foo=bar")
        XCTAssertEqual(cookies.sessionStorage, "foo=bar")

        // Verify that cookies are cleared when Cookies is selected.
        clearPrivateData([.cookies])

        tester().waitForAnimationsToFinish(withTimeout: 5)
        cookies = getCookies(webView)
        XCTAssertEqual(cookies.cookie, "")
        XCTAssertEqual(cookies.localStorage, "null")
        XCTAssertEqual(cookies.sessionStorage, "null")
    }

    func testClearsCache() throws {
        try skipTest(issue: 3216, "KIF cannot recognize SwiftUI Toggles as UISwitches")
        if isiPad() {
            try skipTest(issue: 1343, "Fails on iPad on CI only")
        }
        let cachedServer = CachedPageServer()
        let cacheRoot = cachedServer.start()
        let url = "\(cacheRoot)/cachedPage.html"
        openURL(url)
        tester().waitForWebViewElementWithAccessibilityLabel("Cache test")

        let webView = tester().waitForView(withAccessibilityLabel: "Web content") as! WKWebView
        let requests = cachedServer.requests

        // Verify that clearing non-cache items will keep the page in the cache.
        clearPrivateData(excluding: [.cache])
        webView.reload()
        XCTAssertEqual(cachedServer.requests, requests)

        // Verify that clearing the cache will fire a new request.
        clearPrivateData([Clearable.cache])
        webView.reload()
        XCTAssertEqual(cachedServer.requests, requests + 1)
    }

    fileprivate func setCookies(_ webView: WKWebView, cookie: String) {
        let expectation = self.expectation(description: "Set cookie")
        webView.evaluateJavascriptInDefaultContentWorld(
            "document.cookie = \"\(cookie)\"; localStorage.cookie = \"\(cookie)\"; sessionStorage.cookie = \"\(cookie)\";"
        ) { result, _ in
            expectation.fulfill()
        }
        waitForExpectations(timeout: 10, handler: nil)
    }

    fileprivate func getCookies(_ webView: WKWebView) -> (
        cookie: String, localStorage: String?, sessionStorage: String?
    ) {
        var cookie: (String, String?, String?)!
        var value: String!
        let expectation = self.expectation(description: "Got cookie")

        webView.evaluateJavascriptInDefaultContentWorld(
            "JSON.stringify([document.cookie, localStorage.cookie, sessionStorage.cookie])"
        ) { result, _ in
            value = result as? String
            expectation.fulfill()
        }

        waitForExpectations(timeout: 10, handler: nil)
        value = value.replacingOccurrences(of: "[", with: "")
        value = value.replacingOccurrences(of: "]", with: "")
        value = value.replacingOccurrences(of: "\"", with: "")
        let items = value.components(separatedBy: ",")
        cookie = (items[0], items[1], items[2])
        return cookie
    }

    func testClearsTrackingProtectionSafelist() throws {
        try skipTest(issue: 1885, "Advanced tracking prevention menu not enabled yet")
        let wait = expectation(description: "wait for file write")
        TrackingPreventionConfig.updateAllowList(
            with: (URL(string: "http://www.mozilla.com")?.host)!, allowed: true
        ) {
            wait.fulfill()
        }

        waitForExpectations(timeout: 30)
        clearPrivateData([Clearable.trackingProtection])

        XCTAssert(Defaults[.unblockedDomains].isEmpty)
    }
}

/// Server that keeps track of requests.
private class CachedPageServer {
    var requests = 0

    func start() -> String {
        let webServer = GCDWebServer()
        webServer.addHandler(
            forMethod: "GET", path: "/cachedPage.html", request: GCDWebServerRequest.self
        ) { (request) -> GCDWebServerResponse? in
            self.requests += 1
            return GCDWebServerDataResponse(
                html: "<html><head><title>Cached page</title></head><body>Cache test</body></html>")
        }

        webServer.start(withPort: 0, bonjourName: nil)

        // We use 127.0.0.1 explicitly here, rather than localhost, in order to avoid our
        // history exclusion code (Bug 1188626).
        let port = (webServer.port)
        let webRoot = "http://127.0.0.1:\(port)"
        return webRoot
    }
}
