// Copyright Neeva. All rights reserved.

import XCTest

class AuthenticationTests: BaseTestCase {
    let url = "https://jigsaw.w3.org/HTTP/Basic"

    func testIncorrectCredientials() {
        openURL(url, waitForPageLoad: false)

        // Make sure that 3 invalid credentials result in authentication failure.
        enterCredentials(username: "foo", password: "bar")
        enterCredentials(username: "foo2", password: "bar2")
        enterCredentials(username: "foo3", password: "bar3")
        waitForExistence(app.staticTexts["Unauthorized access"])
    }

    func testCorrectCredientials() {
        openURL(url, waitForPageLoad: false)

        enterCredentials(username: "guest", password: "guest")
        waitForExistence(app.staticTexts["Your browser made it!"])
    }

    fileprivate func enterCredentials(username: String, password: String) {
        waitForExistence(app.textFields["Auth_Username_Field"])
        app.textFields["Auth_Username_Field"].tap()
        app.textFields["Auth_Username_Field"].typeText(username + "\n")

        app.secureTextFields["Auth_Password_Field"].tap()
        app.secureTextFields["Auth_Password_Field"].typeText(username)

        app.buttons["Auth_Submit"].tap()
        waitForExistence(app.buttons["Show Tabs"])
    }
}
