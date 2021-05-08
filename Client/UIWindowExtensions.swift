//
//  UIWindowExtensions.swift
//  Client
//
//  Created by Macy Ngan on 5/8/21.
//  Copyright © 2021 Neeva. All rights reserved.
//

import Foundation

extension UIWindow {
    static var isLandscape: Bool {
        if #available(iOS 13.0, *) {
            return UIApplication.shared.windows
                .first?
                .windowScene?
                .interfaceOrientation
                .isLandscape ?? false
        } else {
            return UIApplication.shared.statusBarOrientation.isLandscape
        }
    }
}
