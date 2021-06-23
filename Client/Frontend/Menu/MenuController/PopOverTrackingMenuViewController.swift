// Copyright Neeva. All rights reserved.

import SwiftUI
import Defaults

class PopOverTrackingMenuViewController: UIHostingController<TrackingMenuView>{

    var delegate: BrowserViewController?

    @objc required dynamic init?(coder aDecoder: NSCoder){
        fatalError("init(coder:) has not been implemented")
    }
    
    public init(delegate: BrowserViewController, source: UIView) {
        let viewModel = TrackingStatsViewModel(trackers: TrackingEntity.getTrackingEntityURLsForCurrentTab())
        super.init(rootView: TrackingMenuView(viewModel: viewModel))
        self.delegate = delegate
        self.modalPresentationStyle = .popover
        self.overrideUserInterfaceStyle = ThemeManager.instance.current.userInterfaceStyle
        NotificationCenter.default.addObserver(forName: .DisplayThemeChanged, object: nil, queue: .main) { [weak self] _ in
            self?.overrideUserInterfaceStyle = ThemeManager.instance.current.userInterfaceStyle
        }
        
        //Create host as a popup
        let popoverMenuViewController = self.popoverPresentationController
        popoverMenuViewController?.permittedArrowDirections = .up
        popoverMenuViewController?.delegate = delegate
        popoverMenuViewController?.sourceView = source
    }

    override func viewWillAppear(_ animated: Bool) {
        self.presentationController?.containerView?.backgroundColor = UIColor.neeva.Backdrop
    }
}
