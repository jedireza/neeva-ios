// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

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

    func testRemoveItemFromSuggestedSites() {
        newTab()

        waitForExistence(app.buttons["Facebook"], timeout: 30)
        app.buttons["Facebook"].press(forDuration: 1)
        waitForExistence(app.buttons["Remove"])
        app.buttons["Remove"].tap()

        // Confirm on the ActionSheet
        waitForExistence(app.buttons["Remove"])
        app.buttons["Remove"].tap()

        // Make sure Facebook was removed
        waitForNoExistence(app.buttons["Facebook"])
    }
}
