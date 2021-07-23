// Copyright Neeva. All rights reserved.

import XCTest
@testable import AppClip

class AppClipTest: XCTestCase {
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testSaveRetrieveData() throws {
        let testValue = "testing"

        AppClipApp.saveDataToDevice(data: testValue)
        XCTAssertEqual(retreiveDataFromDevice(), testValue)
    }

    func retreiveDataFromDevice() -> String? {
        guard let appClipPath = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: AppClipApp.appClipSuiteName)?.appendingPathComponent("AppClipValue") else {
            return nil
        }

        do {
            let data = try Data(contentsOf: appClipPath)
            return try JSONDecoder().decode(String.self, from: data)
        } catch {
            print("Error retriving App Clip data:", error.localizedDescription)
            return nil
        }
    }
}
