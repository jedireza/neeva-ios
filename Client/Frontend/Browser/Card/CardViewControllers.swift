// Copyright Neeva. All rights reserved.

import Foundation
import Shared
import SnapKit
import SwiftUI

public enum CardControllerUX {
    static let BottomPadding: CGFloat = 50
    static let HandleWidth: CGFloat = 50
}

class CardGridViewController: UIHostingController<CardGridViewController.Content> {
    struct Content: View {
        let tabCardModel: TabCardModel
        let tabGroupCardModel: TabGroupCardModel
        let spaceCardModel: SpaceCardModel
        let gridModel: GridModel
        let toolbarModel: SwitcherToolbarModel

        var body: some View {
            CardGrid()
                .environmentObject(toolbarModel)
                .environmentObject(tabCardModel)
                .environmentObject(spaceCardModel)
                .environmentObject(tabGroupCardModel)
                .environmentObject(gridModel)
                .environment(\.onOpenURL, tabCardModel.manager.createOrSwitchToTab(for:))
        }
    }

    var leadingConstraint: Constraint? = nil
    let gridModel = GridModel()

    init(bvc: BrowserViewController) {
        let tabGroupManager = TabGroupManager(tabManager: bvc.tabManager)
        super.init(
            rootView: Content(
                tabCardModel: TabCardModel(manager: bvc.tabManager, groupManager: tabGroupManager),
                tabGroupCardModel: TabGroupCardModel(manager: tabGroupManager),
                spaceCardModel: SpaceCardModel(bvc: bvc),
                gridModel: gridModel,
                toolbarModel: SwitcherToolbarModel(tabManager: bvc.tabManager, openLazyTab: { bvc.openLazyTab(openedFrom: .tabTray) })
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
            let tabMenu = TabMenu(tabManager: bvc.tabManager, alertPresentViewController: self)
            return tabMenu.createCloseAllTabsMenu(fromTabTray: true)
        }
        gridModel.buildRecentlyClosedTabsMenu = {
            let tabMenu = TabMenu(tabManager: bvc.tabManager, alertPresentViewController: self)
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
    @ObservedObject var cardStripModel: CardStripModel

    var width: CGFloat

    var body: some View {
        VStack {
            Spacer()

            CardStripView()
                .environmentObject(tabCardModel)
                .environmentObject(spaceCardModel)
                .environmentObject(sitesCardModel)
                .environmentObject(cardStripModel)
                .offset(x: cardStripModel.isVisible ? 0 : width - 50)
        }
    }

    init(bvc: BrowserViewController, width: CGFloat) {
        let tabManager = bvc.tabManager

        self.tabCardModel = TabCardModel(manager: tabManager, groupManager: TabGroupManager(tabManager: tabManager))
        self.spaceCardModel = SpaceCardModel(bvc: bvc)
        self.sitesCardModel = SiteCardModel(urls: [], tabManager: tabManager)
        self.cardStripModel = CardStripModel(tabManager: tabManager)
        self.width = width
    }
}
