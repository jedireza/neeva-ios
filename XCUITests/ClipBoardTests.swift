/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import XCTest

class ClipBoardTests: BaseTestCase {
    let url = "www.example.com"

    //Check for test url in the browser
    func checkUrl() {
        let urlField = app.buttons["url"]
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
            let value = app.buttons["url"].value as! String
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
        waitForNoExistence(app.staticTexts["XCUITests-Runner pasted from Neeva"])
        navigator.goto(URLBarOpen)
        app.textFields["address"].press(forDuration: 3)
        app.menuItems["Paste"].tap()
        waitForValueContains(app.textFields["address"], value: "www.example.com")
    }

    // Smoketest
    /* Disabled: Test needs to be updated.
    func testClipboardPasteAndGo() {
        navigator.openURL(url)
        waitUntilPageLoad()
        copyUrl()
        checkCopiedUrl()

        waitForNoExistence(app.staticTexts["XCUITests-Runner pasted from Neeva"])
        navigator.createNewTab()
        waitForNoExistence(app.staticTexts["XCUITests-Runner pasted from Neeva"])
        app.buttons["url"].press(forDuration: 3)
        waitForExistence(app.tables["Context Menu"])
        app.cells["doc.on.clipboard"].tap()
        waitForExistence(app.buttons["url"])
        waitForValueContains(app.buttons["url"], value: "www.example.com")
    }
    */
}
