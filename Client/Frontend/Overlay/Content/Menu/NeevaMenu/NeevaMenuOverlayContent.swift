// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import SwiftUI

struct NeevaMenuOverlayContent: View {
    @Environment(\.hideOverlay) private var hideOverlay

    let menuAction: (NeevaMenuAction) -> Void
    let isIncognito: Bool

    var body: some View {
        NeevaMenuView { action in
            menuAction(action)
            hideOverlay()
        }
        .environmentObject(IncognitoModel(isIncognito: isIncognito))
        .overlayIsFixedHeight(isFixedHeight: true)
    }
}
