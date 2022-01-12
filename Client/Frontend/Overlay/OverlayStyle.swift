// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Foundation

public struct OverlayStyle {
    let showTitle: Bool
    let backgroundColor: UIColor
    let nonDismissible: Bool  // disable dismiss modal by clicking the gray black

    init(
        showTitle: Bool, backgroundColor: UIColor = .systemBackground, nonDismissible: Bool = false
    ) {
        self.showTitle = showTitle
        self.backgroundColor = backgroundColor
        self.nonDismissible = nonDismissible
    }

    /// Use for sheets containing grouped sets of controls (e.g., like the Overflow menu).
    static let grouped = OverlayStyle(
        showTitle: false, backgroundColor: .systemGroupedBackground)

    static let spaces = OverlayStyle(
        showTitle: false, backgroundColor: .DefaultBackground)

    /// Use for sheets with a title (e.g., like the AddToSpaces sheet).
    static let withTitle = OverlayStyle(showTitle: true)
}
