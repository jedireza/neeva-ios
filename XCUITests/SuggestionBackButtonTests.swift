// Copyright Neeva. All rights reserved.

import XCTest

class SuggestionBackButtonTests: BaseTestCase {
    override func setUp() {
        if testName == "testSuggestionBackButtonEnabledFromCardGrid" {
            launchArguments.append(LaunchArguments.DontAddTabOnLaunch)
        }
        super.setUp()
    }

    private func performSearch() {
        app.typeText("example.com")
        app.typeText("\r")

        waitForExistence(app.buttons["Back"])
    }

    /// Make sure back button can be tapped after searching from Card Grid.
    /// Also tests if tapping the back button works and shows the Suggest UI.
    func testSuggestionBackButtonEnabledFromCardGrid() {
        // Create new tab, and perform a search
        newTab()
        performSearch()

        // Go back to Suggest UI
        app.buttons["Back"].tap()

        waitForExistence(app.buttons["Cancel"])
        XCTAssertTrue(app.staticTexts["example.com"].exists)
    }

    func testSuggestionBackButtonEnabledFromURLBar() {
        goToAddressBar()
        performSearch()

        XCTAssertTrue(app.buttons["Back"].exists)
    }

    func testSuggestionBackButtonDisabled() {
        openURLInNewTab()

        waitForExistence(app.buttons["Back"])
        XCTAssertFalse(app.buttons["Back"].isEnabled)
    }
}
