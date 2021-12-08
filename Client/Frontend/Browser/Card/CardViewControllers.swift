// Copyright Neeva. All rights reserved.

import Foundation
import Shared
import SnapKit
import SwiftUI

public enum CardControllerUX {
    static let BottomPadding: CGFloat = 50
    static let Height: CGFloat = 75
    static let HandleWidth: CGFloat = 50
}

class CardGridViewController: UIHostingController<CardGridViewController.Content> {
    struct Content: View {
        let gridModel: GridModel
        let toolbarModel: SwitcherToolbarModel
        let shareURL: (URL, UIView) -> Void

        var body: some View {
            CardGrid()
                .environmentObject(toolbarModel)
                .environmentObject(gridModel.tabCardModel)
                .environmentObject(gridModel.spaceCardModel)
                .environmentObject(gridModel.tabGroupCardModel)
                .environmentObject(gridModel)
                .environment(
                    \.onOpenURL, { gridModel.tabCardModel.manager.createOrSwitchToTab(for: $0) }
                )
                .environment(
                    \.onOpenURLForSpace,
                    {
                        gridModel.tabCardModel.manager.createOrSwitchToTabForSpace(
                            for: $0, spaceID: $1)
                    }
                )
                .environment(\.shareURL, shareURL)
        }
    }

    var leadingConstraint: Constraint? = nil
    let gridModel: GridModel
    let toolbarModel: SwitcherToolbarModel

    init(
        tabManager: TabManager, toolbarModel: SwitcherToolbarModel,
        shareURL: @escaping (URL, UIView) -> Void
    ) {
        self.gridModel = GridModel(tabManager: tabManager)
        self.toolbarModel = toolbarModel
        super.init(
            rootView: Content(
                gridModel: gridModel,
                toolbarModel: toolbarModel,
                shareURL: shareURL
            )
        )

        gridModel.setVisibilityCallback(updateVisibility: { isHidden in
            self.view.isHidden = isHidden
            self.view.isUserInteractionEnabled = !isHidden
            if !isHidden {
                self.parent?.view.bringSubviewToFront(self.view)
            }
        })
        gridModel.buildCloseAllTabsMenu = {
            if self.gridModel.switcherState == .tabs {
                let tabMenu = TabMenu(tabManager: tabManager, alertPresentViewController: self)
                return tabMenu.createCloseAllTabsMenu(fromTabTray: true)
            } else {
                return UIMenu(sections: [[]])
            }
        }
        gridModel.buildRecentlyClosedTabsMenu = {
            let tabMenu = TabMenu(tabManager: tabManager, alertPresentViewController: self)
            return tabMenu.createRecentlyClosedTabsMenu()
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .clear
        view.accessibilityViewIsModal = true
    }
}

struct CardStripContent: View {
    let tabCardModel: TabCardModel
    let spaceCardModel: SpaceCardModel
    let sitesCardModel: SiteCardModel
    let gridModel: GridModel

    @EnvironmentObject var cardStripModel: CardStripModel

    var body: some View {
        CardStripView()
            .environmentObject(tabCardModel)
            .environmentObject(spaceCardModel)
            .environmentObject(sitesCardModel)
            .environmentObject(gridModel)
            .frame(height: CardControllerUX.Height)
            .opacity(cardStripModel.isVisible ? 1 : 0.4)
            .animation(.easeOut)
            .transition(.identity)
    }

    init(bvc: BrowserViewController) {
        let tabManager = bvc.tabManager

        self.tabCardModel = TabCardModel(
            manager: tabManager, groupManager: TabGroupManager(tabManager: tabManager))
        self.spaceCardModel = SpaceCardModel()
        self.sitesCardModel = SiteCardModel(urls: [], tabManager: tabManager)
        self.gridModel = bvc.gridModel
    }
}
