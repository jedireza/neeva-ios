// Copyright Neeva. All rights reserved.

import XCTest

fileprivate let firstWebsite = (url: path(forTestPage: "test-mozilla-org.html"), tabName: "Internet for people, not profit — Mozilla")
fileprivate let secondWebsite = (url: path(forTestPage: "test-mozilla-book.html"), tabName: "The Book of Mozilla")

class TabMenuTests: BaseTestCase {
    func testCloseNormalTabFromTab() {
        openTwoWebsites()

        waitForExistence(app.buttons["Show Tabs"], timeout: 3)
        app.buttons["Show Tabs"].press(forDuration: 3)

        waitForExistence(app.buttons["Close Tab"], timeout: 3)
        app.buttons["Close Tab"].tap()

        waitForExistence(app.buttons["Show Tabs"], timeout: 3)

        navigator.goto(TabTray)
        waitForExistence(app.buttons["Done"], timeout: 3)

        XCTAssertEqual(app.cells.count, 1, "Expected number of tabs remaining is not correct")
        XCTAssertEqual(app.cells.firstMatch.label, firstWebsite.tabName, "Expected label of remaining tab is not correct")
    }

    func testCloseAllNormalTabsFromTab() {
        openTwoWebsites()

        waitForExistence(app.buttons["Show Tabs"], timeout: 3)
        app.buttons["Show Tabs"].press(forDuration: 3)

        waitForExistence(app.buttons["Close All Tabs"], timeout: 3)
        app.buttons["Close All Tabs"].tap()

        waitForExistence(app.buttons["Confirm Close All Tabs"], timeout: 3)
        app.buttons["Confirm Close All Tabs"].tap()

        waitForExistence(app.buttons["Show Tabs"], timeout: 3)
        navigator.nowAt(NewTabScreen)

        navigator.goto(TabTray)
        waitForExistence(app.buttons["Done"], timeout: 3)

        XCTAssertEqual(app.cells.count, 1, "Expected number of tabs remaining is not correct")
        XCTAssertEqual(app.cells.firstMatch.label, "Home", "Expected label of remaining tab is not correct")
    }

    func testCloseIncognitoTabFromTab() {
        navigator.performAction(Action.TogglePrivateMode)
        navigator.nowAt(NewTabScreen)

        openTwoWebsites()

        waitForExistence(app.buttons["Show Tabs"], timeout: 3)
        app.buttons["Show Tabs"].press(forDuration: 3)

        waitForExistence(app.buttons["Close Tab"], timeout: 3)
        app.buttons["Close Tab"].tap()

        waitForExistence(app.buttons["Show Tabs"], timeout: 3)

        navigator.goto(TabTray)
        waitForExistence(app.buttons["Done"], timeout: 3)

        XCTAssertEqual(app.cells.count, 1, "Expected number of tabs remaining is not correct")
        XCTAssertEqual(app.cells.firstMatch.label, firstWebsite.tabName, "Expected label of remaining tab is not correct")
    }

    func testCloseAllIncognitoTabsFromTab() {
        navigator.performAction(Action.TogglePrivateMode)
        navigator.nowAt(NewTabScreen)

        openTwoWebsites()

        waitForExistence(app.buttons["Show Tabs"], timeout: 3)
        app.buttons["Show Tabs"].press(forDuration: 3)

        waitForExistence(app.buttons["Close All Tabs"], timeout: 3)
        app.buttons["Close All Tabs"].tap()

        waitForExistence(app.buttons["Confirm Close All Tabs"], timeout: 3)
        app.buttons["Confirm Close All Tabs"].tap()

        waitForExistence(app.buttons["Show Tabs"], timeout: 3)
        navigator.nowAt(NewTabScreen)

        navigator.performAction(Action.TogglePrivateMode)

        waitForExistence(app.buttons["Show Tabs"], timeout: 3)
        navigator.nowAt(NewTabScreen)

        navigator.goto(TabTray)
        waitForExistence(app.buttons["Done"], timeout: 3)

        XCTAssertEqual(app.cells.count, 1, "Expected number of tabs remaining is not correct")
        XCTAssertEqual(app.cells.firstMatch.label, "Home", "Expected label of remaining tab is not correct")
    }

    func testCloseAllNormalTabsFromSwitcher() {
        openTwoWebsites()
        navigator.goto(TabTray)

        waitForExistence(app.buttons["Done"], timeout: 3)
        app.buttons["Done"].press(forDuration: 3)

        waitForExistence(app.buttons["Close All Tabs"], timeout: 3)
        app.buttons["Close All Tabs"].tap()

        waitForExistence(app.buttons["Confirm Close All Tabs"], timeout: 3)
        app.buttons["Confirm Close All Tabs"].tap()

        waitForExistence(app.buttons["Show Tabs"], timeout: 3)
        navigator.nowAt(NewTabScreen)

        navigator.goto(TabTray)
        waitForExistence(app.buttons["Done"], timeout: 3)

        XCTAssertEqual(app.cells.count, 1, "Expected number of tabs remaining is not correct")
        XCTAssertEqual(app.cells.firstMatch.label, "Home", "Expected label of remaining tab is not correct")
    }

    func testCloseAllIncognitoTabsFromSwitcher() {
        navigator.performAction(Action.TogglePrivateMode)
        navigator.nowAt(NewTabScreen)

        openTwoWebsites()
        navigator.goto(TabTray)

        waitForExistence(app.buttons["Done"], timeout: 3)
        app.buttons["Done"].press(forDuration: 3)

        waitForExistence(app.buttons["Close All Tabs"], timeout: 3)
        app.buttons["Close All Tabs"].tap()

        waitForExistence(app.buttons["Confirm Close All Tabs"], timeout: 3)
        app.buttons["Confirm Close All Tabs"].tap()

        waitForExistence(app.buttons["Done"], timeout: 3)
        navigator.nowAt(TabTray)

        navigator.performAction(Action.TogglePrivateMode)

        waitForExistence(app.buttons["Show Tabs"], timeout: 3)
        navigator.nowAt(NewTabScreen)

        navigator.goto(TabTray)
        waitForExistence(app.buttons["Done"], timeout: 3)

        XCTAssertEqual(app.cells.count, 1, "Expected number of tabs remaining is not correct")
        XCTAssertEqual(app.cells.firstMatch.label, "Home", "Expected label of remaining tab is not correct")
    }
}

fileprivate extension BaseTestCase {
    func openTwoWebsites() {
        // Open two tabs
        navigator.openURL(firstWebsite.url)
        waitForTabsButton()
        navigator.goto(TabTray)
        navigator.openURL(secondWebsite.url)
        waitUntilPageLoad()
        waitForTabsButton()
    }
}
