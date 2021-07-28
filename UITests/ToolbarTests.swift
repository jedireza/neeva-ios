/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import UIKit
import WebKit

class ToolbarTests: KIFTestCase, UITextFieldDelegate {
    fileprivate var webRoot: String!

    override func setUp() {
        webRoot = SimplePageServer.start()
        BrowserUtils.dismissFirstRunUI(tester())
    }

    func testURLEntry() {
        let urlHost = tester().waitForView(withAccessibilityLabel: "Address Bar")!
        let urlField = { urlHost.accessibilityElement(withLabel: "Address Bar")! }
        tester().tapView(withAccessibilityLabel: "Address Bar")
        tester().enterText(intoCurrentFirstResponder: "foobar")
        tester().tapView(withAccessibilityLabel: "Cancel")
        XCTAssertNotEqual(
            urlField().accessibilityValue, "foobar",
            "Verify that the URL bar text clears on about:home")

        // 127.0.0.1 doesn't cause http:// to be hidden. localhost does. Both will work.
        let localhostURL = webRoot.replacingOccurrences(of: "127.0.0.1", with: "localhost")
        let url = "\(localhostURL)/numberedPage.html?page=1"

        BrowserUtils.enterUrlAddressBar(tester(), typeUrl: url)

        tester().waitForAnimationsToFinish()
        XCTAssertEqual(urlField().accessibilityValue, url, "URL matches page URL")

        tester().tapView(withAccessibilityLabel: "Address Bar")
        tester().enterText(intoCurrentFirstResponder: "foobar")
        tester().tapView(withAccessibilityLabel: "Cancel")
        tester().waitForAnimationsToFinish()
        XCTAssertEqual(
            urlField().accessibilityValue, url,
            "Verify that text reverts to page URL after entering text")

        tester().tapView(withAccessibilityLabel: "Address Bar")
        tester().enterText(intoCurrentFirstResponder: " ")

        tester().tapView(withAccessibilityLabel: "Cancel")
        tester().waitForAnimationsToFinish()
        XCTAssertEqual(
            urlField().accessibilityValue, url,
            "Verify that text reverts to page URL after clearing text")
    }

    func testUserInfoRemovedFromURL() {
        let hostWithUsername = webRoot.replacingOccurrences(
            of: "127.0.0.1", with: "username:password@127.0.0.1")
        let urlWithUserInfo = "\(hostWithUsername)/numberedPage.html?page=1"

        BrowserUtils.enterUrlAddressBar(tester(), typeUrl: urlWithUserInfo)
        tester().waitForAnimationsToFinish()
        tester().waitForWebViewElementWithAccessibilityLabel("Page 1")

        let urlWithoutUserInfo = "\(webRoot!)/numberedPage.html?page=1"

        let urlField = tester().waitForView(withAccessibilityLabel: "Address Bar")!
            .accessibilityElement(withLabel: "Address Bar")!
        XCTAssertEqual(urlField.accessibilityValue, urlWithoutUserInfo)
    }

    override func tearDown() {
        let previousOrientation = UIDevice.current.value(forKey: "orientation") as! Int
        if previousOrientation == UIInterfaceOrientation.landscapeLeft.rawValue {
            // Rotate back to portrait
            let value = UIInterfaceOrientation.portrait.rawValue
            UIDevice.current.setValue(value, forKey: "orientation")
        }
        BrowserUtils.resetToAboutHomeKIF(tester())
        BrowserUtils.clearPrivateDataKIF(tester())
    }
}
