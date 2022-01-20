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

    @Published private(set) var pickerHeight: CGFloat = UIConstants
        .TopToolbarHeightWithToolbarButtonsShowing
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
    @Published private(set) var refreshDetailedSpaceSubscription: AnyCancellable? = nil
    @Published var showingDetailView = false
    @Published var dragOffset: CGFloat? = nil

    private let tabMenu: TabMenu

    var animateDetailTransitions = true

    @Published var needsScrollToSelectedTab: Int = 0

    init(tabManager: TabManager) {
        let tabGroupManager = TabGroupManager(tabManager: tabManager)
        self.tabCardModel = TabCardModel(manager: tabManager, groupManager: tabGroupManager)
        self.tabGroupCardModel = TabGroupCardModel(manager: tabGroupManager)
        self.spaceCardModel = SpaceCardModel()

        self.tabMenu = TabMenu(tabManager: tabManager)
    }

    func scrollToSelectedTab() {
        needsScrollToSelectedTab += 1
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

    func switchToTabs(incognito: Bool) {
        switcherState = .tabs

        if tabCardModel.manager.isIncognito != incognito {
            tabCardModel.manager.toggleIncognitoMode(fromTabTray: true, openLazyTab: false)
        }
    }

    func switchToSpaces() {
        switcherState = .spaces

        if tabCardModel.manager.isIncognito {
            tabCardModel.manager.toggleIncognitoMode(fromTabTray: true, openLazyTab: false)
        }
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
