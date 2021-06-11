// Copyright Neeva. All rights reserved.

import UIKit

class NavigationController: UINavigationController {
    override init(rootViewController: UIViewController) {
        super.init(navigationBarClass: NavigationBar.self, toolbarClass: nil)
        self.pushViewController(rootViewController, animated: false)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var isNavigationBarHidden: Bool {
        get { true }
        set { super.isNavigationBarHidden = true }
    }
    override func setNavigationBarHidden(_ hidden: Bool, animated: Bool) {
        super.setNavigationBarHidden(true, animated: animated)
    }
}

class NavigationBar: UINavigationBar {
    override var isHidden: Bool {
        get { true }
        set { super.isHidden = true }
    }
}
