// Copyright Neeva. All rights reserved.

import Foundation
import XCTest

class NeevaSignInTests: BaseTestCase {
    var username: String?
    var password: String?

    override func setUp() {
        username = ProcessInfo.processInfo.environment["TEST_ACCOUNT_USERNAME"]
        password = ProcessInfo.processInfo.environment["TEST_ACCOUNT_PASSWORD"]

        XCTAssertNotNil(username)
        XCTAssertNotNil(password)

        // These are set by our test environment on CircleCI. If you want to run the
        // tests manually, you will need to edit the Schema to define these variables.
        XCTAssertNotEqual(username, "", "TEST_ACCOUNT_USERNAME environment variable not set!")
        XCTAssertNotEqual(password, "", "TEST_ACCOUNT_PASSWORD environment variable not set!")

        // For this test, preset a junk login cookie.
        if testName == "testSignInWithStaleLoginCookie" {
            launchArguments.append("\(LaunchArguments.SetLoginCookie)foobar")
        }

        super.setUp()
    }

    fileprivate func waitUntilPageLoad(withUrlContaining urlSubstring: String) {
        waitUntilPageLoad()

        // TODO(darin): Flakiness alert! Set an extra long timeout here as `waitForPageLoad()`
        // does not always result in the URL being updated immediately, suggesting that there
        // is perhaps an ordering issue between when we stop the progress bar from animating
        // and when the URL gets updated. That is worth investigating and resolving, so that
        // tests involving navigation can be more reliable.
        waitForValueContains(app.buttons["Address Bar"], value: urlSubstring, timeout: 60.0)

        // Print out this value to help debug test flakiness.
        print("Address Bar:", app.buttons["Address Bar"].value.debugDescription)
    }

    fileprivate func doSignIn() {
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

        // Expect first run dialog.
        waitForExistence(app.buttons["Got it!"])
        app.buttons["Got it!"].tap()
    }

    fileprivate func doSignOut() {
        goToSettings()

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

    func testSignInFromPromoCard() {
        waitForExistence(app.buttons["Sign in or Join Neeva"])
        app.buttons["Sign in or Join Neeva"].tap()

        waitUntilPageLoad(withUrlContaining: "https://neeva.com/signin")

        doSignIn()
        doSignOut()
    }

    func testSignInFromSettings() {
        goToSettings()

        waitForExistence(app.cells["Sign In or Join Neeva"])
        app.cells["Sign In or Join Neeva"].tap()

        waitUntilPageLoad(withUrlContaining: "https://neeva.com/signin")

        doSignIn()
        doSignOut()
    }

    func testSignInWithStaleLoginCookie() {
        // See the setUp() function where the stale login cookie is specified
        // as a launch argument to the browser.

        // Load neeva.com, and we should get redirected to the sign in page.
        openURL("https://neeva.com/")
        waitUntilPageLoad(withUrlContaining: "https://neeva.com/signin")

        doSignIn()
        doSignOut()
    }
}
