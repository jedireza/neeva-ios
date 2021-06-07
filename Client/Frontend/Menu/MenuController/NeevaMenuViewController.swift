//
//  NeevaMenuViewController.swift
//  Client
//
//  Copyright © 2021 Neeva. All rights reserved.
//

import SwiftUI
import Shared

struct NeevaMenuRootView: View {
    @StateObject var overlaySheetModel = OverlaySheetModel()
    let onDismiss: () -> ()
    let isPrivate: Bool
    var embeddedView: NeevaMenuView

    var body: some View {
        let config = OverlaySheetConfig(showTitle: false, backgroundColor: UIColor.PopupMenu.background)
        OverlaySheetView(model: self.overlaySheetModel, config: config, onDismiss: { self.onDismiss() } ) {
            self.embeddedView.overlaySheetIsFixedHeight(isFixedHeight: true).padding(.top, 8)
        }
        .onAppear() {
            DispatchQueue.main.async {
                self.overlaySheetModel.show()
            }
        }
    }
}

class NeevaMenuViewController: UIHostingController<NeevaMenuRootView> {
    var delegate: BrowserViewController?

    public init(delegate: BrowserViewController, onDismiss: @escaping () -> (), isPrivate: Bool, feedbackImage: UIImage?){
        super.init(rootView: NeevaMenuRootView(onDismiss: onDismiss, isPrivate: isPrivate, embeddedView:NeevaMenuView(isPrivate: isPrivate, noTopPadding: true) ))
        self.delegate = delegate
        self.overrideUserInterfaceStyle = ThemeManager.instance.current.userInterfaceStyle
        NotificationCenter.default.addObserver(forName: .DisplayThemeChanged, object: nil, queue: .main) { [weak self] _ in
            self?.overrideUserInterfaceStyle = ThemeManager.instance.current.userInterfaceStyle
        }
        delegate.isNeevaMenuSheetOpen = true

        //Build callbacks for each button action
        self.rootView.embeddedView.menuAction = { result in
            delegate.isNeevaMenuSheetOpen = false
            self.rootView.onDismiss()
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
                if FeatureFlag[.legacySettings] {
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
                } else {
                    let controller = SettingsViewController(bvc: delegate)

                    // Wait to present VC in an async dispatch queue to prevent a case where dismissal
                    // of this popover on iPad seems to block the presentation of the modal VC.
                    DispatchQueue.main.async {
                        delegate.present(controller, animated: true, completion: nil)
                    }
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
                delegate.present(SendFeedbackPanel(screenshot: feedbackImage, url: delegate.tabManager.selectedTab?.canonicalURL, onOpenURL: {
                    delegate.dismiss(animated: true, completion: nil)
                    delegate.openURLInNewTab($0)
                }), animated: true)
                break
            }
        }
    }

    @objc required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // By default, a UIHostingController opens as an opaque layer, so we override
        // that behavior here.
        view.backgroundColor = .clear
    }
}
