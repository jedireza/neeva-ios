// Copyright Neeva. All rights reserved.

import Combine
import Foundation
import Shared
import SwiftUI

class GridModel: ObservableObject {
    let tabCardModel: TabCardModel
    let tabGroupCardModel: TabGroupCardModel
    let spaceCardModel: SpaceCardModel

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

    var isIncognito: Bool {
        tabCardModel.manager.isIncognito
    }

    private var followPublicSpaceSubscription: AnyCancellable? = nil

    private var updateVisibility: ((Bool) -> Void)!
    var buildCloseAllTabsMenu: (() -> UIMenu)!
    var buildRecentlyClosedTabsMenu: (() -> UIMenu)!
    var animateDetailTransitions = true

    @Published var needsScrollToSelectedTab: Int = 0

    init(tabManager: TabManager) {
        let tabGroupManager = TabGroupManager(tabManager: tabManager)
        self.tabCardModel = TabCardModel(manager: tabManager, groupManager: tabGroupManager)
        self.tabGroupCardModel = TabGroupCardModel(manager: tabGroupManager)
        self.spaceCardModel = SpaceCardModel()
    }

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

    func openSpace(spaceId: String, bvc: BrowserViewController, completion: @escaping () -> Void) {
        SpaceStore.openSpace(spaceId: spaceId) { [weak self] in
            let spaceCardModel = bvc.gridModel.spaceCardModel
            if let _ = spaceCardModel.allDetails.first(where: { $0.id == spaceId }) {
                bvc.gridModel.openSpace(spaceID: spaceId, animate: false)
                completion()
            } else {
                guard let self = self else { return }
                self.followPublicSpaceSubscription = spaceCardModel.objectWillChange.sink {
                    if let _ = spaceCardModel.allDetails.first(where: { $0.id == spaceId }) {
                        bvc.gridModel.openSpace(
                            spaceID: spaceId, animate: false)
                        completion()
                        self.followPublicSpaceSubscription?.cancel()
                    }
                }
            }
        }
    }

    func openSpace(spaceID: String, animate: Bool = true) {
        let detail = spaceCardModel.allDetails.first(where: { $0.id == spaceID })
        withAnimation(nil) {
            showSpaces(forceUpdate: false)
        }
        animateDetailTransitions = animate
        detail?.isShowingDetails = true
    }

    func openTabGroup(detail: TabGroupCardDetails) {
        tabGroupCardModel.detailedTabGroup = detail
        show()
    }
}

enum AnimationThumbnailState {
    case hidden
    case visibleForTrayShow
    case visibleForTrayHidden
}
