// Copyright Neeva. All rights reserved.

import Foundation

class GridModel: ObservableObject {
    @Published var isHidden = true
    @Published var animationThumbnailState: AnimationThumbnailState = .visibleForTrayShown
    private var updateVisibility: ((Bool) -> ())!
    var scrollOffset: CGFloat = CGFloat.zero
    var buildCloseAllTabsMenu: (() -> UIMenu)!
    var buildRecentlyClosedTabsMenu: (() -> UIMenu)!

    func show() {
        animationThumbnailState = .visibleForTrayShown
        isHidden = false
        updateVisibility(false)
    }

    func hideWithNoAnimation() {
        updateVisibility(true)
        isHidden = true
        animationThumbnailState = .visibleForTrayShown
    }

    func setVisibilityCallback(updateVisibility: @escaping (Bool) -> ()) {
        self.updateVisibility = updateVisibility
    }
}


enum AnimationThumbnailState {
    case visibleForTrayShown
    case hidden
    case visibleForTrayHidden
}
