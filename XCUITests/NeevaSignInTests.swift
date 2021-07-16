// Copyright Neeva. All rights reserved.

import Foundation
import XCTest

class NeevaSignInTests: BaseTestCase {
    var username: String?
    var password: String?

    override func setUp() {
        username = ProcessInfo.processInfo.environment["TEST_ACCOUNT_USERNAME"]
        password = ProcessInfo.processInfo.environment["TEST_ACCOUNT_PASSWORD"]
        super.setUp()
    }

    fileprivate func waitUntilPageLoad(withUrlContaining: String) {
        waitUntilPageLoad()

        // TODO(darin): Flakiness alert! Set an extra long timeout here as `waitForPageLoad()`
        // does not always result in the URL being updated immediately, suggesting that there
        // is perhaps an ordering issue between when we stop the progress bar from animating
        // and when the URL gets updated. That is worth investigating and resolving, so that
        // tests involving navigation can be more reliable.
        waitForValueContains(app.buttons["Address Bar"], value: withUrlContaining, timeout: 30.0)
    }

    func testSignInFromPromoCard() {
        XCTAssertNotNil(username)
        XCTAssertNotNil(password)

        waitForExistence(app.buttons["Sign in or Join Neeva"])
        app.buttons["Sign in or Join Neeva"].tap()

        waitUntilPageLoad(withUrlContaining: "https://neeva.com/signin")

        let textField = app.textFields.firstMatch
        XCTAssertEqual("Please enter your email address", textField.placeholderValue)

        UIPasteboard.general.string = username
        textField.tap()
        textField.press(forDuration: 2)
        app.menus.firstMatch.menuItems["Paste"].tap()

        waitForExistence(app.staticTexts["Sign in"])
        app.staticTexts["Sign in"].tap()

        waitUntilPageLoad(withUrlContaining: "https://login.neeva.com/")

        // Password field should already be focused
        UIPasteboard.general.string = password
        app.secureTextFields.firstMatch.press(forDuration: 2)
        app.menus.firstMatch.menuItems["Paste"].tap()

        waitForExistence(app.buttons["Sign In"])
        app.buttons["Sign In"].tap()

        waitUntilPageLoad(withUrlContaining: "https://neeva.com/")

        waitForExistence(app.buttons["Got it!"])
        app.buttons["Got it!"].tap()

        // Sign out
        navigator.goto(SettingsScreen)

        waitForExistence(app.cells["Member, \(username!)"])
        app.cells["Member, \(username!)"].tap()

        waitForExistence(app.buttons["Sign Out"])
        app.buttons["Sign Out"].tap()

        waitForExistence(app.sheets.firstMatch.staticTexts["Sign out of Neeva?"])
        waitForExistence(app.sheets.firstMatch.buttons["Sign Out"])
        app.sheets.firstMatch.buttons["Sign Out"].tap()

        waitForExistence(app.cells["Sign In or Join Neeva"])

        waitForExistence(app.navigationBars.buttons["Done"])
        app.navigationBars.buttons["Done"].tap()

        // Reload to ensure we are bounced to the marketing site.
        waitForExistence(app.buttons["Reload"])
        app.buttons["Reload"].tap()

        waitUntilPageLoad(withUrlContaining: "https://neeva.com/")
        waitForExistence(app.webViews.links["Sign In"])
    }

    func testSignInFromSettings() {
        XCTAssertNotNil(username)
        XCTAssertNotNil(password)

        navigator.goto(SettingsScreen)

        waitForExistence(app.cells["Sign In or Join Neeva"])
        app.cells["Sign In or Join Neeva"].tap()

        waitUntilPageLoad(withUrlContaining: "https://neeva.com/signin")

        let textField = app.textFields.firstMatch
        XCTAssertEqual("Please enter your email address", textField.placeholderValue)

        UIPasteboard.general.string = username
        textField.tap()
        textField.press(forDuration: 2)
        app.menus.firstMatch.menuItems["Paste"].tap()

        waitForExistence(app.staticTexts["Sign in"])
        app.staticTexts["Sign in"].tap()

        waitUntilPageLoad(withUrlContaining: "https://login.neeva.com/")

        // Password field should already be focused
        UIPasteboard.general.string = password
        app.secureTextFields.firstMatch.press(forDuration: 2)
        app.menus.firstMatch.menuItems["Paste"].tap()

        waitForExistence(app.buttons["Sign In"])
        app.buttons["Sign In"].tap()

        waitUntilPageLoad(withUrlContaining: "https://neeva.com/")

        waitForExistence(app.buttons["Got it!"])
        app.buttons["Got it!"].tap()

        // Sign out
        navigator.nowAt(BrowserTab)
        navigator.goto(SettingsScreen)

        waitForExistence(app.cells["Member, \(username!)"])
        app.cells["Member, \(username!)"].tap()

        waitForExistence(app.buttons["Sign Out"])
        app.buttons["Sign Out"].tap()

        waitForExistence(app.sheets.firstMatch.staticTexts["Sign out of Neeva?"])
        waitForExistence(app.sheets.firstMatch.buttons["Sign Out"])
        app.sheets.firstMatch.buttons["Sign Out"].tap()

        waitForExistence(app.cells["Sign In or Join Neeva"])

        waitForExistence(app.navigationBars.buttons["Done"])
        app.navigationBars.buttons["Done"].tap()

        // Reload to ensure we are bounced to the marketing site.
        waitForExistence(app.buttons["Reload"])
        app.buttons["Reload"].tap()

        waitUntilPageLoad(withUrlContaining: "https://neeva.com/")
        waitForExistence(app.webViews.links["Sign In"])
    }
}
