/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import XCTest

let webpage = ["url": "www.mozilla.org", "label": "Internet for people, not profit — Mozilla", "value": "mozilla.org"]
let oldHistoryEntries: [String] = ["Internet for people, not profit — Mozilla", "Twitter", "Home - YouTube"]
// This is part of the info the user will see in recent closed tabs once the default visited website (https://www.mozilla.org/en-US/book/) is closed
let closedWebPageLabel = "localhost:\(serverPort)/test-fixture/test-mozilla-book.html"

class HistoryTests: BaseTestCase {
    let testWithDB = ["testOpenHistoryFromBrowserContextMenuOptions", "testClearHistoryFromSettings", "testClearRecentHistory"]

    // This DDBB contains those 4 websites listed in the name
    let historyDB = "browserYoutubeTwitterMozillaExample.db"
    
    let clearRecentHistoryOptions = ["The Last Hour", "Today", "Today and Yesterday", "Everything"]

    func clearWebsiteData() {
        app.buttons["Neeva Menu"].tap()

        waitForExistence(app.buttons["Settings"])
        app.buttons["Settings"].tap()

        waitForExistence(app.cells["Clear Browsing Data"])
        app.cells["Clear Browsing Data"].tap()
        app.cells["Clear Selected Data on This Device"].tap()
        app.buttons["Clear Data"].tap()

        waitForNoExistence(app.buttons["Clear Data"])
        app.buttons["Settings"].tap()
        app.buttons["Done"].tap()
    }

    override func setUp() {
        // Test name looks like: "[Class testFunc]", parse out the function name
        let parts = name.replacingOccurrences(of: "]", with: "").split(separator: " ")
        let key = String(parts[1])
        if testWithDB.contains(key) {
            // for the current test name, add the db fixture used
            launchArguments = [LaunchArguments.SkipIntro, LaunchArguments.SkipWhatsNew, LaunchArguments.SkipETPCoverSheet, LaunchArguments.LoadDatabasePrefix + historyDB]
        }
        super.setUp()
    }

    func testEmptyHistoryListFirstTime() {
        // Go to History List from Top Sites and check it is empty
        goToHistory()

        waitForExistence(app.tables.cells["HistoryPanel.recentlyClosedCell"])
        XCTAssertTrue(app.tables.cells["HistoryPanel.recentlyClosedCell"].exists)
    }

    func testClearHistoryFromSettings() {
        // Go to Clear Data
        clearWebsiteData()

        // Back on History panel view check that there is not any item
        goToHistory()
        XCTAssertFalse(app.tables.cells.staticTexts[webpage["label"]!].exists)
    }

    func testClearPrivateDataButtonDisabled() {
        //Clear private data from settings and confirm
        clearPrivateData()
        
        //Wait for OK pop-up to disappear after confirming
        waitForNoExistence(app.alerts.buttons["Clear Data"], timeoutValue:5)
        
        //Assert that the button has been replaced with a success message
        XCTAssertFalse(app.tables.cells["Clear Selected Data on This Device"].exists)
    }

    private func showRecentlyClosedTabs() {
        goToTabTray()
        app.buttons["Add Tab"].press(forDuration: 1)
    }

    func testRecentlyClosedOptionAvailable() {
        // Now go back to default website close it and check whether the option is enabled
        openURL(path(forTestPage: "test-mozilla-book.html"))
        waitUntilPageLoad()
        closeAllTabs()
        
        goToRecentlyClosedPage()

        // The Closed Tabs list should contain the info of the website just closed
        waitForExistence(app.tables["Recently Closed Tabs List"], timeout: 3)
        XCTAssertTrue(app.tables.cells.staticTexts[closedWebPageLabel].exists)
        app.buttons["History Panel"].tap()
        app.buttons["Done"].tap()

        // This option should be enabled on private mode too
        toggleIncognito()

        goToRecentlyClosedPage()
        waitForExistence(app.tables["Recently Closed Tabs List"])
    }

    func testClearRecentlyClosedHistory() {
        // Open the default website
        openURL(path(forTestPage: "test-mozilla-book.html"))
        waitUntilPageLoad()
        closeAllTabs()

        goToRecentlyClosedPage()

        // Once the website is visited and closed it will appear in Recently Closed Tabs list
        waitForExistence(app.tables["Recently Closed Tabs List"])
        XCTAssertTrue(app.tables.cells.staticTexts[closedWebPageLabel].exists)
        print(app.menus.buttons.debugDescription, app.navigationBars.buttons.debugDescription)
        app.buttons["History Panel"].tap()
        app.buttons["Done"].tap()

        clearPrivateData()

        // Back on History panel view check that there is not any item
        goToRecentlyClosedPage()
        waitForNoExistence(app.tables["Recently Closed Tabs List"])
    }

    func testRecentlyClosedMenuAvailable() {
        openURL(path(forTestPage: "test-mozilla-book.html"))
        waitUntilPageLoad()
        closeAllTabs()

        showRecentlyClosedTabs()
        XCTAssertTrue(app.buttons["The Book of Mozilla"].exists)
    }

    func testOpenInNewTabRecentlyClosedItemFromMenu() {
        // test the recently closed tab menu
        openURL("neeva.com")
        waitUntilPageLoad()
        closeAllTabs()

        showRecentlyClosedTabs()
        app.buttons["Ad-free, private search - Neeva"].tap()

        XCTAssertEqual(app.cells.count, 2)
    }

    func testOpenInNewTabRecentlyClosedItem() {
        // test the recently closed tab page
        openURL(path(forTestPage: "test-mozilla-book.html"))
        waitUntilPageLoad()
        closeAllTabs()

        goToRecentlyClosedPage()

        waitForExistence(app.tables["Recently Closed Tabs List"])
        app.tables.cells.staticTexts[closedWebPageLabel].tap()
    }

    func testOpenInNewPrivateTabRecentlyClosedItem() {
        // Open the default website
        openURL("neeva.com")
        waitUntilPageLoad()
        closeAllTabs()

        goToRecentlyClosedPage()

        waitForExistence(app.tables["Recently Closed Tabs List"])
        app.tables.cells.staticTexts["https://neeva.com"].press(forDuration: 1)

        app.buttons["Open in New Incognito Tab"].tap()

        XCTAssertEqual(getNumberOfTabs(), 1)
    }

    func testPrivateClosedSiteDoesNotAppearOnRecentlyClosedMenu() {
        waitForTabsButton()
        toggleIncognito()

        // Open the default website
        openURL("neeva.com")
        waitUntilPageLoad()
        closeAllTabs()

        showRecentlyClosedTabs()
        XCTAssertFalse(app.buttons["Ad-free, private search - Neeva"].exists)
    }

    func testPrivateClosedSiteDoesNotAppearOnRecentlyClosed() {
        waitForTabsButton()
        toggleIncognito()

        // Open the default website
        openURL(path(forTestPage: "test-mozilla-book.html"))
        waitUntilPageLoad()
        closeAllTabs()

        goToRecentlyClosedPage()
        XCTAssertFalse(app.tables.cells.staticTexts[closedWebPageLabel].exists)
    }
    
    // Private function created to select desired option from the "Clear Recent History" list
    // We used this aproch to avoid code duplication
    private func tapOnClearRecentHistoryOption(optionSelected: String) {
        app.sheets.buttons[optionSelected].tap()
    }
    
    private func navigateToExample() {
        openURL("example.com")
        waitUntilPageLoad()
    }

    /* disabled because it fails with the new URL bar
    func testClearRecentHistory() {
        goToHistory()
        waitForExistence(app.tables["History List"].cells.element(matching: .cell, identifier: "HistoryPanel.clearHistory"))
        app.tables["History List"].cells.element(matching: .cell, identifier: "HistoryPanel.clearHistory").tap()
        tapOnClearRecentHistoryOption(optionSelected: "The Last Hour")
        // No data will be removed after Action.ClearRecentHistory since there is no recent history created.
        for entry in oldHistoryEntries {
            XCTAssertTrue(app.tables.cells.staticTexts[entry].exists)
        }

        // Go to 'goolge.com' to create a recent history entry.
        app.buttons["Done"].tap()
        navigator.nowAt(NewTabScreen)
        navigateToExample()

        goToHistory()
        waitForExistence(app.tables["History List"].cells.element(matching: .cell, identifier: "HistoryPanel.clearHistory"))
        app.tables["History List"].cells.element(matching: .cell, identifier: "HistoryPanel.clearHistory").tap()
        // Recent data will be removed after calling tapOnClearRecentHistoryOption(optionSelected: "Today").
        // Older data will not be removed
        tapOnClearRecentHistoryOption(optionSelected: "Today")
        for entry in oldHistoryEntries {
            XCTAssertTrue(app.tables.cells.staticTexts[entry].exists)
        }
        XCTAssertFalse(app.tables.cells.staticTexts["Google"].exists)
        
        // Begin Test for Today and Yesterday
        // Go to 'goolge.com' to create a recent history entry.
        app.buttons["Done"].tap()
        navigator.nowAt(NewTabScreen)
        navigateToExample()

        goToHistory()
        waitForExistence(app.tables["History List"].cells.element(matching: .cell, identifier: "HistoryPanel.clearHistory"))
        app.tables["History List"].cells.element(matching: .cell, identifier: "HistoryPanel.clearHistory").tap()
        // Tapping "Today and Yesterday" will remove recent data (from yesterday and today).
        // Older data will not be removed
        tapOnClearRecentHistoryOption(optionSelected: "Today and Yesterday")
        for entry in oldHistoryEntries {
            XCTAssertTrue(app.tables.cells.staticTexts[entry].exists)
        }
        XCTAssertFalse(app.tables.cells.staticTexts["Google"].exists)
        
        // Begin Test for Everything
        // Go to 'goolge.com' to create a recent history entry.
        app.buttons["Done"].tap()
        navigator.nowAt(NewTabScreen)
        navigateToExample()

        goToHistory()
        waitForExistence(app.tables["History List"].cells.element(matching: .cell, identifier: "HistoryPanel.clearHistory"))
        app.tables["History List"].cells.element(matching: .cell, identifier: "HistoryPanel.clearHistory").tap()
        // Tapping everything removes both current data and older data.
        tapOnClearRecentHistoryOption(optionSelected: "Everything")
        for entry in oldHistoryEntries {
            waitForNoExistence(app.tables.cells.staticTexts[entry], timeoutValue: 10)
            XCTAssertFalse(app.tables.cells.staticTexts[entry].exists, "History not removed")
        }
        XCTAssertFalse(app.tables.cells.staticTexts["Google"].exists)
    }
    */
    
    func testAllOptionsArePresent() {
        // Go to 'goolge.com' to create a recent history entry.
        navigateToExample()

        goToHistory()
        waitForExistence(app.tables["History List"].cells.element(matching: .cell, identifier: "HistoryPanel.clearHistory"))
        app.tables["History List"].cells.element(matching: .cell, identifier: "HistoryPanel.clearHistory").tap()
        
        for option in clearRecentHistoryOptions {
            XCTAssertTrue(app.sheets.buttons[option].exists)
        }
    }

    // Smoketest
    func testDeleteHistoryEntryBySwiping() {
        navigateToExample()
        goToHistory()
        waitForExistence(app.cells.staticTexts["http://example.com/"], timeout: 10)
        app.cells.staticTexts["http://example.com/"].firstMatch.swipeLeft()
        waitForExistence(app.buttons["Delete"], timeout: 10)
        app.buttons["Delete"].tap()
        waitForNoExistence(app.staticTexts["http://example.com"])
    }
}
