// Copyright Neeva. All rights reserved.

import XCTest

extension BaseTestCase {
    /// Launches from anywhere the URL bar is visible
    func goToAddressBar() {
        waitForExistence(app.buttons["Address Bar"], timeout: 30)
        
        if app.buttons["Cancel"].exists {
            app.textFields["address"].tap()
        } else {
            app.buttons["Address Bar"].tap()
        }
    }

    /// Launches from tab page
    func goToSettings() {
        waitForExistence(app.buttons["Neeva Menu"])
        app.buttons["Neeva Menu"].tap(force: true)

        waitForExistence(app.buttons["Settings"])
        app.buttons["Settings"].tap()

        waitForExistence(app.tables.cells["Show Search Suggestions"])
    }

    /// Lauches from tab page
    func goToFindOnPage() {
        goToOverflowMenuButton(label: "Find on Page", shouldDismissOverlay: false) { element in
            element.tap()
        }

        waitForExistence(app.textFields["FindInPage_TextField"])
    }

    /// Launches from tab page
    func goToTabTray() {
        waitForExistence(app.buttons["Show Tabs"], timeout: 30)
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
        app.buttons["Neeva Menu"].tap(force: true)

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

    /// Launches from tab page, then opens the overflow menu
    func goToOverflowMenu() {
        waitForExistence(app.buttons["More"], timeout: 30)
        app.buttons["More"].tap(force: true)

        waitForExistence(app.buttons["New Tab"])
    }

    /// Launches overflow menu and interact with a button
    func goToOverflowMenuButton(
        label: String,
        shouldDismissOverlay: Bool = true,
        action: (XCUIElement) -> Void
    ) {
        app.buttons["More"].tap(force: true)
        waitForExistence(app.buttons[label])
        action(app.buttons[label])
        if shouldDismissOverlay {
            if iPad() {
                tapCoordinate(at: 1, and: 100)
            } else {
                tapCoordinate(at: 5, and: 50)
            }
        }
    }
}
