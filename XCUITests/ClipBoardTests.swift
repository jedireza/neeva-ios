/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import XCTest

class ClipBoardTests: BaseTestCase {
    let url = "www.example.com"

    // Check for test url in the browser
    func checkUrl() {
        let urlField = app.buttons["Address Bar"]
        waitForValueContains(urlField, value: "http://example.com/", timeout: 30)
    }

    // Copy url from the browser
    func copyUrl() {
        app.buttons["Address Bar"].tap()

        waitForExistence(app.buttons["Edit Current URL"])
        app.buttons["Edit Current URL"].press(forDuration: 1)

        waitForExistence(app.buttons["Copy Address"])
        app.buttons["Copy Address"].tap()
    }

    // Check copied url is same as in browser
    func checkCopiedUrl() {
        if let myString = UIPasteboard.general.string {
            let value = app.buttons["Address Bar"].value as! String
            XCTAssertNotNil(myString)
            XCTAssertEqual(myString, value, "Url matches with the UIPasteboard")
        }
    }

    // This test is disabled in release, but can still run on master
    func testClipboard() {
        openURL()
        checkUrl()
        copyUrl()
        checkCopiedUrl()

        waitForExistence(app.buttons["Edit Current URL"])
        app.buttons["Edit Current URL"].tap()
        app.textFields["address"].typeText("\n")

        waitForExistence(app.buttons["Address Bar"])
        app.buttons["Address Bar"].press(forDuration: 2)

        waitForExistence(app.menuItems["Paste & Go"], timeout: 30)
        app.menuItems["Paste & Go"].tap()

        checkUrl()
    }
}
