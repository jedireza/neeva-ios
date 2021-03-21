//
//  PopOverViewController.swift
//  Client
//
//  Created by Stuart Allen on 13/03/21.
//  Copyright © 2021 Neeva. All rights reserved.
//

import SwiftUI
import NeevaSupport

class PopOverNeevaMenuViewController: UIHostingController<NeevaMenuView>{
    
    @objc required dynamic init?(coder aDecoder: NSCoder){
        fatalError("init(coder:) has not been implemented")
    }
    
    public init(delegate:BrowserViewController,
                         source:UIView) {
        super.init(rootView: NeevaMenuView())
        
        self.modalPresentationStyle = .popover
        self.overrideUserInterfaceStyle = ThemeManager.instance.current.userInterfaceStyle
        NotificationCenter.default.addObserver(forName: .DisplayThemeChanged, object: nil, queue: .main) { [weak self] _ in
            self?.overrideUserInterfaceStyle = ThemeManager.instance.current.userInterfaceStyle
        }
        
        //Build callbacks for each button action
        self.rootView.menuAction = { result in
            self.dismiss( animated: true, completion: nil )
            switch result {
            case .home:
                delegate.neevaMenuDidRequestToOpenPage(page: NeevaMenuButtonActions.home)
                break
            case .spaces:
                self.dismiss( animated: true, completion: nil )
                let host = UIHostingController(
                    rootView: SpaceListView(onDismiss: self.dismissVC)
                        .environment(\.onOpenURL) { url in
                            delegate.settingsOpenURLInNewTab(url)
                            delegate.dismissVC()
                        }
                )
                host.overrideUserInterfaceStyle = self.overrideUserInterfaceStyle
                delegate.present(host, animated: true, completion: nil)
                break
            case .settings:
                self.dismiss( animated: true, completion: nil )
                let settingsTableViewController = AppSettingsTableViewController()
                settingsTableViewController.profile = delegate.profile
                settingsTableViewController.tabManager = delegate.tabManager
                settingsTableViewController.settingsDelegate = delegate

                let controller = ThemedNavigationController(rootViewController: settingsTableViewController)
                // On iPhone iOS13 the WKWebview crashes while presenting file picker if its not full screen. Ref #6232
                // since there are no intentional uses of file pickers in the web views under the Settings screen, we
                // can remove this workaround and get the better iOS 13 UX
                // if UIDevice.current.userInterfaceIdiom == .phone {
                //     controller.modalPresentationStyle = .fullScreen
                // }
                controller.presentingModalViewControllerDelegate = delegate

                // Wait to present VC in an async dispatch queue to prevent a case where dismissal
                // of this popover on iPad seems to block the presentation of the modal VC.
                DispatchQueue.main.async {
                    delegate.present(controller, animated: true, completion: nil)
                }
                break
            case .history:
                delegate.homePanelDidRequestToOpenLibrary(panel: .history)
                break
            case .downloads:
                delegate.homePanelDidRequestToOpenLibrary(panel: .downloads)
                break
            case .feedback:
                delegate.present(SendFeedbackPanel(), animated: true)
                break
            case .privacyPolicy:
                delegate.neevaMenuDidRequestToOpenPage(page: NeevaMenuButtonActions.privacyPolicy)
                break
            case .helpCenter:
                delegate.neevaMenuDidRequestToOpenPage(page: NeevaMenuButtonActions.helpCenter)
                break
            case .signOut:
                //TODO: once sign out experience defined
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
