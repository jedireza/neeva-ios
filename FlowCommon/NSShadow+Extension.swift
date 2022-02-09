// Code Adapted from FlowCommoniOS. See README.md for license

import UIKit

extension NSShadow {
    convenience init(blurRadius: CGFloat, offset: CGSize, color: UIColor) {
        self.init()
        shadowBlurRadius = blurRadius
        shadowOffset = offset
        shadowColor = color
    }
}
