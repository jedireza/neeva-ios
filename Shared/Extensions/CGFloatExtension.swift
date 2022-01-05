// Copyright Neeva. All rights reserved.

import UIKit

extension CGFloat {
    public func clamp(min: CGFloat, max: CGFloat) -> CGFloat {
        if self >= max {
            return max
        } else if self <= min {
            return min
        }
        return self
    }
}
