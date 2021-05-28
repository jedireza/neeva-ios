/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import Foundation
@testable import Client
import XCTest
import Shared
import Defaults

class DefaultBrowserOnboardingTests: XCTestCase {
    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        UserDefaults.standard.clearProfilePrefs()
        super.tearDown()
    }
    
    func testShouldNotShowCoverSheetFreshInstallSessionLessThan3() {
        var sessionValue: Int32 = 0
        let shouldShow = DefaultBrowserOnboardingViewModel.shouldShowDefaultBrowserOnboarding()
        // The session value should increase from 0 to 1
        sessionValue = Defaults[.sessionCount]
        XCTAssertEqual(sessionValue, 0)
        XCTAssert(!shouldShow)
    }
    
    func testShouldShowCoverSheetCleanInstallSessionEqualTo3() {
        var shouldShow: Bool = false
        var didShow: Bool = false
        Defaults[.sessionCount] = 3
        Defaults[.didShowDefaultBrowserOnboarding] = false
        shouldShow = DefaultBrowserOnboardingViewModel.shouldShowDefaultBrowserOnboarding()
        didShow = Defaults[.didShowDefaultBrowserOnboarding]
        XCTAssert(shouldShow)
        XCTAssert(didShow)
    }
}
