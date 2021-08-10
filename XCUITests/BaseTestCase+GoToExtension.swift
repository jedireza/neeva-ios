// Copyright Neeva. All rights reserved.

import XCTest

extension BaseTestCase {
    /// Launches from tab page
    func goToSettings() {
        waitForExistence(app.buttons["Neeva Menu"])
        app.buttons["Neeva Menu"].tap()

        waitForExistence(app.buttons["Settings"])
        app.buttons["Settings"].tap()

        waitForExistence(app.tables.cells["Show Search Suggestions"])
    }

    /// Lauches from tab page
    func goToFindOnPage() {
        waitForExistence(app.buttons["Share"])
        app.buttons["Share"].tap(force: true)

        waitForExistence(app.buttons["Find on Page"])
        app.buttons["Find on Page"].tap()

        waitForExistence(app.textFields["FindInPage_TextField"])
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

        waitForExistence(app.tables.cells["Clear Browsing Data"])
        app.tables.cells["Clear Browsing Data"].tap()
    }

    /// Launches from tab page
    func goToHistory() {
        waitForExistence(app.buttons["Neeva Menu"])
        app.buttons["Neeva Menu"].tap()

        waitForExistence(app.buttons["Settings"])

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
