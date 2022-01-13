// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Combine
import Foundation
import Shared
import SwiftUI

class GridModel: ObservableObject {
    let tabCardModel: TabCardModel
    let tabGroupCardModel: TabGroupCardModel
    let spaceCardModel: SpaceCardModel
    let browserModel: BrowserModel

    @Published var isHidden = true
    @Published var animationThumbnailState: AnimationThumbnailState = .hidden
    @Published private(set) var pickerHeight: CGFloat = UIConstants
        .TopToolbarHeightWithToolbarButtonsShowing
    @Published private(set) var isLoading = false
    @Published var switcherState: SwitcherViews = .tabs {
        didSet {
            if case .spaces = switcherState {
                ClientLogger.shared.logCounter(
                    .SpacesUIVisited,
                    attributes: EnvironmentHelper.shared.getAttributes())
            }
        }
    }
    @Published private(set) var refreshDetailedSpaceSubscription: AnyCancellable? = nil
    @Published var showingDetailView = false
    @Published var dragOffset: CGFloat? = nil

    private let tabMenu: TabMenu

    var isIncognito: Bool {
        tabCardModel.manager.isIncognito
    }

    private var followPublicSpaceSubscription: AnyCancellable? = nil

    private var updateVisibility: ((Bool) -> Void)!
    var animateDetailTransitions = true

    @Published var needsScrollToSelectedTab: Int = 0

    init(tabManager: TabManager, browserModel: BrowserModel) {
        let tabGroupManager = TabGroupManager(tabManager: tabManager)
        self.tabCardModel = TabCardModel(manager: tabManager, groupManager: tabGroupManager)
        self.tabGroupCardModel = TabGroupCardModel(manager: tabGroupManager)
        self.spaceCardModel = SpaceCardModel()
        self.browserModel = browserModel

        self.tabMenu = TabMenu(tabManager: tabManager)
    }

    func scrollToSelectedTab() {
        needsScrollToSelectedTab += 1
    }

    func show() {
        if tabCardModel.allDetails.isEmpty {
            showWithNoAnimation()
        } else {
            if FeatureFlag[.enableBrowserView] {
                withAnimation(.easeOut(duration: 0.2)) {
                    browserModel.currentState = .switcher
                    isHidden = false
                }
            } else {
                animationThumbnailState = .visibleForTrayShow
                updateVisibility(false)
                updateSpaces()
            }
        }
    }

    func showWithNoAnimation() {
        if FeatureFlag[.enableBrowserView] {
            browserModel.currentState = .switcher
        } else {
            animationThumbnailState = .hidden
            updateVisibility(false)
            updateSpaces()
        }

        isHidden = false
    }

    func showSpaces(forceUpdate: Bool = true) {
        if FeatureFlag[.enableBrowserView] {
            browserModel.currentState = .switcher
        } else {
            animationThumbnailState = .hidden
            updateVisibility(false)
        }

        isHidden = false
        switcherState = .spaces

        if forceUpdate {
            updateSpaces()
        }
    }

    func hideWithAnimation() {
        assert(!tabCardModel.allDetails.isEmpty)

        if FeatureFlag[.enableBrowserView] {
            withAnimation(.easeOut(duration: 0.2)) {
                browserModel.currentState = .tab
                switcherState = .tabs
                isHidden = true
            }
        } else {
            self.animationThumbnailState = .visibleForTrayHidden
        }
    }

    func hideWithNoAnimation() {
        if FeatureFlag[.enableBrowserView] {
            browserModel.currentState = .tab
        } else {
            animationThumbnailState = .hidden
            updateVisibility(true)
            animateDetailTransitions = true
        }

        isHidden = true
        switcherState = .tabs
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

    func openSpace(spaceID: String?, animate: Bool = true) {
        withAnimation(nil) {
            showSpaces(forceUpdate: false)
        }

        animateDetailTransitions = animate

        guard let spaceID = spaceID,
            let detail = spaceCardModel.allDetails.first(where: { $0.id == spaceID })
        else {
            return
        }

        detail.isShowingDetails = true
    }

    func openTabGroup(detail: TabGroupCardDetails) {
        tabGroupCardModel.detailedTabGroup = detail
        show()
    }

    func switchToTabs(incognito: Bool) {
        switcherState = .tabs

        if isIncognito != incognito {
            tabCardModel.manager.toggleIncognitoMode(fromTabTray: true, openLazyTab: false)
        }
    }

    func switchToSpaces() {
        switcherState = .spaces
    }

    func buildCloseAllTabsMenu(sourceView: UIView) -> UIMenu {
        if switcherState == .tabs {
            return UIMenu(sections: [[tabMenu.createCloseAllTabsAction(sourceView: sourceView)]])
        } else {
            return UIMenu()
        }
    }

    func buildRecentlyClosedTabsMenu() -> UIMenu {
        tabMenu.createRecentlyClosedTabsMenu()
    }
}

enum AnimationThumbnailState {
    case hidden
    case visibleForTrayShow
    case visibleForTrayHidden
}
