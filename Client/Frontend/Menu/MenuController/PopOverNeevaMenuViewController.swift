// Copyright Neeva. All rights reserved.

import SwiftUI
import Shared

typealias NeevaMenuContainerView = VerticalScrollViewIfNeeded<NeevaMenuView>
let neevaMenuIntrinsicHeight: CGFloat = 312  // TODO: Compute this value instead.

class PopOverNeevaMenuViewController: UIHostingController<NeevaMenuContainerView>{

    var delegate: BrowserViewController?

    @objc required dynamic init?(coder aDecoder: NSCoder){
        fatalError("init(coder:) has not been implemented")
    }
    
    public init(delegate:BrowserViewController,
                source:UIView, isPrivate: Bool,
                feedbackImage: UIImage?) {
        super.init(rootView: NeevaMenuContainerView(embeddedView: NeevaMenuView(isPrivate: isPrivate),
                   thresholdHeight: neevaMenuIntrinsicHeight))
        self.delegate = delegate
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

                // if user started a tour, trigger navigation on webui side
                // to prevent page refresh, which will lost the states
                if TourManager.shared.userReachedStep(step: .promptSpaceInNeevaMenu) != .stopAction {
                    delegate.neevaMenuDidRequestToOpenPage(page: NeevaMenuButtonActions.spaces)
                } else {
                    delegate.dismissVC()
                }
                break
            case .settings:
                ClientLogger.shared.logCounter(.OpenSetting, attributes: EnvironmentHelper.shared.getAttributes())
                TourManager.shared.userReachedStep(tapTarget: .settingMenu)

                let controller = SettingsViewController(bvc: delegate)

                self.dismiss(animated: true) {
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

                if TourManager.shared.userReachedStep(tapTarget: .feedbackMenu) == .resumeAction {
                    // need to add this dismissVC because without it,
                    // when user click on feedback menu, the quest popover
                    // for feedback will disappear, but the Neeva menu
                    // still shows. Expect behavior will be both quest
                    // popover and Neeva menu disappear, then open up
                    // feedback panel
                    delegate.dismissVC()
                }

                DispatchQueue.main.asyncAfter(deadline: TourManager.shared.delay()) {
                    delegate.present(SendFeedbackPanel(screenshot: feedbackImage, url: delegate.tabManager.selectedTab?.canonicalURL, onOpenURL: {
                        delegate.dismiss(animated: true, completion: nil)
                        delegate.openURLInNewTab($0)
                    }), animated: true)
                }
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
        self.presentationController?.containerView?.backgroundColor = UIColor.neeva.Backdrop
    }

    override func viewWillDisappear(_ animated: Bool) {
        let rotateCheck = delegate?.isRotateSwitchDismiss ?? false

        if !rotateCheck {
            delegate?.isNeevaMenuSheetOpen = false
        }
        delegate?.isRotateSwitchDismiss = false
    }
}
