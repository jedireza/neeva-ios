// Copyright Neeva. All rights reserved.

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
