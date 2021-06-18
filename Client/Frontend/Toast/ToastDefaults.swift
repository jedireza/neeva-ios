// Copyright Neeva. All rights reserved.

import UIKit
import Shared

class ToastDefaults: NSObject {
    func showToastForClosedTabs(_ savedTabs: [SavedTab], tabManager: TabManager) {
        guard FeatureFlag[.newToastUI], savedTabs.count > 0 else {
            return
        }

        let savedTabs = savedTabs.filter { !$0.isPrivate }
        var toastText: String!

        if savedTabs.count > 1 {
            toastText = "\(savedTabs.count) Tabs Closed"
        } else  {
            toastText = "Tab Closed"
        }

        let toastView = ToastViewManager.shared.makeToast(text: toastText, buttonText: "restore") {
            // restores last closed tab
            tabManager.restoreSavedTabs(savedTabs)
        }

        ToastViewManager.shared.enqueue(toast: toastView)
    }
}
