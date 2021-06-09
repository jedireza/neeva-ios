// Copyright Neeva. All rights reserved.

import SwiftUI

fileprivate extension Font.Weight {
    var roobertName: String {
        switch self {
        case .light, .ultraLight, .thin:
            return "Roobert-Light"
        case .regular:
            return "Roobert-Regular"
        case .medium:
            return "Roobert-Medium"
        case .semibold:
            return "Roobert-SemiBold"
        case .bold:
            return "Roobert-Bold"
        case .heavy, .black:
            return "Roobert-Heavy"
        default:
            print("Unsupported Font.Weight: \(self)")
            return "Roobert-Regular"
        }
    }
}

extension Font {
    static func roobert(_ weight: Font.Weight = .regular, size: CGFloat) -> Self {
        custom(weight.roobertName, size: size)
    }
    static func roobert(_ weight: Font.Weight = .regular, size: CGFloat, relativeTo textStyle: TextStyle) -> Self {
        custom(weight.roobertName, size: size, relativeTo: textStyle)
    }
    static func roobert(_ weight: Font.Weight = .regular, fixedSize size: CGFloat) -> Self {
        custom(weight.roobertName, fixedSize: size)
    }
}
