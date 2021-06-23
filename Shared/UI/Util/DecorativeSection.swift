// Copyright Neeva. All rights reserved.

import SwiftUI

/// An alternative to `Section { ... }` that doesn’t render an empty view
/// for VoiceOver users to swipe past
public struct DecorativeSection<Content: View, Footer: View>: View {
    let content: () -> Content
    let footer: (() -> Footer)?

    public init(@ViewBuilder content: @escaping () -> Content, @ViewBuilder footer: @escaping () -> Footer) {
        self.content = content
        self.footer = footer
    }

    public var body: some View {
        if let footer = footer {
            Section(header: Text("").accessibilityHidden(true), footer: footer(), content: content)
        } else {
            Section(header: Text("").accessibilityHidden(true), content: content)
        }
    }
}

extension DecorativeSection where Footer == Never {
    public init(@ViewBuilder _ content: @escaping () -> Content) {
        self.content = content
        self.footer = nil
    }
}

extension DecorativeSection where Footer == Text {
    public init(footer: String, @ViewBuilder _ content: @escaping () -> Content) {
        self.content = content
        self.footer = { Text(footer) }
    }
}
