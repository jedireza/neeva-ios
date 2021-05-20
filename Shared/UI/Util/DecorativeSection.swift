// Copyright Neeva. All rights reserved.

import SwiftUI

/// An alternative to `Section { ... }` that doesn’t render an empty view
/// for VoiceOver users to swipe past
struct DecorativeSection<Content: View>: View {
    let content: () -> Content
    init(@ViewBuilder _ content: @escaping () -> Content) {
        self.content = content
    }
    var body: some View {
        Section(header: EmptyView().accessibilityHidden(true), content: content)
    }
}
