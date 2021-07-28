/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import XCTest

@testable import Client

class TabToolbarHelperTests: XCTestCase {
    var subject: LegacyTabToolbarHelper!
    var mockToolbar: MockTabToolbar!

    override func setUp() {
        super.setUp()
        mockToolbar = MockTabToolbar()
        subject = LegacyTabToolbarHelper(toolbar: mockToolbar)
    }
}

class MockTabsButton: TabsButton {
    init() {
        super.init(frame: .zero)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class MockToolbarButton: ToolbarButton {
    init() {
        super.init(frame: .zero)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class MockTabToolbar: LegacyTabToolbarProtocol {

    var isPrivateMode = false

    var tabToolbarDelegate: TabToolbarDelegate? {
        get { return nil }
        set {}
    }

    var _tabsButton = MockTabsButton()
    var tabsButton: TabsButton {
        _tabsButton
    }

    var _forwardButton = MockToolbarButton()
    var forwardButton: ToolbarButton { _forwardButton }

    var _backButton = MockToolbarButton()
    var backButton: ToolbarButton { _backButton }

    var _addToSpacesButton = MockToolbarButton()
    var addToSpacesButton: ToolbarButton { _addToSpacesButton }

    var _shareButton = MockToolbarButton()
    var shareButton: ToolbarButton { _shareButton }

    var _toolbarNeevaMenuButton = MockToolbarButton()
    var toolbarNeevaMenuButton: ToolbarButton { _toolbarNeevaMenuButton }

    var _multiStateButton = MockToolbarButton()
    var multiStateButton: ToolbarButton { _multiStateButton }
    var actionButtons: [ToolbarButton] {
        return []
    }

    func updateBackStatus(_ canGoBack: Bool) {

    }

    func updateForwardStatus(_ canGoForward: Bool) {

    }

    func updatePageStatus(_ isWebPage: Bool) {

    }

    func updateTabCount(_ count: Int, animated: Bool) {

    }

    func appMenuBadge(setVisible: Bool) {

    }

    func warningMenuBadge(setVisible: Bool) {

    }
}
