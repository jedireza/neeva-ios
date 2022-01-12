// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import SwiftUI

public extension LayoutDirection {
    var xSign: CGFloat {
        switch self {
        case .rightToLeft:
            return -1
        case .leftToRight:
            return 1
        @unknown default:
            return 1
        }
    }
}
