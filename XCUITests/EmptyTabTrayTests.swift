// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Foundation

class EmptyTabTrayTests: BaseTestCase {
    override func setUp() {
        launchArguments.append(LaunchArguments.DontAddTabOnLaunch)

        super.setUp()
    }

    func openThreeTabs() {
        openURLInNewTab()
        openURLInNewTab()
        openURLInNewTab()
    }

    func testEmptyTabTrayShowsOnLaunch() {
        // Can assume no tabs are saved between tests
        waitForExistence(app.staticTexts["EmptyTabTray"], timeout: 30)
    }

    func testEmptyTabTrayShowsAfterClosingTab() {
        openURLInNewTab()
        closeAllTabs(createNewTab: false)

        waitForExistence(app.staticTexts["EmptyTabTray"])
    }

    func testEmptyTabTrayShowsAfterClosingTabFromTabTray() {
        openURLInNewTab()
        goToTabTray()

        app.buttons["Close"].tap()

        waitForExistence(app.staticTexts["EmptyTabTray"])
    }

    func testEmptyTabTrayShowsAfterClosingAllTabs() {
        openThreeTabs()
        closeAllTabs(createNewTab: false)

        waitForExistence(app.staticTexts["EmptyTabTray"])
    }

    func testEmptyTabTrayShowsAfterClosingAllTabsFromTabTray() {
        openThreeTabs()
        goToTabTray()
        closeAllTabs(fromTabSwitcher: true, createNewTab: false)

        waitForExistence(app.staticTexts["EmptyTabTray"])
    }

    /// Tests that when closing all incognito tabs, and no normal tabs exist that empty tab tray is shown
    func testEmptyTabTrayShowsAfterClosingAllIncognitoTabs() {
        setIncognitoMode(enabled: true)
        openThreeTabs()
        closeAllTabs(createNewTab: false)

        waitForExistence(app.staticTexts["EmptyTabTrayIncognito"])
    }

    func testEmptyTabTrayShowsAfterClosingAllIncognitoTabsFromTabTray() {
        setIncognitoMode(enabled: true)
        openThreeTabs()
        goToTabTray()
        closeAllTabs(fromTabSwitcher: true, createNewTab: false)

        waitForExistence(app.staticTexts["EmptyTabTrayIncognito"])
    }

    func testTabTrayShowsTabs() {
        openURLInNewTab()
        goToTabTray()
        waitForExistence(app.buttons["Example Domain, Tab"])
    }

    // https://github.com/neevaco/neeva-ios/issues/2595
    func testTabGroupWorksAfterClosingLastTab() {
        openURLInNewTab("https://example.com")

        waitForExistence(app.links["More information..."])
        app.links["More information..."].press(forDuration: 0.5)

        waitForExistence(app.buttons["Open in New Tab"])
        app.buttons["Open in New Tab"].tap()

        setIncognitoMode(enabled: true)
        openURLInNewTab("https://test.example/")
        goToTabTray()

        waitForExistence(app.buttons["Close"].firstMatch)
        app.buttons["Close"].firstMatch.tap(force: true)

        setIncognitoMode(enabled: false, closeTabTray: false)
        app.buttons["Example Domain, Tab Group"].tap()
        XCTAssert(app.buttons["Example Domain, Tab"].exists)
    }
}
