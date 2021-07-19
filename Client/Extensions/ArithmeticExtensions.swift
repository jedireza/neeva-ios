// Copyright Neeva. All rights reserved.

import Foundation

// See https://github.com/neevaco/neeva-ios-phoenix/pull/1004#issuecomment-882558870
// for an explanation of why these functions (and only these functions) are implemented

@inlinable func * <I: BinaryInteger>(lhs: CGFloat, rhs: I) -> CGFloat {
    lhs * CGFloat(rhs)
}
@inlinable func * <I: BinaryInteger>(lhs: I, rhs: CGFloat) -> CGFloat {
    CGFloat(lhs) * rhs
}

// This is not commutative (i.e. BinaryInteger / CGFloat) because it seems likely to result in errors
@inlinable func / <I: BinaryInteger>(lhs: CGFloat, rhs: I) -> CGFloat {
    lhs / CGFloat(rhs)
}
