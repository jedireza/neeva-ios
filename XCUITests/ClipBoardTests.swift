/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import XCTest

class ClipBoardTests: BaseTestCase {
    let url = "www.example.com"

    //Check for test url in the browser
    func checkUrl() {
        let urlField = app.buttons["Address Bar"]
        waitForValueContains(urlField, value: "http://example.com/")
    }

    //Copy url from the browser
    func copyUrl() {
        app.buttons["Address Bar"].tap()
        waitForExistence(app.textFields["address"])
        app.textFields["address"].tap()

        waitForExistence(app.menuItems["Copy"])
        app.menuItems["Copy"].tap()
        app.typeText("\r")
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
        openURL("example.com")
        checkUrl()
        copyUrl()
        checkCopiedUrl()

        newTab()

        waitForExistence(app.textFields["address"])
        app.textFields["address"].tap()
        waitFor(
            app.menuItems.matching(
                NSPredicate(format: "label = 'Paste & Go' OR label = 'show.next.items.menu.button'")
            ), with: "count > 0")
        while !app.menuItems["Paste & Go"].exists {
            app.menuItems["show.next.items.menu.button"].tap()
        }
        app.menuItems["Paste & Go"].tap()

        checkUrl()
    }
}
