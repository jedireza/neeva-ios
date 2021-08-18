// Copyright Neeva. All rights reserved.

import Foundation

class GridModel: ObservableObject {
    @Published var isHidden = true
    @Published var animationThumbnailState: AnimationThumbnailState = .visibleForTrayShown
    @Published var pickerHeight: CGFloat = UIConstants.TopToolbarHeightWithToolbarButtonsShowing
    @Published var switcherState: SwitcherViews = .tabs
    @Published var showingDetailsAsList = true

    private var updateVisibility: ((Bool) -> Void)!
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
        switcherState = .tabs
    }

    func setVisibilityCallback(updateVisibility: @escaping (Bool) -> Void) {
        self.updateVisibility = updateVisibility
    }
}

enum AnimationThumbnailState {
    case visibleForTrayShown
    case hidden
    case visibleForTrayHidden
}
