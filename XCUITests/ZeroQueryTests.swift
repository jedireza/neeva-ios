// Copyright Neeva. All rights reserved.

import Foundation

class ZeroQueryTests: BaseTestCase {
    func testZeroQueryHidesAfterLoadingURL() {
        newTab()

        waitForExistence(app.buttons["Suggested sites, expands this section"], timeout: 30)
        openURL()

        waitForNoExistence(app.buttons["Suggested sites, expands this section"])
    }

    func testZeroQueryHidesOnOpenPage() {
        newTab()

        waitForExistence(app.buttons["Suggested sites, expands this section"], timeout: 30)
        openURL()

        goToAddressBar()
        waitForExistence(app.buttons["Cancel"])
        app.buttons["Cancel"].tap()

        waitForNoExistence(app.buttons["Suggested sites, expands this section"])
        assert(app.staticTexts["Example Domain"].exists)
    }
}
