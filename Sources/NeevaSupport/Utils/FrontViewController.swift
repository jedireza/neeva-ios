//
//  FrontViewController.swift
//  
//
//  Created by Jed Fox on 1/7/21.
//

import UIKit

extension UIViewController {
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
