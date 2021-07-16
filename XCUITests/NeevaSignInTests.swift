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

        waitForExistence(app.buttons["Sign in or Join Neeva"])
        app.buttons["Sign in or Join Neeva"].tap()

        let textField = app.textFields.firstMatch
        XCTAssertEqual("Please enter your email address", textField.placeholderValue)

        UIPasteboard.general.string = username
        textField.tap()
        textField.press(forDuration: 2)
        app.menus.firstMatch.menuItems["Paste"].tap()

        waitForExistence(app.staticTexts["Sign in"])
        app.staticTexts["Sign in"].tap()

        waitUntilPageLoad()
        waitForValueContains(app.buttons["Address Bar"], value: "https://login.neeva.com/")

        // Password field should already be focused
        UIPasteboard.general.string = password
        app.secureTextFields.firstMatch.press(forDuration: 2)
        app.menus.firstMatch.menuItems["Paste"].tap()

        waitForExistence(app.buttons["Sign In"])
        app.buttons["Sign In"].tap()

        waitUntilPageLoad()
        print(app.buttons["Address Bar"].value.debugDescription)
        waitForValueContains(app.buttons["Address Bar"], value: "https://neeva.com/")
        print(app.buttons["Address Bar"].value.debugDescription)

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

        // Reloading should bounce user to the marketing site.
        waitForExistence(app.buttons["Reload"])
        app.buttons["Reload"].tap()

        waitUntilPageLoad()
        waitForExistence(app.webViews.links["Sign In"])
    }
}
