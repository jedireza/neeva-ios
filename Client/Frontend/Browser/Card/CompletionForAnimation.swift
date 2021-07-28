// Copyright Neeva. All rights reserved.

import SwiftUI

private struct CompletionForAnimation: AnimatableModifier {
    var targetValue: Double

    var animatableData: Double {
        didSet {
            maybeRunCompletion()
        }
    }

    var afterTrueToFalse: () -> Void
    var afterFalseToTrue: () -> Void

    init(
        toggleValue: Bool,
        afterTrueToFalse: @escaping () -> Void, afterFalseToTrue: @escaping () -> Void
    ) {
        self.afterTrueToFalse = afterTrueToFalse
        self.afterFalseToTrue = afterFalseToTrue

        self.animatableData = toggleValue ? 1 : 0
        self.targetValue = toggleValue ? 1 : 0
    }

    func maybeRunCompletion() {
        if animatableData == targetValue {
            DispatchQueue.main.async {
                targetValue == 1 ? self.afterFalseToTrue() : self.afterTrueToFalse()
            }
        }
    }

    func body(content: Content) -> some View {
        content
    }
}

extension View {
    func runAfter(
        toggling: Bool,
        fromTrueToFalse: @escaping () -> Void = {},
        fromFalseToTrue: @escaping () -> Void = {}
    ) -> some View {
        self.modifier(
            CompletionForAnimation(
                toggleValue: toggling,
                afterTrueToFalse: fromTrueToFalse,
                afterFalseToTrue: fromFalseToTrue))
    }
}
