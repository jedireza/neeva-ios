//
//  NeevaUIConstants.swift
//  Client
//
//  Created by Stuart Allen on 13/03/21.
//  Copyright © 2021 Mozilla. All rights reserved.
//

import Foundation

struct NeevaUIConstants{
    /// Constant set for Menu UI
    static let menuCornerDefault:CGFloat = 10
    static let menuOuterPadding:CGFloat = 12
    static let menuInnerPadding:CGFloat = 8
    static let menuRowPadding:CGFloat = 2
    static let menuMaxWidth:CGFloat = 310
    static let menuMaxHeight:CGFloat = 310
    static let menuButtonMaxWidth:CGFloat = 75
    static let menuHorizontalSpacing:CGFloat = 8
    
    static let menuButtonFontSize:CGFloat = 13
    static let menuFontSize:CGFloat = 16
    static let trackingMenuBlockedFontSize:CGFloat = 18
    static let trackingMenuFontSize:CGFloat = 10
    static let trackingMenuSubtextFontSize:CGFloat = 8
}

public enum NeevaMenuButtonActions{
    case home
    case spaces
    case settings
    case history
    case downloads
    case feedback
    case privacyPolicy
    case helpCenter
    case signOut
}

public enum TrackingMenuButtonActions{
    case incognito
    case tracking
}
