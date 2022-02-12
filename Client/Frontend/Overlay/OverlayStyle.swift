// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Foundation
import Shared

public struct OverlayStyle {
    let showTitle: Bool
    let backgroundColor: UIColor
    let nonDismissible: Bool  // disable dismiss modal by clicking the gray black
    let embedScrollView: Bool

    init(
        showTitle: Bool, backgroundColor: UIColor = .DefaultBackground, nonDismissible: Bool = false, embedScrollView: Bool = true
    ) {
        self.showTitle = showTitle
        self.backgroundColor = backgroundColor
        self.nonDismissible = nonDismissible
        self.embedScrollView = embedScrollView
    }

    /// Use for sheets containing grouped sets of controls (e.g., like the Overflow menu).
    static let grouped = OverlayStyle(
        showTitle: false,
        backgroundColor: .systemGroupedBackground.elevated)

    static let spaces = OverlayStyle(
        showTitle: false,
        backgroundColor: .DefaultBackground
    )

    static let cheatsheet = OverlayStyle(
        showTitle: false,
        backgroundColor: .DefaultBackground
    )

    static let nonScrollableMenu = OverlayStyle(
        showTitle: false,
        backgroundColor: .systemGroupedBackground.elevated,
        embedScrollView: false
    )

    /// Use for sheets with a title (e.g., like the AddToSpaces sheet).
    static let withTitle = OverlayStyle(showTitle: true)
}
