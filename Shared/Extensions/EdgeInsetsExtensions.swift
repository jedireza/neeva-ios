// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import SwiftUI

extension EdgeInsets {
    /// Creates an `EdgeInsets` with the given `edges` set to `amount` and the others set to zero.
    public init(edges: Edge.Set, amount: CGFloat) {
        self.init(top: 0, leading: 0, bottom: 0, trailing: 0)
        if edges.contains(.top) { top = amount }
        if edges.contains(.bottom) { bottom = amount }
        if edges.contains(.leading) { leading = amount }
        if edges.contains(.trailing) { trailing = amount }
    }
}
