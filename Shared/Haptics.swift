// Copyright Neeva. All rights reserved.

import UIKit

public class Haptics {
    public static func longPress() {
        custom(style: .medium)
    }

    public static func swipeGesture() {
        custom(style: .rigid)
    }

    public static func custom(style: UIImpactFeedbackGenerator.FeedbackStyle) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.impactOccurred()
    }
}
