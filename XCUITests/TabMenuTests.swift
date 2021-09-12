// Copyright Neeva. All rights reserved.

import XCTest

private let firstWebsite = (
    url: path(forTestPage: "test-mozilla-org.html"),
    tabName: "Internet for people, not profit — Mozilla, Tab"
)
private let secondWebsite = (
    url: path(forTestPage: "test-mozilla-book.html"), tabName: "The Book of Mozilla"
)

class TabMenuTests: BaseTestCase {
    func testCloseNormalTabFromTab() {
        openURL(firstWebsite.url)
        openURLInNewTab(secondWebsite.url)

        waitForExistence(app.buttons["Show Tabs"], timeout: 3)
        app.buttons["Show Tabs"].press(forDuration: 1)

        waitForExistence(app.buttons["Close Tab"], timeout: 3)
        app.buttons["Close Tab"].tap()

        goToTabTray()

        XCTAssertEqual(getTabs().count, 1, "Expected number of tabs remaining is not correct")
        XCTAssertEqual(
            getTabs().firstMatch.label, firstWebsite.tabName,
            "Expected label of remaining tab is not correct")
    }

    func testCloseAllNormalTabsFromTab() {
        openURL(firstWebsite.url)
        openURLInNewTab(secondWebsite.url)
        closeAllTabs(createNewTab: false)

        waitForExistence(app.images["EmptyTabTray"])
    }

    func testCloseIncognitoTabFromTab() {
        toggleIncognito()
        openURLInNewTab(secondWebsite.url)

        waitForExistence(app.buttons["Show Tabs"], timeout: 3)
        app.buttons["Show Tabs"].press(forDuration: 1)

        waitForExistence(app.buttons["Close Tab"], timeout: 3)
        app.buttons["Close Tab"].tap()

        goToTabTray()

        XCTAssertEqual(getTabs().count, 1, "Expected number of tabs remaining is not correct")
        XCTAssertEqual(
            getTabs().firstMatch.label, "Example Domain, Tab",
            "Expected label of remaining tab is not correct")
    }

    func testCloseAllIncognitoTabsFromTab() {
        toggleIncognito()
        openURLInNewTab(secondWebsite.url)

        closeAllTabs(createNewTab: false)
        goToTabTray()

        XCTAssertEqual(getTabs().count, 1, "Expected number of tabs remaining is not correct")
        XCTAssertEqual(
            getTabs().firstMatch.label, "Home, Tab",
            "Expected label of remaining tab is not correct")
    }

    func testCloseAllNormalTabsFromSwitcher() {
        openURL(firstWebsite.url)
        openURLInNewTab(secondWebsite.url)
        goToTabTray()

        closeAllTabs(fromTabSwitcher: true, createNewTab: false)
        waitForExistence(app.images["EmptyTabTray"])
    }

    func testCloseAllIncognitoTabsFromSwitcher() {
        openURL()
        toggleIncognito()
        openURLInNewTab(secondWebsite.url)
        goToTabTray()

        closeAllTabs(fromTabSwitcher: true, createNewTab: false)

        waitForExistence(app.buttons["Example Domain, Tab"])
        XCTAssertEqual(getTabs().count, 1, "Expected number of tabs remaining is not correct")
    }
}
