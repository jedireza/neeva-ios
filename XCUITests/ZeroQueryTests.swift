// Copyright Neeva. All rights reserved.

import Foundation

class ZeroQueryTests: BaseTestCase {
    func testZeroQueryURLNotSuggestedToEdit() {
        goToAddressBar()
        assert(app.buttons["Edit Current URL"].exists == false)
    }

    // Tests to be sure that hitting the cancel button on the URL bar
    // shows the zero query page (if it was open)
    // instead of showing a blank tab.
    func testCancelZeroQueryShowsZeroQuery() {
        waitForExistence(app.buttons["Suggested sites, expands this section"], timeout: 30)
        goToAddressBar()

        waitForExistence(app.buttons["Cancel"])
        app.buttons["Cancel"].tap()

        // confirms zero query is still showing
        waitForExistence(app.buttons["Suggested sites, expands this section"])
    }

    func testZeroQueryHidesAfterLoadingURL() {
        waitForExistence(app.buttons["Suggested sites, expands this section"], timeout: 30)
        openURL()

        waitForNoExistence(app.buttons["Suggested sites, expands this section"])
    }

    func testZeroQueryHidesOnOpenPage() {
        waitForExistence(app.buttons["Suggested sites, expands this section"], timeout: 30)
        openURL()
        goToAddressBar()

        waitForExistence(app.buttons["Cancel"])
        app.buttons["Cancel"].tap()

        waitForNoExistence(app.buttons["Suggested sites, expands this section"])
        assert(app.staticTexts["Example Domain"].exists)
    }
}
