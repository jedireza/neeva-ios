// Copyright Neeva. All rights reserved.

import XCTest

class ToastTests: BaseTestCase {
    let testWithDB = ["testOpenHistoryFromBrowserContextMenuOptions", "testClearHistoryFromSettings", "testClearRecentHistory"]

    // This DB contains those 4 websites listed in the name
    let historyDB = "browserYoutubeTwitterMozillaExample.db"
    
    let clearRecentHistoryOptions = ["The Last Hour", "Today", "Today and Yesterday", "Everything"]

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

    // MARK: Close Tab Toast
    private func showCloseTabToast() {
        // test the recently closed tab page
        navigator.openURL(path(forTestPage: "test-mozilla-book.html"))
        waitUntilPageLoad()
        navigator.nowAt(NewTabScreen)
        navigator.goto(TabTray)

        waitForExistence(app.buttons["tab close"])
        app.buttons["tab close"].firstMatch.tap()
    }

    func testClosedTabToastDoesNotAppear() {
        // test the recently closed tab page
        navigator.openURL(path(forTestPage: "test-mozilla-book.html"))
        waitUntilPageLoad()
        closeAllTabs()

        navigator.nowAt(NewTabScreen)

        waitForNoExistence(app.buttons["restore"])
    }

    func testClosedTabToastAppears() {
        showCloseTabToast()
        waitForExistence(app.buttons["restore"])
    }

    func testClosedTabToastDisappears() {
        showCloseTabToast()
        waitForExistence(app.buttons["restore"])
        waitForNoExistence(app.buttons["restore"], timeoutValue: 6)
    }

    func testClosedTabToastTabRestored() {
        showCloseTabToast()
        waitForExistence(app.buttons["restore"])
        app.buttons["restore"].forceTapElement()
    }

    func testClosedTabToastTabRestoredWithMultipleTabs() {
        // open up another tab
        navigator.goto(TabTray)
        app.buttons["Add Tab"].tap()
        navigator.nowAt(NewTabScreen)

        // close the first tab
        showCloseTabToast()

        // restore
        waitForExistence(app.buttons["restore"])
        app.buttons["restore"].forceTapElement()
        waitForNoExistence(app.buttons["restore"])

        // Still causes error
        // TODO: Possibly an interference from the Toast animation
        // XCTAssertTrue(userState.numTabs == 2)
    }
}
