// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import UIKit

public class Haptics {
    public static func longPress() {
        custom(style: .medium)
    }

    public static func swipeGesture() {
        custom(style: .rigid)
    }

    public static func selection() {
        UISelectionFeedbackGenerator().selectionChanged()
    }

    public static func custom(style: UIImpactFeedbackGenerator.FeedbackStyle) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.impactOccurred()
    }
}
