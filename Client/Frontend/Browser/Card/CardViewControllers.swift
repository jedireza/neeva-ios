// Copyright Neeva. All rights reserved.

import Foundation
import Shared
import SnapKit
import SwiftUI

public enum CardControllerUX {
    static let BottomPadding: CGFloat = 50
    static let Height: CGFloat = 275
    static let HandleWidth: CGFloat = 50
}

class CardGridViewController: UIHostingController<CardGridViewController.Content> {
    struct Content: View {
        let tabCardModel: TabCardModel
        let tabGroupCardModel: TabGroupCardModel
        let spaceCardModel: SpaceCardModel
        let gridModel: GridModel
        let toolbarModel: SwitcherToolbarModel
        let shareURL: (URL) -> Void

        var body: some View {
            CardGrid()
                .environmentObject(toolbarModel)
                .environmentObject(tabCardModel)
                .environmentObject(spaceCardModel)
                .environmentObject(tabGroupCardModel)
                .environmentObject(gridModel)
                .environment(\.onOpenURL, tabCardModel.manager.createOrSwitchToTab(for:))
                .environment(\.shareURL, shareURL)
        }

        func openSpace(spaceID: String) {
            let detail = spaceCardModel.allDetails.first(where: { $0.id == spaceID })
            gridModel.showSpaces()
            detail?.isShowingDetails = true
        }
    }

    var leadingConstraint: Constraint? = nil
    let gridModel = GridModel()
    let toolbarModel: SwitcherToolbarModel

    init(bvc: BrowserViewController, toolbarModel: SwitcherToolbarModel) {
        let tabGroupManager = TabGroupManager(tabManager: bvc.tabManager)
        self.toolbarModel = toolbarModel
        let shareURL: (URL) -> Void = { url in
            let helper = ShareExtensionHelper(url: url, tab: nil)
            let controller = helper.createActivityViewController({ (_, _) in })
            controller.modalPresentationStyle = .formSheet
            bvc.present(controller, animated: true, completion: nil)
        }
        super.init(
            rootView: Content(
                tabCardModel: TabCardModel(manager: bvc.tabManager, groupManager: tabGroupManager),
                tabGroupCardModel: TabGroupCardModel(manager: tabGroupManager),
                spaceCardModel: SpaceCardModel(),
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
            let tabMenu = TabMenu(tabManager: bvc.tabManager, alertPresentViewController: self)
            return tabMenu.createCloseAllTabsMenu(fromTabTray: true)
        }
        gridModel.buildRecentlyClosedTabsMenu = {
            let tabMenu = TabMenu(tabManager: bvc.tabManager, alertPresentViewController: self)
            return tabMenu.createRecentlyClosedTabsMenu()
        }

        SpaceStore.suggested.refresh()
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
        CardStripView()
            .environmentObject(tabCardModel)
            .environmentObject(spaceCardModel)
            .environmentObject(sitesCardModel)
            .environmentObject(cardStripModel)
            .offset(x: !cardStripModel.isVisible ? 0 : width - 50)
            .frame(height: CardControllerUX.Height)
    }

    init(bvc: BrowserViewController, width: CGFloat) {
        let tabManager = bvc.tabManager

        self.tabCardModel = TabCardModel(
            manager: tabManager, groupManager: TabGroupManager(tabManager: tabManager))
        self.spaceCardModel = SpaceCardModel()
        self.sitesCardModel = SiteCardModel(urls: [], tabManager: tabManager)
        self.cardStripModel = CardStripModel()
        self.width = width
    }
}
