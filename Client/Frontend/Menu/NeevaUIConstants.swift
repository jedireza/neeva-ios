// Copyright Neeva. All rights reserved.

import Foundation

struct NeevaUIConstants{
    /// Constant set for Menu UI
    static let menuCornerDefault:CGFloat = 12
    static let menuOuterPadding:CGFloat = 16
    static let menuInnerPadding:CGFloat = 12
    static let menuSectionPadding: CGFloat = 12
    static let menuInnerSectionPadding: CGFloat = 8

    static let buttonInnerPadding: CGFloat = 16
    
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
