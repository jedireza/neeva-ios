// Copyright Neeva. All rights reserved.

import Foundation

struct NeevaUIConstants{
    /// Constant set for Menu UI
    static let menuCornerDefault:CGFloat = 12
    static let menuOuterPadding:CGFloat = 16
    static let menuInnerPadding:CGFloat = 12
    static let menuRowPadding:CGFloat = 4
    static let menuMaxWidth:CGFloat = 338
    static let menuButtonMaxWidth:CGFloat = 160
    static let menuHorizontalSpacing:CGFloat = 8
    static let menuSectionPadding: CGFloat = 12
    static let menuInnerSectionPadding: CGFloat = 8

    static let buttonInnerPadding: CGFloat = 16
    
    static let menuButtonFontSize:CGFloat = 13
    static let menuFontSize:CGFloat = 20
    static let trackingMenuMaxHeight:CGFloat = 65
    static let trackingMenuBlockedFontSize:CGFloat = 24
    static let trackingMenuFontSize:CGFloat = 17
    static let trackingMenuSubtextFontSize:CGFloat = 8
    static let hallOfShameElementSpacing:CGFloat = 8
    static let hallOfShameElementFaviconSize:CGFloat = 25
    static let hallOfShameRowSpacing:CGFloat = 60
}

public enum NeevaMenuButtonActions{
    case home
    case spaces
    case settings
    case history
    case downloads
    case feedback
}

public enum FirstRunButtonActions {
    case signin
    case signup
    case skipToBrowser
}
