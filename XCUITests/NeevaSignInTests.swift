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

    func testSignInFromPromoCard() {
        XCTAssertNotNil(username)
        XCTAssertNotNil(password)

        waitForExistence(app.buttons["Sign in or Join Neeva"], timeout: 3)
        app.buttons["Sign in or Join Neeva"].tap()

        let textField = app.textFields.firstMatch
        XCTAssertEqual("Please enter your email address", textField.placeholderValue)

        UIPasteboard.general.string = username
        textField.tap()
        textField.press(forDuration: 2)
        app.menus.firstMatch.menuItems["Paste"].tap()

        waitForExistence(app.staticTexts["Sign in"], timeout: 3)
        app.staticTexts["Sign in"].tap()

        waitUntilPageLoad()
        waitForValueContains(app.buttons["url"], value: "https://login.neeva.com/")

        // Password field should already be focused
        UIPasteboard.general.string = password
        app.secureTextFields.firstMatch.press(forDuration: 2)
        app.menus.firstMatch.menuItems["Paste"].tap()

        waitForExistence(app.buttons["Sign In"], timeout: 3)
        app.buttons["Sign In"].tap()

        waitUntilPageLoad()
        waitForValueContains(app.buttons["url"], value: "https://neeva.com/")

        waitForExistence(app.buttons["Got it!"], timeout: 3)
        app.buttons["Got it!"].tap()

        // Sign out
        navigator.goto(SettingsScreen)

        waitForExistence(app.cells["Member, \(username!)"], timeout: 3)
        app.cells["Member, \(username!)"].tap()

        waitForExistence(app.buttons["Sign Out"], timeout: 3)
        app.buttons["Sign Out"].tap()

        waitForExistence(app.sheets.firstMatch.staticTexts["Sign out of Neeva?"], timeout: 3)
        waitForExistence(app.sheets.firstMatch.buttons["Sign Out"], timeout: 3)
        app.sheets.firstMatch.buttons["Sign Out"].tap()

        waitForExistence(app.cells["Sign In or Join Neeva"], timeout: 3)

        waitForExistence(app.navigationBars.buttons["Done"], timeout: 3)
        app.navigationBars.buttons["Done"].tap()

        // Reloading should bounce user to the marketing site.
        waitForExistence(app.buttons["Reload"], timeout: 3)
        app.buttons["Reload"].tap()

        waitUntilPageLoad()
        print(app.webViews.firstMatch.debugDescription)
        waitForExistence(app.webViews.links["Sign In"], timeout: 3)
    }
}
