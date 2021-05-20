// Copyright Neeva. All rights reserved.

import UIKit

extension UIViewController {
    /// The frontmost view controller. Used to present share sheets and other
    /// UIKit-only view controllers
    @objc var frontViewController: UIViewController {
        presentedViewController?.frontViewController ?? self
    }
}
extension UITabBarController {
    override var frontViewController: UIViewController {
        presentedViewController?.frontViewController ?? selectedViewController?.frontViewController ?? self
    }
}
extension UINavigationController {
    override var frontViewController: UIViewController {
        presentedViewController?.frontViewController ?? topViewController?.frontViewController ?? self
    }
}
extension UIApplication {
    var frontViewController: UIViewController {
        windows.first!.rootViewController!.frontViewController
    }
}
