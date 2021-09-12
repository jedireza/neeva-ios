// Copyright Neeva. All rights reserved.

import XCTest

class LazyTabTests: BaseTestCase {
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
        goToTabTray()

        app.buttons["Add Tab"].tap()

        waitForExistence(app.buttons["Cancel"])
        app.buttons["Cancel"].tap()

        // Confirms the app returns to the tab tray
        waitForExistence(app.buttons["Add Tab"])
    }

    func testLazyTabCreatedFromTabTray() {
        goToTabTray()

        app.buttons["Add Tab"].tap()
        waitForExistence(app.buttons["Cancel"])
        openURL()

        goToTabTray()
        XCTAssertEqual(getTabs().count, 2)
    }

    // MARK: Long Press Tab Tray Button
    func testNoTabAddedWhenCancelingNewTabFromLongPressTabTrayButton() {
        newTab()

        app.buttons["Cancel"].tap()

        // Confirms that no tab was created
        goToTabTray()
        XCTAssertEqual(getTabs().count, 1)
    }

    func testLazyTabCreatedFromLongPressTabTrayButton() {
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

    // MARK: Incognito Mode
    func testNoTabAddedWhenCancelingNewTabFromIncognito() {
        goToTabTray()
        toggleIncognito(shouldOpenURL: false)

        waitForExistence(app.buttons["Cancel"])
        app.buttons["Cancel"].tap()

        // confirms that the tab tray is open and that the non-incognito tab is shown
        XCTAssertEqual(
            getTabs().firstMatch.label, "Home, Tab",
            "Expected label of remaining tab is not correct")
    }

    func testLazyTabCreatedFromIncognito() {
        openURL(path(forTestPage: "test-mozilla-book.html"))
        goToTabTray()
        toggleIncognito()

        goToTabTray()

        // confirms incognito tab was created
        waitForExistence(app.buttons["Example Domain, Tab"])
        XCTAssertEqual(
            getTabs().firstMatch.label, "Example Domain, Tab",
            "Expected label of remaining tab is not correct")

        toggleIncognito(closeTabTray: false)

        // confirms that non-incognito tab is shown
        waitForExistence(app.buttons["The Book of Mozilla, Tab"])
        XCTAssertEqual(
            getTabs().firstMatch.label, "The Book of Mozilla, Tab",
            "Expected label of remaining tab is not correct")
    }

    func testLazyTabNotCreatedWhenIncognitoTabOpen() {
        // create normal tab and open incognito tab
        openURL(path(forTestPage: "test-mozilla-book.html"))
        goToTabTray()
        toggleIncognito()

        // switch back to normal mode
        goToTabTray()
        toggleIncognito(closeTabTray: false)

        // switch back to incognito mode
        toggleIncognito(closeTabTray: false)

        // confirms that non-incognito tab is shown
        XCTAssert(!app.buttons["Cancel"].exists)
        XCTAssertEqual(
            getTabs().firstMatch.label, "Example Domain, Tab",
            "Expected label of remaining tab is not correct")
    }
}
