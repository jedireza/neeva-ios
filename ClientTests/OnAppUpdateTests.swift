// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import XCTest

@testable import Client

class OnAppUpdateTests: XCTestCase {
    let sceneDelegate = SceneDelegate()

    func testLogicOne() {
        let currentVersion = "1.1.1"
        let previousVersion = "1.1.0"

        XCTAssertTrue(
            sceneDelegate.onAppUpdate(
                previousVersion: previousVersion,
                currentVersion: currentVersion)
        )
    }

    func testLogicTwo() {
        let currentVersion = "10.1.1"
        let previousVersion = "1.1.1"

        XCTAssertTrue(
            sceneDelegate.onAppUpdate(
                previousVersion: previousVersion,
                currentVersion: currentVersion)
        )
    }

    func testLogicThree() {
        let currentVersion = "1.1.1"
        let previousVersion = "10.1.1"

        XCTAssertFalse(
            sceneDelegate.onAppUpdate(
                previousVersion: previousVersion,
                currentVersion: currentVersion)
        )
    }

    func testLogicFour() {
        let currentVersion = "1.1.0"
        let previousVersion = "1.1.1"

        XCTAssertFalse(
            sceneDelegate.onAppUpdate(
                previousVersion: previousVersion,
                currentVersion: currentVersion)
        )
    }
}
