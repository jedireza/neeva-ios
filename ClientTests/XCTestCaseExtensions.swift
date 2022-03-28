/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import Foundation
import XCTest

extension XCTestCase {
    func wait(_ time: TimeInterval) {
        let expectation = self.expectation(description: "Wait")
        let result = XCTWaiter.wait(for: [expectation], timeout: time)
        if result == XCTWaiter.Result.timedOut {
            return
        } else {
            XCTFail("Delay interrupted")
        }
    }

    func waitForCondition(timeout: TimeInterval = 10, condition: () throws -> Bool) {
        let timeoutTime = Date.timeIntervalSinceReferenceDate + timeout
        do {
            while !(try condition()) {
                if Date.timeIntervalSinceReferenceDate > timeoutTime {
                    XCTFail("Condition timed out")
                    return
                }
                wait(0.1)
            }
        } catch {
            XCTFail("Condition threw error")
        }
    }
}
