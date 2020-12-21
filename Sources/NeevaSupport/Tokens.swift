import SwiftUI

extension Color {
    static let spaceIconBackground = Color("SpaceIconBackground", bundle: .module)
    static let savedForLaterIcon = Color("SavedForLaterIcon", bundle: .module)
}

extension Color {
    static let purpleVariant = Color("purple-variant", bundle: .module)
    static let gray96 = Color("gray-96", bundle: .module)
}

extension Font {
    static var titleTwo: Font {
        if #available(iOS 14.0, *) {
            return .title2
        } else {
            return .title
        }
    }
}
