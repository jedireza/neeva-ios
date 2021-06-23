// Copyright Neeva. All rights reserved.

import SwiftUI

extension Color {
    public init(light: Color, dark: Color) {
        self.init(UIColor(light: UIColor(light), dark: UIColor(dark)))
    }

    /// Create a `Color` with the given hex code
    ///
    /// ```
    /// Color(hex: 0xff0000) // red
    /// ```
    ///
    /// Source: [Stack Overflow](https://stackoverflow.com/a/56894458/5244995)
    init(hex: UInt, opacity: Double = 1) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xff) / 255,
            green: Double((hex >> 08) & 0xff) / 255,
            blue: Double((hex >> 00) & 0xff) / 255,
            opacity: opacity
        )
    }

    /// Create a `Color` with the given hex code
    ///
    /// ```
    /// Image(...).foregroundColor(.hex(0xff0000))
    /// ```
    static func hex(_ hex: UInt, opacity: Double = 1) -> Color {
        Color(hex: hex, opacity: opacity)
    }
}
