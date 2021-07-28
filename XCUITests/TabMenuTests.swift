// Copyright Neeva. All rights reserved.

import XCTest

private let firstWebsite = (
    url: path(forTestPage: "test-mozilla-org.html"),
    tabName: "Internet for people, not profit — Mozilla"
)
private let secondWebsite = (
    url: path(forTestPage: "test-mozilla-book.html"), tabName: "The Book of Mozilla"
)

class TabMenuTests: BaseTestCase {
    func testCloseNormalTabFromTab() {
        openTwoWebsites()

        waitForExistence(app.buttons["Show Tabs"], timeout: 3)
        app.buttons["Show Tabs"].press(forDuration: 1)

        waitForExistence(app.buttons["Close Tab"], timeout: 3)
        app.buttons["Close Tab"].tap()

        goToTabTray()

        XCTAssertEqual(app.cells.count, 1, "Expected number of tabs remaining is not correct")
        XCTAssertEqual(
            app.cells.firstMatch.label, firstWebsite.tabName,
            "Expected label of remaining tab is not correct")
    }

    func testCloseAllNormalTabsFromTab() {
        openTwoWebsites()

        waitForExistence(app.buttons["Show Tabs"], timeout: 3)
        app.buttons["Show Tabs"].press(forDuration: 1)

        waitForExistence(app.buttons["Close All Tabs"], timeout: 3)
        app.buttons["Close All Tabs"].tap()

        waitForExistence(app.buttons["Confirm Close All Tabs"], timeout: 3)
        app.buttons["Confirm Close All Tabs"].tap()

        goToTabTray()

        XCTAssertEqual(app.cells.count, 1, "Expected number of tabs remaining is not correct")
        XCTAssertEqual(
            app.cells.firstMatch.label, "Home", "Expected label of remaining tab is not correct")
    }

    func testCloseIncognitoTabFromTab() {
        toggleIncognito()
        openTwoWebsites()

        waitForExistence(app.buttons["Show Tabs"], timeout: 3)
        app.buttons["Show Tabs"].press(forDuration: 1)

        waitForExistence(app.buttons["Close Tab"], timeout: 3)
        app.buttons["Close Tab"].tap()

        goToTabTray()

        XCTAssertEqual(app.cells.count, 1, "Expected number of tabs remaining is not correct")
        XCTAssertEqual(
            app.cells.firstMatch.label, firstWebsite.tabName,
            "Expected label of remaining tab is not correct")
    }

    func testCloseAllIncognitoTabsFromTab() {
        toggleIncognito()
        openTwoWebsites()

        waitForExistence(app.buttons["Show Tabs"], timeout: 3)
        app.buttons["Show Tabs"].press(forDuration: 1)
        waitForExistence(app.buttons["Close All Tabs"], timeout: 3)
        app.buttons["Close All Tabs"].tap()

        waitForExistence(app.buttons["Confirm Close All Tabs"], timeout: 3)
        app.buttons["Confirm Close All Tabs"].tap()

        waitForExistence(app.buttons["Show Tabs"], timeout: 3)
        toggleIncognito()

        goToTabTray()

        XCTAssertEqual(app.cells.count, 1, "Expected number of tabs remaining is not correct")
        XCTAssertEqual(
            app.cells.firstMatch.label, "Home", "Expected label of remaining tab is not correct")
    }

    func testCloseAllNormalTabsFromSwitcher() {
        openTwoWebsites()

        goToTabTray()
        app.buttons["Done"].press(forDuration: 1)

        waitForExistence(app.buttons["Close All Tabs"], timeout: 3)
        app.buttons["Close All Tabs"].tap()

        waitForExistence(app.buttons["Confirm Close All Tabs"], timeout: 3)
        app.buttons["Confirm Close All Tabs"].tap()

        goToTabTray()

        XCTAssertEqual(app.cells.count, 1, "Expected number of tabs remaining is not correct")
        XCTAssertEqual(
            app.cells.firstMatch.label, "Home", "Expected label of remaining tab is not correct")
    }

    func testCloseAllIncognitoTabsFromSwitcher() {
        toggleIncognito()
        openTwoWebsites()

        goToTabTray()
        app.buttons["Done"].press(forDuration: 1)

        waitForExistence(app.buttons["Close All Tabs"], timeout: 3)
        app.buttons["Close All Tabs"].tap()

        waitForExistence(app.buttons["Confirm Close All Tabs"], timeout: 3)
        app.buttons["Confirm Close All Tabs"].tap()

        waitForExistence(app.buttons["Done"], timeout: 3)

        toggleIncognito()
        goToTabTray()

        XCTAssertEqual(app.cells.count, 1, "Expected number of tabs remaining is not correct")
        XCTAssertEqual(
            app.cells.firstMatch.label, "Home", "Expected label of remaining tab is not correct")
    }
}

extension BaseTestCase {
    func openTwoWebsites() {
        // Open two tabs
        openURL(firstWebsite.url)
        openURLInNewTab(secondWebsite.url)
    }
}
