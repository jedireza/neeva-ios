//
//  PopOverTrackingMenuViewController.swift
//
//  Created by Stuart Allen on 19/03/21.
//  Copyright © 2021 Neeva. All rights reserved.
//

import SwiftUI

class PopOverTrackingMenuViewController: UIHostingController<TrackingMenuView>{

    var delegate: BrowserViewController?

    @objc required dynamic init?(coder aDecoder: NSCoder){
        fatalError("init(coder:) has not been implemented")
    }
    
    public init(delegate:BrowserViewController,
                         source:UIView) {
        super.init(rootView: TrackingMenuView(isTrackingProtectionEnabled: NeevaTabContentBlocker.isTrackingProtectionEnabled(prefs: delegate.profile.prefs),
            viewModel: TrackingStatsViewModel(
                trackers: TrackingEntity.getTrackingEntityURLsForCurrentTab(),
                settingsHandler: nil)))
        self.delegate = delegate
        self.modalPresentationStyle = .popover
        self.overrideUserInterfaceStyle = ThemeManager.instance.current.userInterfaceStyle
        NotificationCenter.default.addObserver(forName: .DisplayThemeChanged, object: nil, queue: .main) { [weak self] _ in
            self?.overrideUserInterfaceStyle = ThemeManager.instance.current.userInterfaceStyle
        }
        
        //Build callbacks for each button action
        self.rootView.menuAction = { result in
            switch result {
            case .tracking:
                NeevaTabContentBlocker.toggleTrackingProtectionEnabled(prefs: delegate.profile.prefs)
                delegate.tabManager.selectedTab?.reload()
                break
            case .incognito:
                delegate.openURLInNewTab(nil, isPrivate: true)
                self.dismiss( animated: true, completion: nil )
                break
            }
        }
        
        //Create host as a popup
        let popoverMenuViewController = self.popoverPresentationController
        popoverMenuViewController?.permittedArrowDirections = .up
        popoverMenuViewController?.delegate = delegate
        popoverMenuViewController?.sourceView = source
    }

    override func viewWillAppear(_ animated: Bool) {
        self.presentationController?.containerView?.backgroundColor = UIColor.Neeva.Backdrop
    }
}
