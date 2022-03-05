// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Foundation

extension UITestBase {
    static var shouldUseNeevaMenu = false

    func goToAddressBar() {
        if !tester().viewExistsWithLabel("Cancel") {
            tester().waitForView(withAccessibilityLabel: "Address Bar")
            tester().tapView(withAccessibilityLabel: "Address Bar")
        }

        tester().waitForView(withAccessibilityIdentifier: "address")
    }

    // Backup for bots still using the Neeva Menu instead of Neeva Scope
    func goToNeevaMenu() {
        tester().waitForAnimationsToFinish()
        tester().waitForView(withAccessibilityLabel: "Neeva Menu")
        tester().tapView(withAccessibilityLabel: "Neeva Menu")

        tester().waitForAnimationsToFinish()

        // makes sure that the menu is fully open
        tester().waitForView(withAccessibilityLabel: "Settings")
    }

    func goToOverflowMenu() {
        guard !UITestBase.shouldUseNeevaMenu else {
            goToNeevaMenu()
            return
        }

        tester().waitForAnimationsToFinish()
        tester().waitForView(withAccessibilityLabel: "More")
        tester().tapView(withAccessibilityLabel: "More")

        tester().waitForAnimationsToFinish()

        if tester().viewExistsWithLabel("Settings") {
            // Expand the overflow menu
            let reloadButton = tester().waitForView(withAccessibilityLabel: "Reload")

            if !isiPad() {
                reloadButton?.drag(from: CGPoint(x: 0, y: 500), to: CGPoint(x: 0, y: 0))
            }

            tester().waitForAnimationsToFinish()
        } else {
            UITestBase.shouldUseNeevaMenu = true

            if !isiPad() {
                // Close the view
                tester().tapScreen(at: CGPoint(x: 100, y: 100))
            }

            // Bot is still using old version, open Neeva Menu instead
            goToNeevaMenu()
        }
    }

    func goToClearData() {
        goToOverflowMenu()

        tester().tapView(withAccessibilityLabel: "Settings")
        tester().accessibilityScroll(.down)
        tester().waitForAnimationsToFinish()

        tester().waitForView(withAccessibilityLabel: "Clear Browsing Data")
        tester().tapView(withAccessibilityLabel: "Clear Browsing Data")
    }

    func goToHistory() {
        goToOverflowMenu()
        tester().tapView(withAccessibilityLabel: "History")
        tester().waitForAnimationsToFinish()
    }

    func goToSettings() {
        goToOverflowMenu()
        tester().tapView(withAccessibilityLabel: "Settings")
        tester().waitForAnimationsToFinish()
    }
}
