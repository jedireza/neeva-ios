// Copyright Neeva. All rights reserved.

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
        waitForExistence(app.images["EmptyTabTray"], timeout: 30)
    }

    func testEmptyTabTrayShowsAfterClosingTab() {
        openURLInNewTab()
        closeAllTabs(createNewTab: false)

        waitForExistence(app.images["EmptyTabTray"])
    }

    func testEmptyTabTrayShowsAfterClosingTabFromTabTray() {
        openURLInNewTab()
        goToTabTray()

        app.buttons["Close Example Domain"].tap()

        waitForExistence(app.images["EmptyTabTray"])
    }

    func testEmptyTabTrayShowsAfterClosingAllTabs() {
        openThreeTabs()
        closeAllTabs(createNewTab: false)

        waitForExistence(app.images["EmptyTabTray"])
    }

    func testEmptyTabTrayShowsAfterClosingAllTabsFromTabTray() {
        openThreeTabs()
        goToTabTray()
        closeAllTabs(fromTabSwitcher: true, createNewTab: false)

        waitForExistence(app.images["EmptyTabTray"])
    }

    /// Tests that when closing all incognito tabs, and no normal tabs exist that empty tab tray is shown
    func testEmptyTabTrayShowsAfterClosingAllIncognitoTabs() {
        toggleIncognito()
        openThreeTabs()
        closeAllTabs(createNewTab: false)

        waitForExistence(app.images["EmptyTabTray"])
    }

    func testEmptyTabTrayShowsAfterClosingAllIncognitoTabsFromTabTray() {
        toggleIncognito()
        openThreeTabs()
        goToTabTray()
        closeAllTabs(fromTabSwitcher: true, createNewTab: false)

        waitForExistence(app.images["EmptyTabTray"])
    }

    func testTabTrayShowsTabs() {
        openURLInNewTab()
        goToTabTray()
        waitForExistence(app.buttons["Example Domain, Tab"])
    }
}
