// Copyright Neeva. All rights reserved.

import Foundation
import SwiftUI
import Shared
import SnapKit

public enum CardControllerUX {
    static let BottomPadding: CGFloat = 50
    static let Height: CGFloat = 275
    static let HandleWidth: CGFloat = 50
}

class CardViewController: UIViewController {
    lazy var cardStrip: UIView? = {
        let host = UIHostingController(
            rootView: TabsAndSpacesView()
                .environmentObject(self.tabCardModel)
                .environmentObject(self.spaceCardModel)
                .environmentObject(self.sitesCardModel)
                .environmentObject(self.cardStripModel))
        host.view.backgroundColor = UIColor.clear
        addChild(host)
        view.addSubview(host.view)
        host.didMove(toParent: self)
        host.view.translatesAutoresizingMaskIntoConstraints = false
        return host.view
    }()

    lazy var cardGrid: UIView = {
        let host = UIHostingController(
            rootView: CardGrid()
                .environmentObject(self.tabCardModel)
                .environmentObject(self.tabGroupCardModel)
                .environmentObject(self.spaceCardModel)
                .environmentObject(self.gridModel))
        host.view.backgroundColor = UIColor.TabTray.background
        addChild(host)
        view.addSubview(host.view)
        host.didMove(toParent: self)
        host.view.translatesAutoresizingMaskIntoConstraints = false
        return host.view
    }()

    lazy var toolbar: UIView = {
        let host = UIHostingController(
            rootView: SwitcherToolbarView()
                .environmentObject(self.gridModel)
                .environmentObject(self.toolbarModel))
        host.view.backgroundColor = UIColor.clear
        addChild(host)
        view.addSubview(host.view)
        host.didMove(toParent: self)
        host.view.translatesAutoresizingMaskIntoConstraints = false
        return host.view
    }()

    var tabManager: TabManager
    var tabGroupManager: TabGroupManager
    let config: CardConfig
    var tabCardModel: TabCardModel
    var tabGroupCardModel: TabGroupCardModel
    var spaceCardModel: SpaceCardModel
    var sitesCardModel: SiteCardModel
    var gridModel = GridModel()
    var toolbarModel: SwitcherToolbarModel
    var cardStripModel = CardStripModel()
    var leadingConstraint: Constraint? = nil

    init(tabManager: TabManager, config: CardConfig) {
        self.tabManager = tabManager
        self.config = config
        self.tabGroupManager = TabGroupManager(tabManager: tabManager)
        self.tabCardModel = TabCardModel(manager: tabManager, groupManager: tabGroupManager)
        self.tabGroupCardModel = TabGroupCardModel(manager: tabGroupManager)
        self.spaceCardModel = SpaceCardModel()
        self.sitesCardModel = SiteCardModel(urls: [],
                                            profile: BrowserViewController.foregroundBVC().profile)
        self.toolbarModel = SwitcherToolbarModel(tabManager: tabManager)
        super.init(nibName: nil, bundle: nil)
        view.backgroundColor = .clear
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

            UIView.animate(withDuration: 1.5, delay: 0.0, usingSpringWithDamping: 0.85,
                           initialSpringVelocity: 0.0, options: [], animations: {
                self.view.superview?.layoutIfNeeded()
            })
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        switch config {
        case .carousel:
            cardStrip?.snp.updateConstraints { make in
                make.edges.equalToSuperview()
            }
        case .grid:
            cardGrid.snp.updateConstraints { make in
                make.top.leading.trailing.equalToSuperview()
                make.bottom.equalToSuperview().offset(-UIConstants.BottomToolbarHeight)
            }
            toolbar.snp.updateConstraints { make in
                make.bottom.leading.trailing.equalToSuperview()
                make.top.equalTo(cardGrid.snp.bottom)
            }
        }
    }

    func showGrid() {
        guard config == .grid else {
            return
        }
        gridModel.show()
    }

    func hideGridWithNoAnimation() {
        guard config == .grid else {
            return
        }
        gridModel.hideWithNoAnimation()
    }

}
