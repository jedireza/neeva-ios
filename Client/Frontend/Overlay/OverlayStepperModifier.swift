// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Shared
import SwiftUI

struct OverlayStepperButton: View {
    var action: () -> Void
    var symbol: Symbol
    var foregroundColor: Color

    var body: some View {
        Button(action: action) {
            symbol
                .frame(
                    width: GroupedCellUX.minCellHeight,
                    height: GroupedCellUX.minCellHeight
                )
                .foregroundColor(foregroundColor)
        }
    }
}

struct OverlayStepperAccessibilityModifier: ViewModifier {
    var accessibilityLabel: String
    var accessibilityValue: String?

    var increment: () -> Void
    var decrement: () -> Void

    func body(content: Content) -> some View {
        content
            .accessibilityLabel(accessibilityLabel)
            .accessibilityValue(accessibilityValue ?? "")
            .accessibilityAdjustableAction { action in
                switch action {
                case .increment: increment()
                case .decrement: decrement()
                @unknown default: break
                }
            }
    }
}
