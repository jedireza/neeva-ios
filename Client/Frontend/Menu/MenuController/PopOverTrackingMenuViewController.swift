// Copyright Neeva. All rights reserved.

import SwiftUI
import Defaults

class PopOverTrackingMenuViewController: UIHostingController<TrackingMenuView>{

    var delegate: BrowserViewController?

    @objc required dynamic init?(coder aDecoder: NSCoder){
        fatalError("init(coder:) has not been implemented")
    }
    
    public init(delegate: BrowserViewController, source: UIView) {
        let viewModel = TrackingStatsViewModel(
            trackingData: TrackingEntity.getTrackingDataForCurrentTab())
        super.init(rootView: TrackingMenuView(viewModel: viewModel))
        self.delegate = delegate
        self.modalPresentationStyle = .popover
        
        //Create host as a popup
        let popoverMenuViewController = self.popoverPresentationController
        popoverMenuViewController?.permittedArrowDirections = .up
        popoverMenuViewController?.delegate = delegate
        popoverMenuViewController?.sourceView = source
    }

    override func viewWillAppear(_ animated: Bool) {
        self.presentationController?.containerView?.backgroundColor = UIColor.ui.backdrop
    }
}
