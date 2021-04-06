//
//  NeevaExtensions.swift
//  Client
//
//  Created by Stuart Allen on 13/03/21.
//  Copyright © 2021 Mozilla. All rights reserved.
//

import SwiftUI

extension Color {
    /// Constant set for General UI
    static var transparent:Color { Color.gray.opacity(0) }

    /// Constants to Neeva Home UI
    static var homeSectionTitleColor: Color { Color(red: 0.554, green: 0.581, blue: 0.6, opacity: 1) }
    static var homeSectionCollapseButtonBackgroundColor: Color { Color(red: 0.976, green: 0.98, blue: 0.965, opacity: 1) }
    static var topSitesNameColor: Color { Color(red: 0.554, green: 0.581, blue: 0.6, opacity: 1) }
    static var searchesIconsColor: Color { Color(red: 0.651, green: 0.69, blue: 0.698, opacity: 1) }
    static var searchesKeyWordsColor: Color { Color(red: 0.267, green: 0.274, blue: 0.3, opacity: 1) }
    static var spacesNameColor: Color { Color(red: 0.267, green: 0.274, blue: 0.3, opacity: 1) }
}

extension Font {
    static var homeSectionTitleFont: Font { Font.custom("Roobert-SemiBold", size: 13) }
    static var topSitesNameFont: Font { Font.custom("SFProText-Regular", size: 14) }
    static var searchesIconsFont: Font{ Font.custom("SFProText-Medium", size: 16) }
    static var searchesKeyWordsFont: Font { Font.custom("SFProText-Regular", size: 16.0) }
    static var spacesNameFont: Font { Font.custom("SFProText-Regular", size: 16) }
}

