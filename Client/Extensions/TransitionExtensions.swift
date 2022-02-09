// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

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
        .ignoresSafeArea(.container, edges: .bottom)
    }
}

extension AnyTransition {
    static let pageOverlay = AnyTransition.modifier(
        active: PageOverlayTransition(visible: false),
        identity: PageOverlayTransition(visible: true))
}
