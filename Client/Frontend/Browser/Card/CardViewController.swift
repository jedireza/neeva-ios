// Copyright Neeva. All rights reserved.

import Foundation
import SwiftUI
import Shared

public enum CardControllerUX {
    static let BottomPadding: CGFloat = 50
    static let Height = 275
}

class CardViewController: UIViewController {
    lazy var cardStripHostingController: UIHostingController<TabsAndSpacesView>? = {
        let host = UIHostingController(
            rootView: TabsAndSpacesView(
                tabModel: self.tabCardModel,
                spaceModel: self.spaceCardModel,
                sitesModel: self.sitesCardModel))
        host.view.backgroundColor = UIColor.clear
        addChild(host)
        view.addSubview(host.view)
        host.didMove(toParent: self)
        host.view.translatesAutoresizingMaskIntoConstraints = false
        return host
    }()

    lazy var cardGridHostingController: UIHostingController<CardGrid>? = {
        let host = UIHostingController(
            rootView: CardGrid(spacesModel: self.spaceCardModel,
                               tabModel: self.tabCardModel,
                               tabGroupModel: self.tabGroupCardModel,
                               gridModel: self.gridModel))
        host.view.backgroundColor = UIColor.white
        addChild(host)
        view.addSubview(host.view)
        host.didMove(toParent: self)
        host.view.translatesAutoresizingMaskIntoConstraints = false
        return host
    }()

    weak var tabManager: TabManager?
    var tabGroupManager: TabGroupManager
    let config: CardConfig
    var tabCardModel: TabCardModel
    var tabGroupCardModel: TabGroupCardModel
    var spaceCardModel: SpaceCardModel
    var sitesCardModel: SiteCardModel
    var gridModel = GridModel()

    init(tabManager: TabManager, config: CardConfig) {
        self.tabManager = tabManager
        self.config = config
        self.tabGroupManager = TabGroupManager(tabManager: tabManager)
        self.tabCardModel = TabCardModel(manager: tabManager, groupManager: tabGroupManager)
        self.tabGroupCardModel = TabGroupCardModel(manager: tabGroupManager)
        self.spaceCardModel = SpaceCardModel()
        self.sitesCardModel = SiteCardModel(urls: [],
                                            profile: BrowserViewController.foregroundBVC().profile)
        super.init(nibName: nil, bundle: nil)
        view.backgroundColor = .clear
        gridModel.changeVisibility = { isVisible in
            self.view.isHidden = !isVisible
            self.view.isUserInteractionEnabled = isVisible
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        switch config {
        case .carousel:
            cardStripHostingController?.view.snp.updateConstraints { make in
                make.edges.equalToSuperview()
            }
        case .grid:
            cardGridHostingController?.view.snp.updateConstraints { make in
                make.edges.equalToSuperview()
            }
        }
    }

    func showGrid() {
        guard config == .grid else {
            return
        }
        gridModel.show()
    }

}
