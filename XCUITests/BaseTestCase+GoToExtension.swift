// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

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

    func showAppNavigationMenu(for button: String) {
        if app.buttons["SwitcherOverflowButton"].exists {
            waitForHittable(app.buttons["SwitcherOverflowButton"])
            app.buttons["SwitcherOverflowButton"].tap()
        } else if app.buttons["Neeva Menu"].exists {
            app.buttons["Neeva Menu"].tap(force: true)
        } else if app.buttons["More"].exists {
            app.buttons["More"].tap(force: true)
        } else {
            XCTFail("Cannot find tap target for menu to access \(button)")
        }
        waitForExistence(app.buttons[button])
    }

    /// Launches from tab page
    func goToSettings() {
        showAppNavigationMenu(for: "Settings")
        app.buttons["Settings"].tap(force: true)

        waitForExistence(app.tables.cells["Show Search Suggestions"])
    }

    /// Lauches from tab page
    func goToFindOnPage() {
        goToOverflowMenuButton(label: "Find on Page", shouldDismissOverlay: false) { element in
            element.tap(force: true)
        }

        waitForExistence(app.textFields["FindInPage_TextField"])
    }

    /// Launches from tab page
    func goToTabTray() {
        waitForExistence(app.buttons["Show Tabs"], timeout: 30)
        app.buttons["Show Tabs"].tap()

        waitForExistence(app.buttons["Done"], timeout: 30)
    }

    /// Launches from tab page, then opens settings
    func goToClearData() {
        goToSettings()

        waitForExistence(app.tables.cells["Clear Browsing Data"])
        app.tables.cells["Clear Browsing Data"].tap()
    }

    /// Launches from tab page
    func goToHistory() {
        showAppNavigationMenu(for: "History")
        app.buttons["History"].tap(force: true)
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
        waitForExistence(app.buttons["More"])
        app.buttons["More"].tap(force: true)
        waitForExistence(app.buttons[label], timeout: 30)
        action(app.buttons[label])

        if shouldDismissOverlay {
            tapCoordinate(at: 5, and: 100)
            waitForExistence(app.buttons["More"])
        }
    }

    /// Launches share sheet from URL bar
    func goToShareSheet() {
        waitForExistence(app.buttons["Share"])
        app.buttons["Share"].tap()
    }
}
