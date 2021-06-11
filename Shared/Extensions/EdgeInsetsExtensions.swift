// Copyright Neeva. All rights reserved.

import SwiftUI

extension EdgeInsets {
    public init(edges: Edge.Set, amount: CGFloat) {
        self.init(top: 0, leading: 0, bottom: 0, trailing: 0)
        if edges.contains(.top) { top = amount }
        if edges.contains(.bottom) { bottom = amount }
        if edges.contains(.leading) { leading = amount }
        if edges.contains(.trailing) { trailing = amount }
    }
}
