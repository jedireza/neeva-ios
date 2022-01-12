// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import SwiftUI

/// Contains functionality used by both `QueryController` and `MutationController`
open class AbstractController {
    var animation: Animation?

    public init(animation: Animation? = nil) {
        self.animation = animation
    }

    /// Calls `body` inside of `withAnimation` if `animation` is non-`nil`. Otherwise, it calls `body` directly.
    public func withOptionalAnimation<Result>(_ body: () throws -> Result) rethrows -> Result {
        if let animation = animation {
            return try withAnimation(animation, body)
        } else {
            return try body()
        }
    }

}
