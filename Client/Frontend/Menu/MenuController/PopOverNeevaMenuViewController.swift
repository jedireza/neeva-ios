//
//  PopOverViewController.swift
//  Client
//
//  Created by Stuart Allen on 13/03/21.
//  Copyright © 2021 Neeva. All rights reserved.
//

import SwiftUI
import NeevaSupport

typealias NeevaMenuContainerView = VerticalScrollViewIfNeeded<NeevaMenuView>
let neevaMenuIntrinsicHeight: CGFloat = 312  // TODO: Compute this value instead.

class PopOverNeevaMenuViewController: UIHostingController<NeevaMenuContainerView>{

    var delegate: BrowserViewController?

    @objc required dynamic init?(coder aDecoder: NSCoder){
        fatalError("init(coder:) has not been implemented")
    }
    
    public init(delegate:BrowserViewController,
                source:UIView, isPrivate: Bool) {
        super.init(rootView: NeevaMenuContainerView(embeddedView: NeevaMenuView(isPrivate: isPrivate),
                   thresholdHeight: neevaMenuIntrinsicHeight))
        self.delegate = delegate
        self.setAlphaOfBackgroundViews(alpha: 0.5)
        self.modalPresentationStyle = .popover
        self.overrideUserInterfaceStyle = ThemeManager.instance.current.userInterfaceStyle
        NotificationCenter.default.addObserver(forName: .DisplayThemeChanged, object: nil, queue: .main) { [weak self] _ in
            self?.overrideUserInterfaceStyle = ThemeManager.instance.current.userInterfaceStyle
        }
        delegate.isNeevaMenuSheetOpen = true
        
        //Build callbacks for each button action
        self.rootView.embeddedView.menuAction = { result in
            delegate.isNeevaMenuSheetOpen = false
            self.dismiss( animated: true, completion: nil )
            switch result {
            case .home:
                ClientLogger.shared.logCounter(.OpenHome, attributes: EnvironmentHelper.shared.getAttributes())
                delegate.neevaMenuDidRequestToOpenPage(page: NeevaMenuButtonActions.home)
                break
            case .spaces:
                ClientLogger.shared.logCounter(.OpenSpaces, attributes: EnvironmentHelper.shared.getAttributes())
                delegate.neevaMenuDidRequestToOpenPage(page: NeevaMenuButtonActions.spaces)
                break
            case .settings:
                ClientLogger.shared.logCounter(.OpenSetting, attributes: EnvironmentHelper.shared.getAttributes())
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
                ClientLogger.shared.logCounter(.OpenHistory, attributes: EnvironmentHelper.shared.getAttributes())
                delegate.homePanelDidRequestToOpenLibrary(panel: .history)
                break
            case .downloads:
                ClientLogger.shared.logCounter(.OpenDownloads, attributes: EnvironmentHelper.shared.getAttributes())
                delegate.homePanelDidRequestToOpenLibrary(panel: .downloads)
                break
            case .feedback:
                ClientLogger.shared.logCounter(.OpenSendFeedback, attributes: EnvironmentHelper.shared.getAttributes())
                delegate.present(SendFeedbackPanel(), animated: true)
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
        self.presentationController?.containerView?.backgroundColor = UIColor.Photon.Grey90A20
    }

    override func viewWillDisappear(_ animated: Bool) {
        self.setAlphaOfBackgroundViews(alpha: 1.0)
        let rotateCheck = delegate?.isRotateSwitchDismiss ?? false

        if !rotateCheck {
            delegate?.isNeevaMenuSheetOpen = false
        }
        delegate?.isRotateSwitchDismiss = false
    }

    func setAlphaOfBackgroundViews(alpha: CGFloat) {
        let statusBar = UIView(frame: (UIApplication.shared.keyWindow?.windowScene?.statusBarManager?.statusBarFrame)!)
        UIView.animate(withDuration: 0.2) {
            statusBar.alpha = alpha;
            self.delegate!.view.alpha = alpha;
            self.delegate!.navigationController?.navigationBar.alpha = alpha;
        }
    }
}
