/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import UIKit
import SDWebImage

private let imageLock = NSLock()

extension CGRect {
    public init(width: CGFloat, height: CGFloat) {
        self.init(x: 0, y: 0, width: width, height: height)
    }

    public init(size: CGSize) {
        self.init(origin: .zero, size: size)
    }
}

extension Data {
    public var isGIF: Bool {
        return [0x47, 0x49, 0x46].elementsEqual(prefix(3))
    }
}

extension UIImage {
    /// Despite docs that say otherwise, UIImage(data: NSData) isn't thread-safe (see bug 1223132).
    /// As a workaround, synchronize access to this initializer.
    /// This fix requires that you *always* use this over UIImage(data: NSData)!
    public static func imageFromDataThreadSafe(_ data: Data) -> UIImage? {
        imageLock.lock()
        let image = UIImage(data: data)
        imageLock.unlock()
        return image
    }

    public static func createWithColor(_ size: CGSize, color: UIColor) -> UIImage {
        UIGraphicsImageRenderer(size: size).image { (ctx) in
            color.setFill()
            ctx.fill(CGRect(size: size))
        }
    }

    public func createScaled(_ size: CGSize) -> UIImage {
        UIGraphicsImageRenderer(size: size).image { (ctx) in
            draw(in: CGRect(size: size))
        }
    }

    public static func templateImageNamed(_ name: String) -> UIImage? {
        return UIImage(named: name)?.withRenderingMode(.alwaysTemplate)
    }
    
    public static func originalImageNamed(_ name: String) -> UIImage? {
        return UIImage(named: name)?.withRenderingMode(.alwaysOriginal)
    }

    // Uses compositor blending to apply color to an image.
    public func tinted(withColor: UIColor) -> UIImage {
        let img2 = UIImage.createWithColor(size, color: withColor)
        let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        let renderer = UIGraphicsImageRenderer(size: size)
        let result = renderer.image { ctx in
            img2.draw(in: rect, blendMode: .normal, alpha: 1)
            draw(in: rect, blendMode: .destinationIn, alpha: 1)
        }
        return result
    }

    // https://stackoverflow.com/questions/31314412/how-to-resize-image-in-swift/39681316
    // Resize UIImage with aspect ratio preserved
    // maxSize is the maximum size allowed for both width and height
    public func resize(_ maxSize: CGFloat) -> UIImage {
        // adjust for device pixel density
        let maxSizePixels = maxSize / UIScreen.main.scale
        // work out aspect ratio
        let aspectRatio =  size.width / size.height
        // variables for storing calculated data
        var width: CGFloat
        var height: CGFloat
        var newImage: UIImage
        if aspectRatio > 1 {
            // landscape
            width = maxSizePixels
            height = maxSizePixels / aspectRatio
        } else {
            // portrait
            height = maxSizePixels
            width = maxSizePixels * aspectRatio
        }
        // create an image renderer of the correct size
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: width, height: height), format: .default())
        // render the image
        newImage = renderer.image { _ in
            self.draw(in: CGRect(x: 0, y: 0, width: width, height: height))
        }
        // return the image
        return newImage
    }
}
