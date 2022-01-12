// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import XCTest

private let firstWebsite = (
    url: path(forTestPage: "test-mozilla-org.html"),
    tabName: "Internet for people, not profit — Mozilla, Tab"
)
private let secondWebsite = (
    url: path(forTestPage: "test-mozilla-book.html"), tabName: "The Book of Mozilla"
)

class TabMenuTests: BaseTestCase {
    override func setUp() {
        launchArguments.append(LaunchArguments.DontAddTabOnLaunch)
        super.setUp()
    }

    func testCloseNormalTabFromTab() {
        openURL(firstWebsite.url)
        openURLInNewTab(secondWebsite.url)

        waitForExistence(app.buttons["Show Tabs"], timeout: 3)
        app.buttons["Show Tabs"].press(forDuration: 1)

        waitForExistence(app.buttons["Close Tab"], timeout: 3)
        app.buttons["Close Tab"].tap()

        XCTAssertEqual(getNumberOfTabs(), 1, "Expected number of tabs remaining is not correct")
    }

    func testCloseAllNormalTabsFromTab() {
        openURL(firstWebsite.url)
        openURLInNewTab(secondWebsite.url)
        closeAllTabs(createNewTab: false)

        waitForExistence(app.images["EmptyTabTray"])
    }

    func testCloseIncognitoTabFromTab() {
        setIncognitoMode(enabled: true)
        openURLInNewTab(secondWebsite.url)

        waitForExistence(app.buttons["Show Tabs"], timeout: 3)
        app.buttons["Show Tabs"].press(forDuration: 1)

        waitForExistence(app.buttons["Close Tab"], timeout: 3)
        app.buttons["Close Tab"].tap()

        XCTAssertEqual(getNumberOfTabs(), 1, "Expected number of tabs remaining is not correct")
    }

    func testCloseAllIncognitoTabsFromTab() {
        setIncognitoMode(enabled: true)
        openURLInNewTab(secondWebsite.url)

        closeAllTabs(createNewTab: false)
        setIncognitoMode(enabled: false, shouldOpenURL: false, closeTabTray: false)

        XCTAssertEqual(
            getNumberOfTabs(openTabTray: false), 0,
            "Expected number of tabs remaining is not correct")
    }

    func testCloseAllNormalTabsFromSwitcher() {
        openURL(firstWebsite.url)
        openURLInNewTab(secondWebsite.url)
        goToTabTray()

        closeAllTabs(fromTabSwitcher: true, createNewTab: false)
        waitForExistence(app.images["EmptyTabTray"])
    }

    func testCloseAllIncognitoTabsFromSwitcher() {
        setIncognitoMode(enabled: true)
        openURLInNewTab(secondWebsite.url)
        closeAllTabs(createNewTab: false)
        setIncognitoMode(enabled: false, shouldOpenURL: false, closeTabTray: false)

        XCTAssertEqual(
            getNumberOfTabs(openTabTray: false), 0,
            "Expected number of tabs remaining is not correct")
    }
}
