// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Defaults
import Foundation
import Shared
import Storage

@testable import Client

// Needs to be in sync with Client Clearables.
enum Clearable: String, CaseIterable {
    case history = "Browsing History"
    case cache = "Cache"
    case cookies = "Cookies"
    case trackingProtection = "Tracking Protection"

    func label() -> String? {
        switch self {
        case .cookies:
            return "Cookies, Clearing it will sign you out of most sites."
        default:
            return self.rawValue
        }
    }
}

class UITestBase: KIFTestCase {
    static let AllClearables = Set([
        Clearable.history, Clearable.cache, Clearable.cookies, Clearable.trackingProtection,
    ])

    func resetToHome() {
        if (try? tester().tryFindingTappableView(withAccessibilityLabel: "Cancel")) != nil {
            tester().tapView(withAccessibilityLabel: "Cancel")
        }

        closeAllTabs()
    }

    func getNumberOfTabs() -> Int {
        SceneDelegate.getTabManagerOrNil()?.tabs.count ?? 0
    }

    func isiPad() -> Bool {
        return UIDevice.current.userInterfaceIdiom == .pad
    }

    func addHistoryEntry(_ title: String, url: URL) {
        let info: [AnyHashable: Any] = [
            "url": url,
            "title": title,
            "visitType": VisitType.link.rawValue,
        ]

        NotificationCenter.default.post(name: .OnLocationChange, object: self, userInfo: info)
    }

    func ensureAutocompletionResult(textField: UITextField, prefix: String, completion: String) {
        let autocompleteFieldlabel =
            textField.subviews.first { $0.accessibilityIdentifier == "autocomplete" } as? UILabel

        if completion == "" {
            XCTAssertTrue(
                autocompleteFieldlabel == nil,
                "The autocomplete was empty but the label still exists.")
            return
        }

        XCTAssertTrue(autocompleteFieldlabel != nil, "The autocomplete was not found")
        XCTAssertEqual(
            completion, autocompleteFieldlabel!.text, "Expected prefix matches actual prefix")
    }

    override func setUp() {
        if tester().viewExistsWithLabel("Done") && getNumberOfTabs() == 0 {
            tester().tapView(withAccessibilityLabel: "Add Tab")
            openURL()
        }

        tester().waitForAnimationsToFinish()
    }

    override func tearDown() {
        resetToHome()

        let bvc = SceneDelegate.getBVC(for: nil)
        ClearableDataType.allCases.forEach {
            _ = $0.clearable(profile: bvc.profile, tabManager: bvc.tabManager).clear()
        }

        super.tearDown()
    }
}
