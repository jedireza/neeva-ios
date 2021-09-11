// Copyright Neeva. All rights reserved.

import UIKit

public class Haptics {
    public static func longPress() {
        guard FeatureFlag[.haptics] else { return }

        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
    }

    public static func swipeGesture() {
        guard FeatureFlag[.haptics] else { return }

        let generator = UIImpactFeedbackGenerator(style: .heavy)
        generator.impactOccurred()
    }
}
