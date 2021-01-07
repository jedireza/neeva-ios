import SwiftUI

extension Color {
    static let spaceIconBackground = Color("SpaceIconBackground", bundle: .module)
    static let savedForLaterIcon = Color("SavedForLaterIcon", bundle: .module)
    static let letterAvatarBackground = Color("LetterAvatarBackground", bundle: .module)
}

extension Color {
    static let purpleVariant = Color("purple-variant", bundle: .module)
    static let gray96 = Color("gray-96", bundle: .module)
    static let gray80 = Color("gray-80", bundle: .module)
    static let overlayBlue = Color("overlay-blue", bundle: .module)
}

func firstCharacters(_ count: Int, from str: String) -> String {
    if str.count <= count {
        return str.uppercased()
    } else {
        return str[..<str.index(str.startIndex, offsetBy: count)].uppercased()
    }
}
