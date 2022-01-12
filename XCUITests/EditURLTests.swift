// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

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
