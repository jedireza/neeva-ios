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

        var body: some View {
            CardGrid()
                .environmentObject(toolbarModel)
                .environmentObject(tabCardModel)
                .environmentObject(spaceCardModel)
                .environmentObject(tabGroupCardModel)
                .environmentObject(gridModel)
        }
    }

    var leadingConstraint: Constraint? = nil
    let gridModel = GridModel()

    init(tabManager: TabManager, openLazyTab: @escaping () -> Void) {
        let tabGroupManager = TabGroupManager(tabManager: tabManager)
        super.init(
            rootView: Content(
                tabCardModel: TabCardModel(manager: tabManager, groupManager: tabGroupManager),
                tabGroupCardModel: TabGroupCardModel(manager: tabGroupManager),
                spaceCardModel: SpaceCardModel(),
                gridModel: gridModel,
                toolbarModel: SwitcherToolbarModel(tabManager: tabManager, openLazyTab: openLazyTab)
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
            let tabMenu = TabMenu(tabManager: tabManager, alertPresentViewController: self)
            return tabMenu.createCloseAllTabsMenu()
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

    func showGrid() {
        gridModel.show()
    }

    func hideGridWithNoAnimation() {
        gridModel.hideWithNoAnimation()
    }

}

class CardStripViewController: UIHostingController<CardStripViewController.Content> {
    struct Content: View {
        let tabCardModel: TabCardModel
        let spaceCardModel: SpaceCardModel
        let sitesCardModel: SiteCardModel
        let cardStripModel: CardStripModel

        var body: some View {
            CardStripView()
                .environmentObject(tabCardModel)
                .environmentObject(spaceCardModel)
                .environmentObject(sitesCardModel)
                .environmentObject(cardStripModel)
        }
    }

    var leadingConstraint: Constraint? = nil
    let tabCardModel: TabCardModel

    init(tabManager: TabManager) {
        let tabGroupManager = TabGroupManager(tabManager: tabManager)
        self.tabCardModel = TabCardModel(manager: tabManager, groupManager: tabGroupManager)
        let cardStripModel = CardStripModel()
        super.init(
            rootView: Content(
                tabCardModel: tabCardModel,
                spaceCardModel: SpaceCardModel(),
                sitesCardModel: SiteCardModel(
                    urls: [], profile: SceneDelegate.getBVC().profile),
                cardStripModel: cardStripModel
            )
        )
        cardStripModel.onToggleVisible = { isVisible in
            self.view.superview?.layoutIfNeeded()

            if isVisible {
                self.view.snp.makeConstraints { make in
                    self.leadingConstraint = make.leading.equalToSuperview().constraint
                }
            } else {
                self.leadingConstraint?.update(
                    offset: UIScreen.main.bounds.width - CardControllerUX.HandleWidth)
            }

            UIView.animate(
                withDuration: 1.5, delay: 0.0, usingSpringWithDamping: 0.85,
                initialSpringVelocity: 0.0, options: [],
                animations: {
                    self.view.superview?.layoutIfNeeded()
                })
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .clear
    }
}
