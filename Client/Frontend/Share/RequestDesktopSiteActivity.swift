// Copyright Neeva. All rights reserved.

import Foundation
import Shared

class RequestDesktopSiteActivity: UIActivity {
    private let tab: Tab?
    fileprivate let callback: () -> Void

    init(tab: Tab?, callback: @escaping () -> Void) {
        self.tab = tab
        self.callback = callback
    }

    override var activityTitle: String? {
        return tab?.changedUserAgent == true ?
            Strings.AppMenuViewMobileSiteTitleString : Strings.AppMenuViewDesktopSiteTitleString
    }

    override var activityImage: UIImage? {
        return tab?.changedUserAgent == true ? #imageLiteral(resourceName: "shareRequestMobileSite") : #imageLiteral(resourceName: "shareRequestDesktopSite")
    }

    override func perform() {
        callback()
        activityDidFinish(true)
    }

    override func canPerform(withActivityItems activityItems: [Any]) -> Bool {
        return true
    }
}
