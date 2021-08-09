// Copyright Neeva. All rights reserved.

import Foundation

extension UITestBase {
    func goToAddressBar() {
        if !tester().viewExistsWithLabel("Cancel") {
            tester().waitForView(withAccessibilityLabel: "Address Bar")
            tester().tapView(withAccessibilityLabel: "Address Bar")
        }

        tester().waitForView(withAccessibilityIdentifier: "address")
    }

    func goToNeevaMenu() {
        tester().waitForAnimationsToFinish()
        tester().waitForView(withAccessibilityLabel: "Neeva Menu")
        tester().tapView(withAccessibilityLabel: "Neeva Menu")

        tester().waitForAnimationsToFinish()

        // makes sure that the menu is fully open
        tester().waitForView(withAccessibilityLabel: "Settings")
    }

    func goToClearData() {
        goToNeevaMenu()
        tester().tapView(withAccessibilityLabel: "Settings")
        tester().accessibilityScroll(.down)
        tester().waitForAnimationsToFinish()

        tester().waitForView(withAccessibilityLabel: "Clear Browsing Data")
        tester().tapView(withAccessibilityLabel: "Clear Browsing Data")
    }

    func goToHistory() {
        goToNeevaMenu()
        tester().tapView(withAccessibilityLabel: "History")
        tester().waitForAnimationsToFinish()
    }

    func goToSettings() {
        goToNeevaMenu()
        tester().tapView(withAccessibilityLabel: "Settings")
        tester().waitForAnimationsToFinish()
    }
}
