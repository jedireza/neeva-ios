// Copyright Neeva. All rights reserved.

import XCTest

extension BaseTestCase {
    /// Launches from tab page
    func goToSettings() {
        app.buttons["Neeva Menu"].tap()
        app.buttons["Settings"].tap()
        waitForExistence(app.tables.cells["Show Search Suggestions"])
    }

    /// Lauches from tab page
    func goToFindOnPage() {
        app.buttons["Share"].tap()
        app.buttons["Find on Page"].tap()
    }

    /// Launches from tab page
    func goToTabTray() {
        waitForExistence(app.buttons["Show Tabs"])
        app.buttons["Show Tabs"].tap()

        waitForExistence(app.buttons["Done"], timeout: 3)
    }

    /// Launches from tab page, then opens settings
    func goToClearData() {
        goToSettings()
        app.tables.cells["Clear Browsing Data"].tap()
    }

    /// Launches from tab page
    func goToHistory() {
        app.buttons["Neeva Menu"].tap()

        waitForExistence(app.buttons["History"])
        app.buttons["History"].tap()
    }

    /// Launches from tab page, then opens history
    func goToRecentlyClosedPage() {
        goToHistory()

        waitForExistence(app.tables.cells["Recently Closed"])
        app.tables.cells["Recently Closed"].tap()
    }
}
