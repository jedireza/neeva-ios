// Copyright Neeva. All rights reserved.

import XCTest

extension BaseTestCase {
    /// Launches from tab page, or runs if already in tab tray.
    /// Switches between incognito modes by clicking incognito button
    func toggleIncognito(
        urlToOpen: String = "example.com", shouldOpenURL: Bool = true, closeTabTray: Bool = true
    ) {
        if !app.buttons["Incognito Mode"].exists {
            goToTabTray()
        }

        app.buttons["Incognito Mode"].tap()

        if app.buttons["Cancel"].exists && shouldOpenURL {
            openURL(urlToOpen)
        }

        if app.buttons["Done"].exists && app.buttons["Done"].isHittable && closeTabTray {
            app.buttons["Done"].tap()
        }
    }

    /// Reloads the page from the Overflow Menu
    func reloadPage() {
        if !iPad() {
            goToOverflowMenuButton(label: "Reload") { button in
                button.tap()
            }
        } else {
            app.buttons["Reload"].tap()
        }
    }

    /// Launches from tab page, switches to desktop site from Overflow Menu
    func requestDesktopSite() {
        goToOverflowMenuButton(label: "Request Desktop Site") { button in
            button.tap()
        }
    }

    /// Launches from tab page, switches to mobile site from Overflow Menu
    func requestMobileSite() {
        goToOverflowMenuButton(label: "Request Mobile Site") { button in
            button.tap()
        }
    }

    /// Launches from tab page, ends on tab page
    func clearPrivateData(fromTab: Bool = true) {
        if fromTab {
            goToClearData()
        }

        app.cells["Clear Selected Data on This Device"].tap()

        waitForExistence(app.buttons["Clear Data"])
        app.buttons["Clear Data"].tap()
        waitForNoExistence(app.buttons["Clear Data"])

        // close settings
        app.buttons["Settings"].tap()

        waitForExistence(app.buttons["Done"])
        app.buttons["Done"].tap()
    }

    /// Launches from tab page, ends with the URL bar focused and the URL as the query
    func editCurrentURL() {
        waitForExistence(app.buttons["Address Bar"])
        app.buttons["Address Bar"].tap()

        waitForExistence(app.buttons["Edit Current Address"])
        app.buttons["Edit Current Address"].tap()
    }

    /// Go forward to next visited web site
    func goForward() {
        if !iPad() {
            goToOverflowMenuButton(label: "Forward") { element in
                element.tap()
            }
        } else {
            app.buttons["Forward"].tap()
        }
    }
}
