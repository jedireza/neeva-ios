//
//  PopOverTrackingMenuViewController.swift
//
//  Created by Stuart Allen on 19/03/21.
//  Copyright © 2021 Neeva. All rights reserved.
//

import SwiftUI
import NeevaSupport

class PopOverTrackingMenuViewController: UIHostingController<TrackingMenuView>{
    
    @objc required dynamic init?(coder aDecoder: NSCoder){
        super.init(coder: aDecoder, rootView: TrackingMenuView())
    }
    
    public init(delegate:BrowserViewController,
                         source:UIView,
                         rootView: TrackingMenuView) {
        super.init(rootView: rootView)
        
        self.modalPresentationStyle = .popover
        self.overrideUserInterfaceStyle = ThemeManager.instance.current.userInterfaceStyle
        NotificationCenter.default.addObserver(forName: .DisplayThemeChanged, object: nil, queue: .main) { [weak self] _ in
            self?.overrideUserInterfaceStyle = ThemeManager.instance.current.userInterfaceStyle
        }
        
        //Build callbacks for each button action
        self.rootView.menuAction = { result in
            self.dismiss( animated: true, completion: nil )
            switch result {
            case .settings:
                break
            case .incognito:
                delegate.switchToPrivacyMode(isPrivate: true)
                break
            }
        }
        
        //Create host as a popup
        let popoverMenuViewController = self.popoverPresentationController
        popoverMenuViewController?.permittedArrowDirections = .up
        popoverMenuViewController?.delegate = delegate
        popoverMenuViewController?.sourceView = source
    }
}

