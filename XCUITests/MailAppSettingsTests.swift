/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import XCTest

class MailAppSettingsTests: BaseTestCase {
    func testOpenMailAppSettings() {
        navigator.goto(OpenWithSettings)

        // Check that the list is shown with all elements disabled
        waitForExistence(app.tables.staticTexts["OPEN MAIL LINKS WITH"])
        XCTAssertTrue(app.tables.staticTexts["OPEN MAIL LINKS WITH"].exists)
        XCTAssertFalse(app.tables.cells.buttons["Mail"].isSelected)
        XCTAssertFalse(app.tables.cells.buttons["Outlook"].isSelected)
        XCTAssertFalse(app.tables.cells.buttons["Airmail"].isSelected)
        XCTAssertFalse(app.tables.cells.buttons["Mail.Ru"].isSelected)
        XCTAssertFalse(app.tables.cells.buttons["myMail"].isSelected)
        XCTAssertFalse(app.tables.cells.buttons["Spark"].isSelected)
        XCTAssertFalse(app.tables.cells.buttons["YMail!"].isSelected)
        XCTAssertFalse(app.tables.cells.buttons["Gmail"].isSelected)

        // Check that tapping on an element does nothing
        app.tables.cells.buttons["Airmail"].tap()
        XCTAssertFalse(app.tables.cells.buttons["Airmail"].isSelected)

        // Check that user can go back from that setting
        navigator.nowAt(OpenWithSettings)
        navigator.back()
    }
}
