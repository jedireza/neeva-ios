// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

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
