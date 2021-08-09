/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import XCTest

class DatabaseFixtureTest: BaseTestCase {
    let fixtures = [
        "testHistoryDatabaseFixture": "testHistoryDatabase4000-browser.db",
        "testHistoryDatabasePerformance": "testHistoryDatabase4000-browser.db",
        "testPerfHistory4000startUp": "testHistoryDatabase4000-browser.db",
        "testPerfHistory4000openMenu": "testHistoryDatabase4000-browser.db",
    ]

    override func setUp() {
        // Test name looks like: "[Class testFunc]", parse out the function name
        let parts = name.replacingOccurrences(of: "]", with: "").split(separator: " ")
        let key = String(parts[1])
        // for the current test name, add the db fixture used
        launchArguments = [
            LaunchArguments.SkipIntro, LaunchArguments.SkipWhatsNew,
            LaunchArguments.SkipETPCoverSheet, LaunchArguments.LoadDatabasePrefix + fixtures[key]!,
        ]
        super.setUp()
    }

    func testHistoryDatabaseFixture() {
        goToHistory()

        // History list has two cells that are for recently closed and synced devices that should not count as history items,
        // the actual max number is 100
        let loaded = NSPredicate(format: "count == 102")
        expectation(for: loaded, evaluatedWith: app.tables["History List"].cells, handler: nil)
        waitForExpectations(timeout: 30, handler: nil)
    }

    func testPerfHistory4000startUp() {
        if #available(iOS 13.0, *) {
            measure(metrics: [
                XCTMemoryMetric(),
                XCTClockMetric(),  // to measure timeClock Mon
                XCTCPUMetric(),  // to measure cpu cycles
                XCTStorageMetric(),  // to measure storage consuming
                XCTMemoryMetric(),
            ]) {
                // activity measurement here
                app.launch()
            }
        }
    }

    func testPerfHistory4000openMenu() {
        if #available(iOS 13.0, *) {
            measure(metrics: [
                XCTMemoryMetric(),
                XCTClockMetric(),  // to measure timeClock Mon
                XCTCPUMetric(),  // to measure cpu cycles
                XCTStorageMetric(),  // to measure storage consuming
                XCTMemoryMetric(),
            ]) {
            }
        }
    }
}
