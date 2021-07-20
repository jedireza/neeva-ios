// Copyright Neeva. All rights reserved.

import SwiftUI

struct OverlayGroupCell<Content: View>: View {
    let content: () -> Content
    var body: some View {
        content()
            .background(Color.secondaryGroupedBackground)
            .cornerRadius(12)
    }
}
