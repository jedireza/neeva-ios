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
    @Published var isLoading = false
    @Published var switcherState: SwitcherViews = .tabs {
        didSet {
            if case .spaces = switcherState {
                ClientLogger.shared.logCounter(
                    .SpacesUIVisited,
                    attributes: EnvironmentHelper.shared.getAttributes())
            }
        }
    }
    @Published var refreshDetailedSpaceSubscription: AnyCancellable? = nil
    var cardStripModel = CardStripModel()

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
        if tabCardModel.allDetails.isEmpty {
            showWithNoAnimation()
        } else {
            animationThumbnailState = .visibleForTrayShow
            updateVisibility(false)
            updateSpaces()
        }
    }

    func showWithNoAnimation() {
        animationThumbnailState = .hidden
        isHidden = false
        updateVisibility(false)
        updateSpaces()
        cardStripModel.setVisible(to: false)
    }

    func showSpaces(forceUpdate: Bool = true) {
        animationThumbnailState = .hidden
        switcherState = .spaces
        isHidden = false
        updateVisibility(false)
        if forceUpdate {
            updateSpaces()
        }
        cardStripModel.setVisible(to: false)
    }

    func hideWithAnimation() {
        assert(!tabCardModel.allDetails.isEmpty)
        self.animationThumbnailState = .visibleForTrayHidden
        cardStripModel.setVisible(to: true)
    }

    func hideWithNoAnimation() {
        animationThumbnailState = .hidden
        updateVisibility(true)
        isHidden = true
        switcherState = .tabs
        animateDetailTransitions = true
        cardStripModel.setVisible(to: true)
    }

    func onCompletedCardTransition() {
        if isHidden {
            hideWithNoAnimation()
            animateDetailTransitions = false
            tabGroupCardModel.detailedTabGroup = nil
        } else {
            animationThumbnailState = .hidden
            animateDetailTransitions = true
        }
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

    func openSpace(
        spaceId: String, bvc: BrowserViewController, isPrivate: Bool = false,
        completion: @escaping () -> Void
    ) {
        if !NeevaUserInfo.shared.hasLoginCookie() {
            var spaceURL = NeevaConstants.appSpacesURL
            spaceURL.appendPathComponent(spaceId)
            bvc.switchToTabForURLOrOpen(spaceURL, isPrivate: isPrivate)
            return
        }
        let existingSpace = spaceCardModel.allDetails.first(where: { $0.id == spaceId })
        DispatchQueue.main.async { [self] in
            if isIncognito {
                bvc.tabManager.toggleIncognitoMode()
            }

            if let existingSpace = existingSpace {
                openSpace(spaceID: existingSpace.id)
                refreshDetailedSpace()
            } else {
                bvc.showTabTray()
                switcherState = .spaces

                isLoading = true
            }
        }

        guard existingSpace == nil else {
            return
        }

        SpaceStore.openSpace(spaceId: spaceId) { [self] in
            let spaceCardModel = bvc.gridModel.spaceCardModel
            if let _ = spaceCardModel.allDetails.first(where: { $0.id == spaceId }) {
                self.isLoading = false
                bvc.gridModel.openSpace(spaceID: spaceId, animate: false)
                completion()
            } else {
                self.isLoading = false

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

    func refreshDetailedSpace() {
        guard let detailedSpace = spaceCardModel.detailedSpace else {
            return
        }

        refreshDetailedSpaceSubscription = detailedSpace.manager.$state.sink { state in
            if case .ready = state {
                if detailedSpace.manager.updatedSpacesFromLastRefresh.first?.id.id ?? ""
                    == detailedSpace.id
                {
                    detailedSpace.updateDetails()
                }
                self.refreshDetailedSpaceSubscription?.cancel()
                self.refreshDetailedSpaceSubscription = nil
            }
        }
        detailedSpace.manager.refreshSpace(spaceID: detailedSpace.id)

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
