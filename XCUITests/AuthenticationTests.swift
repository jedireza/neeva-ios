// Copyright Neeva. All rights reserved.

import XCTest

class AuthenticationTests: BaseTestCase {
    let url = "https://jigsaw.w3.org/HTTP/Basic"

    func testIncorrectCredentials() throws {
        try skipTest(issue: 1958, "this test is flaky")

        openURL(url, waitForPageLoad: false)

        // Make sure that 3 invalid credentials result in authentication failure.
        enterCredentials(username: "foo", password: "bar")
        enterCredentials(username: "foo2", password: "bar2")
        enterCredentials(username: "foo3", password: "bar3")
        waitForExistence(app.staticTexts["Unauthorized access"])
    }

    func testCorrectCredentials() throws {
        try skipTest(issue: 1755, "this test is flaky")

        openURL(url, waitForPageLoad: false)

        enterCredentials(username: "guest", password: "guest")
        waitForExistence(app.staticTexts["Your browser made it!"])
    }

    private func enterCredentials(username: String, password: String) {
        enter(text: username, in: "Auth_Username_Field")
        enter(text: password, in: "Auth_Password_Field", isSecure: true)

        waitForExistence(app.buttons["Auth_Submit"])
        app.buttons["Auth_Submit"].tap()
        waitForExistence(app.buttons["Show Tabs"])
    }

    private func enter(text: String, in field: String, isSecure: Bool = false) {
        UIPasteboard.general.string = text

        if isSecure {
            waitForExistence(app.secureTextFields[field])
            app.secureTextFields[field].tap()
            app.secureTextFields[field].press(forDuration: 1)
        } else {
            waitForExistence(app.textFields[field])
            app.textFields[field].tap()
            app.textFields[field].press(forDuration: 1)
        }

        waitForExistence(app.menuItems["Paste"])
        app.menuItems["Paste"].tap()
    }
}
