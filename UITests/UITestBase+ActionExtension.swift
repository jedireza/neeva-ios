// Copyright Neeva. All rights reserved.

import Foundation

extension UITestBase {
    func dismissFirstRunUI() {
        tester().waitForAnimationsToFinish()

        if tester().viewExistsWithLabel("Skip to browser without Neeva search") {
            tester().tapView(withAccessibilityLabel: "Skip to browser without Neeva search")
            tester().waitForAnimationsToFinish()
        }

        tester().waitForAnimationsToFinish()
    }

    // MARK: - Tab & URL
    func closeAllTabs() {
        tester().longPressView(withAccessibilityLabel: "Show Tabs", duration: 1)
        tester().waitForAnimationsToFinish()

        if tester().viewExistsWithLabel("Close All Tabs") {
            tester().tapView(withAccessibilityLabel: "Close All Tabs")

            tester().waitForView(withAccessibilityLabel: "Confirm Close All Tabs")
            tester().tapView(withAccessibilityLabel: "Confirm Close All Tabs")
        } else {
            tester().tapView(withAccessibilityIdentifier: "Close Tab Action")
        }
    }

    func openNewTab(to url: String = "example.com") {
        tester().waitForView(withAccessibilityLabel: "Show Tabs")
        tester().longPressView(withAccessibilityLabel: "Show Tabs", duration: 1)
        tester().waitForAnimationsToFinish()

        if tester().viewExistsWithLabel("New Tab") {
            tester().tapView(withAccessibilityLabel: "New Tab")
        } else {
            tester().tapView(withAccessibilityLabel: "New Incognito Tab")
        }

        tester().waitForAnimationsToFinish()
        openURL(url)
    }

    func openURL(_ url: String = "example.com", openAddressBar: Bool = true) {
        if openAddressBar {
            goToAddressBar()
        }

        tester().waitForSoftwareKeyboard()
        tester().waitForKeyInputReady()
        tester().enterText(intoCurrentFirstResponder: url)
        tester().enterText(intoCurrentFirstResponder: "\n")
        tester().waitForAbsenceOfView(withAccessibilityIdentifier: "address")
        tester().waitForAbsenceOfSoftwareKeyboard()
        tester().waitForView(withAccessibilityLabel: "Show Tabs")
    }

    // MARK: - Data
    func clearPrivateData(_ clearables: [Clearable] = Clearable.allCases) {
        goToClearData()

        let clearables = Set(clearables)
        for clearable in UITestBase.AllClearables {
            tester().setOn(clearables.contains(clearable), forSwitchWithAccessibilityLabel: clearable.label())
        }

        tester().tapView(withAccessibilityLabel: "Clear Selected Data on This Device")
        tester().waitForView(withAccessibilityLabel: "Clear Data")
        tester().tapView(withAccessibilityLabel: "Clear Data")
        tester().waitForAbsenceOfView(withAccessibilityLabel: "Clear Data")

        closeClearPrivateData()
    }

    func clearPrivateData(excluding clearablesToExclude: [Clearable]) {
        clearPrivateData(Clearable.allCases.filter { !clearablesToExclude.contains($0) })
    }

    func closeClearPrivateData() {
        tester().tapView(withAccessibilityLabel: "Settings")
        tester().waitForView(withAccessibilityLabel: "Done")
        tester().tapView(withAccessibilityLabel: "Done")
        tester().waitForAnimationsToFinish()
        tester().waitForView(withAccessibilityLabel: "Show Tabs")
    }

    // MARK: - History
    func clearHistoryItems(numberOfTests: Int = -1) {
        goToHistory()

        let historyTable = tester().waitForView(withAccessibilityIdentifier: "History List") as! UITableView

        var index = 0
        for _ in 0..<historyTable.numberOfSections {
            for _ in 0..<historyTable.numberOfRows(inSection: 0) {
                clearHistoryItemAtIndex(IndexPath(row: 0, section: 0))
                if numberOfTests > -1 {
                    index += 1
                    if index == numberOfTests {
                        return
                    }
                }
            }
        }

        closeHistory()
    }

    func clearHistoryItemAtIndex(_ index: IndexPath) {
        if let row = tester().waitForCell(at: index, inTableViewWithAccessibilityIdentifier: "History List") {
            tester().swipeView(
                withAccessibilityLabel: row.accessibilityLabel, value: row.accessibilityValue,
                in: KIFSwipeDirection.left)
            tester().tapView(withAccessibilityLabel: "Remove")
        }
    }

    func closeHistory() {
        tester().tapView(withAccessibilityLabel: "Done")
        tester().waitForAnimationsToFinish()
        tester().waitForView(withAccessibilityLabel: "Show Tabs")
    }
}
