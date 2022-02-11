// Code Adapted from FlowCommoniOS. See README.md for license

import UIKit

open class FlowTextView: UILabel {
    open var textLayer: CATextLayer {
        return layer as! CATextLayer
    }

    override open class var layerClass: AnyClass {
        return CATextLayer.self
    }
}
