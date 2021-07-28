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

        AppClipHelper.saveTokenToDevice(testValue)
        XCTAssertEqual(AppClipHelper.retreiveAppClipData(), testValue)
    }
}
