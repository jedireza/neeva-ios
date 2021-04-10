// Copyright Neeva. All rights reserved.

import SwiftUI

// Optionally wraps an embedded view with a ScrollView based on a specified
// threshold height value. I.e., if the view needs to be larger than the
// specified value, then a ScrollView will be inserted.
public struct VerticalScrollViewIfNeeded<EmbeddedView>: View where EmbeddedView: View {
    var embeddedView: EmbeddedView
    let thresholdHeight: CGFloat

    public var body: some View {
        GeometryReader { geometry in
            if geometry.size.height < self.thresholdHeight {
                ScrollView {
                    self.embeddedView
                }
            } else {
                self.embeddedView
            }
        }
    }
}
