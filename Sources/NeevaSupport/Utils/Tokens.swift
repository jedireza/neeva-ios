import SwiftUI

extension Color {
    // source https://stackoverflow.com/a/56894458/5244995
    init(hex: UInt, opacity: Double = 1) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xff) / 255,
            green: Double((hex >> 08) & 0xff) / 255,
            blue: Double((hex >> 00) & 0xff) / 255,
            opacity: opacity
        )
    }

    static func hex(_ hex: UInt, opacity: Double = 1) -> Color {
        Color(hex: hex, opacity: opacity)
    }
}

extension Color {
    static let spaceIconBackground = Color(hex: 0xACE0EA)
    static let savedForLaterIcon = Color(hex: 0xFF8852)
    static let letterAvatarBackground = Color(hex: 0x415AFF)
}

extension Color {
    static let purpleVariant = Color("purple-variant", bundle: .module)
    static let gray96 = Color("gray-96", bundle: .module)
    static let gray80 = Color("gray-80", bundle: .module)
    static let overlayBlue = Color("overlay-blue", bundle: .module)
}

extension Color {
    static let groupedBackground = Color(UIColor.systemGroupedBackground)
}

extension Gradient {
    static let skeleton = Gradient(colors: [.hex(0xf1f3ef), .hex(0xfbfbf9)])
}

func firstCharacters(_ count: Int, from str: String) -> String {
    if str.count <= count {
        return str.uppercased()
    } else {
        return str[..<str.index(str.startIndex, offsetBy: count)].uppercased()
    }
}
