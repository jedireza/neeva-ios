// Copyright Neeva. All rights reserved.

import Foundation
import Shared

class GridModel: ObservableObject {
    @Published var isHidden = true
    @Published var animationThumbnailState: AnimationThumbnailState = .hidden
    @Published var pickerHeight: CGFloat = UIConstants.TopToolbarHeightWithToolbarButtonsShowing
    @Published var switcherState: SwitcherViews = .tabs {
        didSet {
            if case .spaces = switcherState {
                ClientLogger.shared.logCounter(
                    .SpacesUIVisited,
                    attributes: EnvironmentHelper.shared.getAttributes())
            }
        }
    }

    private var updateVisibility: ((Bool) -> Void)!
    var buildCloseAllTabsMenu: (() -> UIMenu)!
    var buildRecentlyClosedTabsMenu: (() -> UIMenu)!
    var animateDetailTransitions = true

    /// The cached location of all loaded `Card`s relative to `coordinateSpaceName`
    @Published var cardFrames: [String: CGRect] = [:]
    let coordinateSpaceName: String = UUID().uuidString

    @Published var needsScrollToSelectedTab: Int = 0

    func scrollToSelectedTab() {
        needsScrollToSelectedTab += 1
    }

    func show() {
        animationThumbnailState = .visibleForTrayShow
        updateVisibility(false)
        updateSpaces()
    }

    func showWithNoAnimation() {
        animationThumbnailState = .hidden
        isHidden = false
        updateVisibility(false)
        updateSpaces()
    }

    func showSpaces(forceUpdate: Bool = true) {
        animationThumbnailState = .hidden
        switcherState = .spaces
        isHidden = false
        updateVisibility(false)
        if forceUpdate {
            updateSpaces()
        }
    }

    func hideWithAnimation() {
        self.animationThumbnailState = .visibleForTrayHidden
    }

    func hideWithNoAnimation() {
        animationThumbnailState = .hidden
        updateVisibility(true)
        isHidden = true
        switcherState = .tabs
        animateDetailTransitions = true
    }

    func setVisibilityCallback(updateVisibility: @escaping (Bool) -> Void) {
        self.updateVisibility = updateVisibility
    }

    private func updateSpaces() {
        // In preparation for the CardGrid being shown soon, refresh spaces.
        DispatchQueue.main.async {
            SpaceStore.shared.refresh()
        }
    }
}

enum AnimationThumbnailState {
    case hidden
    case visibleForTrayShow
    case visibleForTrayHidden
}
