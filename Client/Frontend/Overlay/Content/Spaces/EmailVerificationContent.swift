// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Combine
import Shared
import SwiftUI

struct EmailVerificationContent: View {
    @Environment(\.hideOverlay) private var hideOverlay

    var body: some View {
        EmailVerificationPrompt(email: NeevaUserInfo.shared.email ?? "", dismiss: hideOverlay)
            .overlayIsFixedHeight(isFixedHeight: true)
    }
}
