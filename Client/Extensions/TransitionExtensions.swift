// Copyright Neeva. All rights reserved.

import SwiftUI

private struct PageOverlayTransition: ViewModifier {
    let visible: Bool

    func body(content: Content) -> some View {
        ZStack {
            Color(UIColor.HomePanel.topSitesBackground)
            content
                .opacity(visible ? 1 : 0)
                .scaleEffect(visible ? 1 : 0.85)
                .blur(radius: visible ? 0 : 10)
                .saturation(visible ? 1 : 0)
        }
        .opacity(visible ? 1 : 0)
    }
}

extension AnyTransition {
    static let pageOverlay = AnyTransition.modifier(
        active: PageOverlayTransition(visible: false),
        identity: PageOverlayTransition(visible: true))
}
