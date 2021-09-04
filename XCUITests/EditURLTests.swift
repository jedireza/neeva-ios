// Copyright Neeva. All rights reserved.

import Foundation

class EditURLTests: BaseTestCase {
    func testZeroQueryURLNotSuggestedToEdit() {
        goToAddressBar()
        assert(app.buttons["Edit Current URL"].exists == false)
    }

    func testEditURLShows() {
        openURL()
        goToAddressBar()
        assert(app.buttons["Edit Current URL"].exists == true)
    }

    func testTapEditURLShowsInAddressBar() {
        openURL()
        goToAddressBar()
        app.buttons["Edit Current URL"].tap()

        waitForValueContains(app.buttons["Address Bar"], value: "http://example.com/")
    }

    func testTapEditURLShowsCorrectURLInAddressBar() {
        openURL("fakeurl.madeup")
        goToAddressBar()
        app.buttons["Edit Current URL"].tap()

        waitForValueContains(app.buttons["Address Bar"], value: "http://fakeurl.madeup/")
    }
}
