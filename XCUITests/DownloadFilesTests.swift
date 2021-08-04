import XCTest

let testFileName = "1Mio.dat"
let testFileSize = "1 MB"
let testURL = "http://www.ovh.net/files/"
let testBLOBURL = "http://bennadel.github.io/JavaScript-Demos/demos/href-download-text-blob/"
let testBLOBFileSize = "35 bytes"

class DownloadFilesTests: BaseTestCase {

    override func tearDown() {
        // TODO: do this another way
        /*
        // The downloaded file has to be removed between tests
        waitForExistence(app.tables["DownloadsTable"])

        let list = app.tables["DownloadsTable"].cells.count
        if list != 0 {
            for _ in 0...list - 1 {
                waitForExistence(app.tables["DownloadsTable"].cells.element(boundBy: 0))
                app.tables["DownloadsTable"].cells.element(boundBy: 0).swipeLeft()
                waitForExistence(app.tables.cells.buttons["Delete"])
                app.tables.cells.buttons["Delete"].tap()
            }
        }*/
    }

    private func deleteItem(itemName: String) {
        app.tables.cells.staticTexts[itemName].swipeLeft()
        waitForExistence(app.tables.cells.buttons["Delete"], timeout: 3)
        app.tables.cells.buttons["Delete"].tap()
    }

    func testDownloadFileContextMenu() throws {
        try skipTest(issue: 1240, "Test depends on unreachable server")
        openURL(testURL)
        waitUntilPageLoad()
        // Verify that the context menu prior to download a file is correct
        app.webViews.links["1 Mio file"].firstMatch.tap()

        waitForExistence(app.tables["Context Menu"])
        XCTAssertTrue(app.tables["Context Menu"].staticTexts[testFileName].exists)
        XCTAssertTrue(app.tables["Context Menu"].cells["download"].exists)
        app.buttons["Cancel"].tap()

        checkTheNumberOfDownloadedItems(items: 0)
    }

    // Smoketest
    func testDownloadFile() throws {
        try skipTest(issue: 1240, "Test depends on unreachable server")
        downloadFile(fileName: testFileName, numberOfDownloads: 1)

        // There should be one item downloaded. It's name and size should be shown
        checkTheNumberOfDownloadedItems(items: 1)
        XCTAssertTrue(app.tables.cells.staticTexts[testFileName].exists)
        XCTAssertTrue(app.tables.cells.staticTexts[testFileSize].exists)
    }

    func testDeleteDownloadedFile() throws {
        try skipTest(issue: 1240, "Test depends on unreachable server")
        downloadFile(fileName: testFileName, numberOfDownloads: 1)

        // TODO: update to check this another way
        waitForExistence(app.tables["DownloadsTable"])

        deleteItem(itemName: testFileName)
        waitForNoExistence(app.tables.cells.staticTexts[testFileName])

        // After removing the number of items should be 0
        checkTheNumberOfDownloadedItems(items: 0)
    }

    func testShareDownloadedFile() throws {
        try skipTest(issue: 1240, "Test depends on unreachable server")
        downloadFile(fileName: testFileName, numberOfDownloads: 1)

        // TODO: update to check this another way
        waitForExistence(app.tables["DownloadsTable"])
        app.tables.cells.staticTexts[testFileName].swipeLeft()

        XCTAssertTrue(app.tables.cells.buttons["Share"].exists)
        XCTAssertTrue(app.tables.cells.buttons["Delete"].exists)
        //Comenting out until share sheet can be managed with automated tests issue #5477
        //app.tables.cells.buttons["Share"].tap()
        //waitForExistence(app.otherElements["ActivityListView"])
        //if iPad() {
        //    app.otherElements["PopoverDismissRegion"].tap()
        //} else {
        //    app.buttons["Cancel"].tap()
        //}
    }

    func testLongPressOnDownloadedFile() throws {
        try skipTest(issue: 1240, "Test depends on unreachable server")
        downloadFile(fileName: testFileName, numberOfDownloads: 1)

        // TODO: update to check this another way
        waitForExistence(app.tables["DownloadsTable"])
        //Comenting out until share sheet can be managed with automated tests issue #5477
        //app.tables.cells.staticTexts[testFileName].press(forDuration: 1)
        //waitForExistence(app.otherElements["ActivityListView"])
        //if iPad() {
        //    app.otherElements["PopoverDismissRegion"].tap()
        //} else {
        //    app.buttons["Cancel"].tap()
        //}
    }

    private func downloadFile(fileName: String, numberOfDownloads: Int) {
        openURL(testURL)
        waitUntilPageLoad()
        for _ in 0..<numberOfDownloads {
            app.webViews.links["1 Mio file"].firstMatch.tap()
            waitForExistence(app.tables["Context Menu"])
            app.tables["Context Menu"].cells["download"].tap()
        }
    }

    private func downloadBLOBFile() {
        openURL(testBLOBURL)
        waitUntilPageLoad()
        waitForExistence(app.webViews.links["Download Text"])
        app.webViews.links["Download Text"].press(forDuration: 1)
        app.buttons["Download Link"].tap()
    }

    func testDownloadMoreThanOneFile() throws {
        try skipTest(issue: 1240, "Test depends on unreachable server")
        downloadFile(fileName: testFileName, numberOfDownloads: 2)

        checkTheNumberOfDownloadedItems(items: 2)
    }

    func testRemoveUserDataRemovesDownloadedFiles() throws {
        try skipTest(issue: 1240, "Test depends on unreachable server")
        // The option to remove downloaded files from clear private data is off by default
        goToClearData()
        XCTAssertTrue(
            app.cells.switches["Downloaded Files"].isEnabled,
            "The switch is not set correclty by default")

        // Change the value of the setting to on (make an action for this)
        downloadFile(fileName: testFileName, numberOfDownloads: 1)

        // Check there is one item
        waitForExistence(app.tables["DownloadsTable"])
        checkTheNumberOfDownloadedItems(items: 1)

        // Remove private data once the switch to remove downloaded files is enabled
        goToClearData()
        app.cells.switches["Downloaded Files"].tap()
        clearPrivateData(fromTab: false)

        // Check there is still one item
        checkTheNumberOfDownloadedItems(items: 0)
    }

    private func checkTheNumberOfDownloadedItems(items: Int) {
        // TODO: update to check this another way
        waitForExistence(app.tables["DownloadsTable"])
        let list = app.tables["DownloadsTable"].cells.count
        XCTAssertEqual(list, items, "The number of items in the downloads table is not correct")
    }
    // Smoketest
    func testToastButtonToGoToDownloads() throws {
        try skipTest(issue: 1240, "Test depends on unreachable server")
        downloadFile(fileName: testFileName, numberOfDownloads: 1)
        checkTheNumberOfDownloadedItems(items: 1)
    }
}
