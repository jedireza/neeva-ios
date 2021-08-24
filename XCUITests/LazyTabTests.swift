// Copyright Neeva. All rights reserved.

import XCTest

class LazyTabTests: BaseTestCase {
    override func setUp() {
        // For this test, preset a junk login cookie.
        if testName == "testNoTabAddedWhenCancelingNewTabFromOverflow" || testName == "testLazyTabCreatedFromOverflow" {
            launchArguments.append("\(LaunchArguments.EnableFeatureFlags)overflowMenu")
        }

        super.setUp()
    }

    func testCancelURLBarReturnsToWebsite() {
        openURL()
        waitForExistence(app.staticTexts["Example Domain"])

        app.buttons["Address Bar"].tap()
        waitForExistence(app.buttons["Cancel"])
        app.buttons["Cancel"].tap()

        // Confirms the app returns to the web page
        waitForExistence(app.staticTexts["Example Domain"])
    }

    // MARK: Tab Tray
    func testNoTabAddedWhenCancelingNewTabFromTabTray() {
        openURL()
        goToTabTray()

        app.buttons["Add Tab"].tap()

        waitForExistence(app.buttons["Cancel"])
        app.buttons["Cancel"].tap()

        // Confirms the app returns to the tab tray
        waitForExistence(app.buttons["Add Tab"])
    }

    func testLazyTabCreatedFromTabTray() {
        openURL()
        goToTabTray()

        app.buttons["Add Tab"].tap()
        waitForExistence(app.buttons["Cancel"])
        openURL()

        goToTabTray()
        XCTAssertEqual(getTabs().count, 2)
    }

    // MARK: Long Press Tab Tray Button
    func testNoTabAddedWhenCancelingNewTabFromLongPressTabTrayButton() {
        openURL()
        newTab()
        
        app.buttons["Cancel"].tap()

        // Confirms that no tab was created
        goToTabTray()
        XCTAssertEqual(getTabs().count, 1)
    }

    func testLazyTabCreatedFromLongPressTabTrayButton() {
        openURL()
        newTab()
        openURL()

        goToTabTray()
        XCTAssertEqual(getTabs().count, 2)
    }

    // MARK: Overflow
    func testNoTabAddedWhenCancelingNewTabFromOverflow() {
        goToOverflowMenu()

        app.buttons["New Tab"].tap()

        waitForExistence(app.buttons["Cancel"])
        app.buttons["Cancel"].tap()

        // Confirms that no tab was created
        goToTabTray()
        XCTAssertEqual(getTabs().count, 1)
    }

    func testLazyTabCreatedFromOverflow() {
        goToOverflowMenu()

        app.buttons["New Tab"].tap()

        waitForExistence(app.buttons["Cancel"])
        openURL()

        goToTabTray()
        XCTAssertEqual(getTabs().count, 2)
    }
}
