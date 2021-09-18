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

        waitForValueContains(app.buttons["Address Bar"], value: "http://example.com/")
    }

    func testTapEditURLShowsCorrectURLInAddressBar() {
        openURL()
        openURL("fakeurl.madeup")
        goToAddressBar()
        app.buttons["Edit Current Address"].tap()
        print(app.debugDescription)
        waitForValueContains(app.buttons["Address Bar"], value: "http://fakeurl.madeup/")
    }
}
