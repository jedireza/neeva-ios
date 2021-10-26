// Copyright Neeva. All rights reserved.

import Foundation
import XCTest

class ReaderModeTests: BaseTestCase {
    func goToReaderModeSite() {
        openURL(path(forTestPage: "test-mozilla-org.html"))
        waitUntilPageLoad()
        waitForExistence(app.buttons["Reader Mode"])
    }

    func enableReaderMode() {
        goToReaderModeSite()
        app.buttons["Reader Mode"].tap()
        waitUntilPageLoad()
    }

    func testReaderModeOptionDoesntExist() {
        openURL()
        waitUntilPageLoad()
        waitForNoExistence(app.buttons["Reader Mode"])
    }

    func testEnableReaderMode() {
        enableReaderMode()
        copyUrl()

        if let myString = UIPasteboard.general.string, let url = URL(string: myString) {
            XCTAssertEqual("/reader-mode/page", url.path)
        }
    }

    func testDisableReaderMode() {
        enableReaderMode()
        waitForExistence(app.buttons["Reading Mode Settings"])
        app.buttons["Reading Mode Settings"].tap()

        waitForExistence(app.buttons["Close Reading Mode"])
        app.buttons["Close Reading Mode"].tap()
        waitUntilPageLoad()

        copyUrl()

        if let myString = UIPasteboard.general.string, let url = URL(string: myString) {
            XCTAssertEqual("/test-fixture/test-mozilla-org.html", url.path)
        }
    }
}
