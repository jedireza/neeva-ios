/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import Foundation
import SwiftUI

extension UIView {
    /// Takes a screenshot of the view with the given size.
    func screenshot(_ size: CGSize, offset: CGPoint? = nil, quality: CGFloat = 1) -> UIImage? {
        assert(0...1 ~= quality)

        let offset = offset ?? .zero

        UIGraphicsBeginImageContextWithOptions(size, false, UIScreen.main.scale * quality)
        drawHierarchy(in: CGRect(origin: offset, size: frame.size), afterScreenUpdates: false)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return image
    }

    /// Takes a screenshot of the view with the given aspect ratio.
    ///
    /// An aspect ratio of 0 means to capture the entire view.
    func screenshot(_ aspectRatio: CGFloat = 0, offset: CGPoint? = nil, quality: CGFloat = 1)
        -> UIImage?
    {
        assert(aspectRatio >= 0)

        var size: CGSize
        if aspectRatio > 0 {
            size = CGSize()
            let viewAspectRatio = frame.width / frame.height
            if viewAspectRatio > aspectRatio {
                size.height = frame.height
                size.width = size.height * aspectRatio
            } else {
                size.width = frame.width
                size.height = size.width / aspectRatio
            }
        } else {
            size = frame.size
        }

        return screenshot(size, offset: offset, quality: quality)
    }

    /// Screenshot of entire UIView
    ///
    /// This method draws the entire view by rendering the layer into a CGContext
    var screenshot: UIImage? {
        let rect = self.bounds
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0.0)
        guard let context = UIGraphicsGetCurrentContext() else {
            return nil
        }
        self.layer.render(in: context)
        let capturedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return capturedImage
    }
}

extension View {
    /// Takes a screenshot of the SwiftUI View
    ///
    /// This method lays out the view in a new UIHostingController as large as the view needs
    /// Thus, this method is expensive and does not preserve any states
    /// In addition, environment objects must be passed to the view again
    func takeScreenshot(origin: CGPoint, size: CGSize) -> UIImage? {
        let window = UIWindow(frame: CGRect(origin: origin, size: size))
        let hosting = UIHostingController(rootView: self)
        hosting.view.frame = window.frame
        window.addSubview(hosting.view)
        window.makeKeyAndVisible()
        return hosting.view.screenshot
    }
}
