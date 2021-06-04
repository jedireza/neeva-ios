// Copyright Neeva. All rights reserved.

import SwiftUI

extension Color {
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

extension Color {
    public static let spaceIconBackground = Color(hex: 0xACE0EA)
    public static let savedForLaterIcon = Color(hex: 0xFF8852)
    public static let letterAvatarBackground = Color(hex: 0x415AFF)
}

extension Color {
    public static let systemFill = Color(UIColor.systemFill)
    public static let secondarySystemFill = Color(UIColor.secondarySystemFill)
    public static let tertiarySystemFill = Color(UIColor.tertiarySystemFill)
    public static let quaternarySystemFill = Color(UIColor.quaternarySystemFill)

    public static let secondaryLabel = Color(UIColor.secondaryLabel)
    public static let tertiaryLabel = Color(UIColor.tertiaryLabel)
}

extension Image {
    // TODO: fix on non-app targets
    public static let neevaLogo = Image("neeva-logo", bundle: .main)
}

extension Color {
    public static let background = Color(UIColor.systemBackground)
    public static let groupedBackground = Color(UIColor.systemGroupedBackground)
}

extension Gradient {
    public static let skeleton = Gradient(colors: [.hex(0xf1f3ef), .hex(0xfbfbf9)])
}

/// Return the first `count` characters from the provided string, uppercased.
public func firstCharacters(_ count: Int, from str: String) -> String {
    if str.count <= count {
        return str.uppercased()
    } else {
        return str[..<str.index(str.startIndex, offsetBy: count)].uppercased()
    }
}
