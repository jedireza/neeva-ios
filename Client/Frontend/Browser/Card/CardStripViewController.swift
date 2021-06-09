// Copyright Neeva. All rights reserved.

import Foundation
import SwiftUI

struct CardStripUX {
    static let BottomPadding: CGFloat = 50
    static let Height = 275
}

class CardStripViewController: UIViewController {
    lazy var cardStripHostingController: UIHostingController<CardStrip<TabCardModel>>? = {
        let host = UIHostingController(rootView: CardStrip(model: self.tabCardModel))
        host.view.backgroundColor = UIColor.clear
        addChild(host)
        view.addSubview(host.view)
        host.didMove(toParent: self)
        host.view.translatesAutoresizingMaskIntoConstraints = false
        host.view.isHidden = true
        return host
    }()

    weak var tabManager: TabManager?

    var tabCardModel: TabCardModel

    init(tabManager: TabManager) {
        self.tabManager = tabManager
        self.tabCardModel = TabCardModel(manager: tabManager)
        super.init(nibName: nil, bundle: nil)
        view.backgroundColor = .clear
        self.navigationController?.isNavigationBarHidden = true
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        tabCardModel.onViewUpdate = { self.navigationController?.isNavigationBarHidden = true }
        cardStripHostingController?.view.snp.updateConstraints { make in
            make.edges.equalToSuperview()
        }
    }

}
