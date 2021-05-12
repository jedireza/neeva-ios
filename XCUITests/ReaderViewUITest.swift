/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import XCTest

class ReaderViewTest: BaseTestCase {
    // Smoketest
    func testLoadReaderContent() {
        userState.url = path(forTestPage: "test-mozilla-book.html")
        navigator.goto(BrowserTab)
        waitForNoExistence(app.staticTexts["Fennec pasted from XCUITests-Runner"])
        waitForExistence(app.buttons["Reader View"], timeout: 5)
        app.buttons["Reader View"].tap()
        app.buttons["Reload"].tap()
        // The settings of reader view are shown as well as the content of the web site
        waitForExistence(app.buttons["Display Settings"], timeout: 5)
        XCTAssertTrue(app.webViews.staticTexts["The Book of Mozilla"].exists)
    }
}
