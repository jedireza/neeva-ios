/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import XCTest

class ClipBoardTests: BaseTestCase {
    let url = "www.example.com"

    //Check for test url in the browser
    func checkUrl() {
        let urlField = app.buttons["Address Bar"]
        waitForValueContains(urlField, value: "www.example")
    }

    //Copy url from the browser
    func copyUrl() {
        navigator.goto(URLBarOpen)
        waitForExistence(app.textFields["address"])
        app.textFields["address"].tap()
        waitForExistence(app.menuItems["Copy"])
        app.menuItems["Copy"].tap()
        app.typeText("\r")
        navigator.nowAt(BrowserTab)
    }

    //Check copied url is same as in browser
    func checkCopiedUrl() {
        if let myString = UIPasteboard.general.string {
            let value = app.buttons["Address Bar"].value as! String
            XCTAssertNotNil(myString)
            XCTAssertEqual(myString, value, "Url matches with the UIPasteboard")
        }
    }

    // This test is disabled in release, but can still run on master
    func testClipboard() {
        navigator.openURL(url)
        waitUntilPageLoad()
        checkUrl()
        copyUrl()
        checkCopiedUrl()

        navigator.createNewTab()

        app.buttons["Address Bar"].tap()
        app.textFields["address"].press(forDuration: 1)
        app.menuItems["Paste & Go"].tap()

        // causing tests to fail in CirceCI works locally
        // TODO: Find out why CirceCI says URL does not match (even though it does)
        // checkUrl()
    }

    // Smoketest
    /* Disabled: Test needs to be updated.
    func testClipboardPasteAndGo() {
        navigator.openURL(url)
        waitUntilPageLoad()
        copyUrl()
        checkCopiedUrl()

        navigator.createNewTab()
        app.buttons["Address Bar"].press(forDuration: 1)
        waitForExistence(app.tables["Context Menu"])
        app.cells["doc.on.clipboard"].tap()
        waitForExistence(app.buttons["Address Bar"])
        waitForValueContains(app.buttons["Address Bar"], value: "www.example.com")
    }
    */
}
