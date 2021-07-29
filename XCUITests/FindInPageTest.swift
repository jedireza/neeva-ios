/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import XCTest

class FindInPageTests: BaseTestCase {
    private func openFindInPageFromMenu(
        _ url: String = "http://localhost:\(serverPort)/test-fixture/find-in-page-test.html"
    ) {
        openURL(url)
        goToFindOnPage()

        waitForExistence(app.buttons["FindInPage.find_next"], timeout: 5)
        waitForExistence(app.buttons["FindInPage.find_previous"], timeout: 5)
        XCTAssertTrue(app.textFields["FindInPage.searchField"].exists)
    }

    func testFindInLargeDoc() {
        openFindInPageFromMenu()

        // Enter some text to start finding
        app.textFields["FindInPage.searchField"].typeText("Book")
        waitForExistence(app.textFields["Book"], timeout: 15)

        XCTAssertEqual(
            app.staticTexts["FindInPage.matchCount"].label, "1/500+",
            "The book word count does match")
    }

    // Smoketest
    func testFindFromMenu() {
        openFindInPageFromMenu(path(forTestPage: "test-mozilla-book.html"))

        // Enter some text to start finding
        app.textFields["FindInPage.searchField"].typeText("Book")

        // Once there are matches, test previous/next buttons
        waitForExistence(app.staticTexts["1/6"])
        XCTAssertTrue(app.staticTexts["1/6"].exists)

        let nextInPageResultButton = app.buttons["FindInPage.find_next"]
        nextInPageResultButton.tap()
        waitForExistence(app.staticTexts["2/6"])
        XCTAssertTrue(app.staticTexts["2/6"].exists)

        nextInPageResultButton.tap()
        waitForExistence(app.staticTexts["3/6"])
        XCTAssertTrue(app.staticTexts["3/6"].exists)

        let previousInPageResultButton = app.buttons["FindInPage.find_previous"]
        previousInPageResultButton.tap()

        waitForExistence(app.staticTexts["2/6"])
        XCTAssertTrue(app.staticTexts["2/6"].exists)

        previousInPageResultButton.tap()
        waitForExistence(app.staticTexts["1/6"])
        XCTAssertTrue(app.staticTexts["1/6"].exists)

        // Tapping on close dismisses the search bar
        app.buttons["Done"].tap()
        waitForNoExistence(app.textFields["Book"])
    }

    func testFindInPageTwoWordsSearch() {
        openFindInPageFromMenu(path(forTestPage: "test-mozilla-book.html"))

        // Enter some text to start finding
        app.textFields["FindInPage.searchField"].typeText("The Book of")

        // Once there are matches, test previous/next buttons
        waitForExistence(app.staticTexts["1/6"])
        XCTAssertTrue(app.staticTexts["1/6"].exists)
    }

    func testFindInPageTwoWordsSearchLargeDoc() {
        openFindInPageFromMenu()

        app.textFields["FindInPage.searchField"].typeText("The Book of")
        waitForExistence(app.textFields["The Book of"], timeout: 15)
        XCTAssertEqual(
            app.staticTexts["FindInPage.matchCount"].label, "1/500+",
            "The book word count does match")
    }

    func testFindInPageResultsPageShowHideContent() {
        openFindInPageFromMenu("lorem2.com")

        // Enter some text to start finding
        app.textFields["FindInPage.searchField"].typeText("lorem")

        // There should be matches
        waitForExistence(app.staticTexts["1/5"])
        XCTAssertTrue(app.staticTexts["1/5"].exists)
    }

    func testQueryWithNoMatches() {
        openFindInPageFromMenu(path(forTestPage: "test-mozilla-book.html"))

        // Try to find text which does not match and check that there are not results
        app.textFields["FindInPage.searchField"].typeText("foo")
        waitForExistence(app.staticTexts["0/0"])
        XCTAssertTrue(app.staticTexts["0/0"].exists, "There should not be any matches")
    }

    func testBarDissapearsWhenReloading() {
        openFindInPageFromMenu(path(forTestPage: "test-mozilla-book.html"))

        // Before reloading, it is necessary to hide the keyboard
        app.buttons["Address Bar"].tap()
        app.textFields["address"].typeText("\n")

        // Once the page is reloaded the search bar should not appear
        waitForNoExistence(app.textFields[""])
        XCTAssertFalse(app.textFields[""].exists)
    }

    /* TODO Restore Test #1159
    func testBarDissapearsWhenOpeningTabsTray() {
        openFindInPageFromMenu(path(forTestPage: "test-mozilla-book.html"))

        // Dismiss keyboard
        app.buttons["FindInPage.close"].tap()
        app.buttons["Show Tabs"].tap()

        waitForExistence(app.buttons["The Book of Mozilla, Tab"])
        app.buttons["The Book of Mozilla, Tab"].tap()
        XCTAssertFalse(app.textFields[""].exists)
        XCTAssertFalse(app.buttons["FindInPage.find_next"].exists)
        XCTAssertFalse(app.buttons["FindInPage.find_previous"].exists)
    } */

    func testFindFromSelection() {
        let textToFind = "from"
        openURL(path(forTestPage: "test-mozilla-book.html"))
        waitForExistence(app.webViews.staticTexts[textToFind])

        let stringToFind = app.webViews.staticTexts.matching(identifier: textToFind)
        let firstStringToFind = stringToFind.element(boundBy: 0)
        firstStringToFind.press(forDuration: 1)
        waitForExistence(app.menuItems["Copy"], timeout: 5)

        // Find in page is correctly launched, bar with text pre-filled and
        // the buttons to find next and previous
        if app.menuItems["Find in Page"].exists {
            app.menuItems["Find in Page"].tap()
        } else {
            app.menuItems["show.next.items.menu.button"].tap()
            waitForExistence(app.menuItems["Find in Page"])
            app.menuItems["Find in Page"].tap()
        }
        waitForExistence(app.textFields[textToFind])
        XCTAssertTrue(
            app.textFields[textToFind].exists,
            "The bar does not appear with the text selected to be found")
        XCTAssertTrue(app.buttons["FindInPage.find_previous"].exists, "Find previous button exists")
        XCTAssertTrue(app.buttons["FindInPage.find_next"].exists, "Find next button exists")
    }
}
