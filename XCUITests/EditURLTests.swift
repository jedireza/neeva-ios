// Copyright Neeva. All rights reserved.

import Foundation

class EditURLTests: BaseTestCase {
    func testEditURLShows() {
        openURL()
        goToAddressBar()
        assert(app.buttons["Edit Current Address"].exists == true)
    }

    func testTapEditURLShowsInAddressBar() {
        openURL()
        goToAddressBar()
        app.buttons["Edit Current Address"].tap()
        XCTAssertEqual(
            app.buttons["Address Bar"].value as! String, "Secure connection, https://example.com/")
    }

    func testTapEditURLShowsCorrectURLInAddressBar() {
        openURL()
        openURL("fakeurl.madeup")
        goToAddressBar()
        app.buttons["Edit Current Address"].tap()
        XCTAssertEqual(app.buttons["Address Bar"].value as! String, "https://fakeurl.madeup/")
    }
}
