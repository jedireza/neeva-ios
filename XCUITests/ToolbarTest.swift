/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import XCTest

let website1: [String: String] = [
    "url": path(forTestPage: "test-mozilla-org.html"),
    "label": "Internet for people, not profit — Mozilla", "value": "localhost",
    "longValue": "localhost:\(serverPort)/test-fixture/test-mozilla-org.html",
]
let website2 = path(forTestPage: "test-example.html")

let PDFWebsite = ["url": "http://www.pdf995.com/samples/pdf.pdf"]

class ToolbarTests: BaseTestCase {
    override func setUp() {
        super.setUp()
        XCUIDevice.shared.orientation = UIDeviceOrientation.landscapeLeft
    }

    override func tearDown() {
        XCUIDevice.shared.orientation = UIDeviceOrientation.portrait
        super.tearDown()
    }

    /// Tests landscape page navigation enablement with the URL bar with tab switching.
    func testLandscapeNavigationWithTabSwitch() {
        XCTAssert(app.buttons["Address Bar"].exists)

        // Check that the back and forward buttons are disabled
        XCTAssertFalse(app.buttons["Back"].isEnabled)
        XCTAssertFalse(app.buttons["Forward"].isEnabled)

        // Navigate to two pages and press back once so that all buttons are enabled in landscape mode.
        openURL(website1["url"]!)
        waitUntilPageLoad()
        waitForExistence(app.webViews.links["Mozilla"], timeout: 10)
        let valueMozilla = app.buttons["Address Bar"].value as! String
        XCTAssertEqual(valueMozilla, website1["url"])
        XCTAssertTrue(app.buttons["Back"].isEnabled)
        XCTAssertFalse(app.buttons["Forward"].isEnabled)
        XCTAssertTrue(app.buttons["Reload"].isEnabled)

        openURL(website2)
        waitUntilPageLoad()
        waitForValueContains(app.buttons["Address Bar"], value: website2)
        XCTAssertTrue(app.buttons["Back"].isEnabled)
        XCTAssertFalse(app.buttons["Forward"].isEnabled)

        app.buttons["Back"].tap()
        XCTAssertEqual(valueMozilla, website1["url"])

        waitUntilPageLoad()
        XCTAssertTrue(app.buttons["Back"].isEnabled)
        XCTAssertTrue(app.buttons["Forward"].isEnabled)

        // Open new tab and then go back to previous tab to test navigation buttons.
        waitForExistence(app.buttons["Show Tabs"], timeout: 15)
        goToTabTray()
        waitForExistence(app.buttons["\(website1["label"]!), Tab"])
        XCTAssertEqual(valueMozilla, website1["url"])

        getTabs().firstMatch.tap()

        // Test to see if all the buttons are enabled then close tab.
        waitUntilPageLoad()
        waitForExistence(app.buttons["Back"])
        XCTAssertTrue(app.buttons["Back"].isEnabled)
        XCTAssertTrue(app.buttons["Forward"].isEnabled)

        waitForExistence(app.buttons["Show Tabs"], timeout: 15)
        goToTabTray()

        waitForExistence(app.buttons["\(website1["label"]!), Tab"])
        app.buttons["Close \(website1["label"]!)"].tap()

        // Go Back to other tab to see if all buttons are disabled.
        XCTAssertFalse(app.buttons["Back"].isEnabled)
        XCTAssertFalse(app.buttons["Forward"].isEnabled)
    }

    func testClearURLTextUsingBackspace() {
        openURL(path(forTestPage: "test-mozilla-book.html"))

        let valueMozilla = app.buttons["Address Bar"].value as! String
        XCTAssertEqual(valueMozilla, path(forTestPage: "test-mozilla-book.html"))

        // Simulate pressing on backspace key should remove the text
        app.buttons["Address Bar"].tap()
        app.textFields["address"].typeText("\u{8}")

        let value = app.textFields["address"].value
        XCTAssertEqual(value as? String, "", "The url has not been removed correctly")
    }

    // Check that after scrolling on a page, the URL bar is hidden. Tapping one on the status bar will reveal the URL bar, tapping again on the status will scroll to the top
    func testRevealToolbarWhenTappingOnStatusbar() {
        openURL(path(forTestPage: "test-mozilla-org.html"))
        waitUntilPageLoad()
        waitForExistence(app.buttons["Show Tabs"], timeout: 15)

        // Workaround when testing on iPhone. If the orientation is in landscape on iPhone the tests will fail.
        if !iPad() {
            XCUIDevice.shared.orientation = UIDeviceOrientation.portrait
            waitForExistence(app.otherElements.matching(identifier: "TabToolbar").firstMatch)
        }

        let shareButton = app.buttons["Share"]
        let statusbarElement: XCUIElement = {
            return XCUIApplication(bundleIdentifier: "com.apple.springboard").statusBars.firstMatch
        }()

        app.swipeUp()
        waitFor(shareButton, with: "isHittable == false")

        if iPad() {
            // test doesn't work on iPad so trying next best thing
            app.swipeDown()
        } else {
            statusbarElement.tap(force: true)
        }

        waitForExistence(shareButton)
        XCTAssertTrue(shareButton.isHittable)
    }
}
