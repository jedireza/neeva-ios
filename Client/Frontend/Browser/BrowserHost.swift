// Copyright Neeva. All rights reserved.

import Foundation
import SwiftUI

class BrowserHost: IncognitoAwareHostingController<BrowserView> {
    init(bvc: BrowserViewController) {
        super.init(isIncognito: bvc.tabManager.isIncognito) {
            BrowserView(bvc: bvc)
        }
    }

    @objc required dynamic init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        view.backgroundColor = UIColor.DefaultBackground
        view.translatesAutoresizingMaskIntoConstraints = false
    }
}
