// Copyright Neeva. All rights reserved.

import Foundation

func showFeedbackPanel(bvc: BrowserViewController, screenshot: UIImage? = nil) {
    bvc.present(SendFeedbackPanel(screenshot: screenshot, url: bvc.tabManager.selectedTab?.canonicalURL, onOpenURL: {
        bvc.dismiss(animated: true, completion: nil)
        bvc.openURLInNewTab($0)
    }), animated: true)
}
