/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import XCTest

class SettingsTest: BaseTestCase {
    /* TODO: rewrite this test
    func testDefaultBrowser() {
        // A default browser card should be available on the home screen
        if #available(iOS 14, *) {
            waitForExistence(app.staticTexts["Open links in Neeva automatically by making it your Default Browser App."], timeout: 5)
            waitForExistence(app.buttons["Go to Settings"], timeout: 5)
            app.buttons["Go to Settings"].tap()

            // Tap on "Default Browser App" and set the browser as a default (Safari is listed first)
            waitForExistence(iOS_Settings.tables.buttons.element(boundBy: 1), timeout: 5)
            iOS_Settings.tables.buttons.element(boundBy: 1).tap()
            iOS_Settings.tables.staticTexts.element(boundBy: 1).tap()

            // Return to the browser
            app.activate()

            // Tap on "Set as Default Browser" from the in-browser settings
            navigator.goto(SettingsScreen)
            let settingsTableView = app.tables["AppSettingsTableViewController.tableView"]
            let defaultBrowserButton = settingsTableView.cells["Set as Default Browser"]
            defaultBrowserButton.tap()

            // Verify the browser is selected as a default in iOS settings
            waitForExistence(iOS_Settings.tables.buttons.element(boundBy: 1), timeout: 5)
            iOS_Settings.tables.buttons.element(boundBy: 1).tap()
            waitForExistence(iOS_Settings.tables.cells.buttons["checkmark"])
            XCTAssertFalse(iOS_Settings.tables.cells.buttons["checkmark"].isEnabled)
        }
    }
    */
}
