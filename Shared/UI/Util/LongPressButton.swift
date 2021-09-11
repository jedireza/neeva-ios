// Copyright Neeva. All rights reserved.

import SwiftUI

public struct LongPressButton<Label: View>: View {
    let action: () -> Void
    let longPressAction: (() -> Void)?
    let label: () -> Label

    @State private var didLongPress = false

    public init(
        action: @escaping () -> Void,
        longPressAction: (() -> Void)? = nil,
        @ViewBuilder label: @escaping () -> Label
    ) {
        self.action = action
        self.longPressAction = longPressAction
        self.label = label
    }

    public var body: some View {
        Button(action: {
            if !didLongPress {
                action()
            }
            didLongPress = false
        }) {
            label()
        }
        .simultaneousGesture(
            LongPressGesture().onEnded { _ in
                if let longPressAction = longPressAction {
                    longPressAction()
                    Haptics.longPress()
                    didLongPress = true
                }
            }
        )
    }
}
