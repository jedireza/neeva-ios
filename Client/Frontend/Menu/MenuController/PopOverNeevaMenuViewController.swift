// Copyright Neeva. All rights reserved.

import SwiftUI
import Shared

// can’t be fileprivate because the type of the generic on UIHostingController
// is required to be at least as public as the hosting controller subclass itself.
struct _NeevaMenuPopover: View {
    fileprivate let isIncognito: Bool
    fileprivate let menuAction: ((NeevaMenuButtonActions) -> ())?

    var body: some View {
        VerticalScrollViewIfNeeded(
            embeddedView: NeevaMenuView(menuAction: menuAction),
            thresholdHeight: 312 // TODO: Compute this value instead.
        ).environment(\.isIncognito, isIncognito)
    }
}

fileprivate typealias NeevaMenuPopover = _NeevaMenuPopover

class PopOverNeevaMenuViewController: UIHostingController<_NeevaMenuPopover> {

    var delegate: BrowserViewController?

    @objc required dynamic init?(coder aDecoder: NSCoder){
        fatalError("init(coder:) has not been implemented")
    }
    
    public init(delegate:BrowserViewController,
                source:UIView, isPrivate: Bool,
                feedbackImage: UIImage?) {
        super.init(rootView: NeevaMenuPopover(isIncognito: isPrivate, menuAction: nil))
        self.delegate = delegate
        self.modalPresentationStyle = .popover
        delegate.isNeevaMenuSheetOpen = true
        
        //Build callbacks for each button action
        self.rootView = NeevaMenuPopover(isIncognito: isPrivate) { result in
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
                delegate.zeroQueryPanelDidRequestToOpenLibrary(panel: .history)
                
                break
            case .downloads:
                ClientLogger.shared.logCounter(.OpenDownloads, attributes: EnvironmentHelper.shared.getAttributes())
                delegate.zeroQueryPanelDidRequestToOpenLibrary(panel: .downloads)

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
                    showFeedbackPanel(bvc: delegate, screenshot: feedbackImage)
                }
                break
            case .referralPromo:
                delegate.neevaMenuDidRequestToOpenPage(page: NeevaMenuButtonActions.referralPromo)
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
        self.presentationController?.containerView?.backgroundColor = UIColor.ui.backdrop
    }

    override func viewWillDisappear(_ animated: Bool) {
        let rotateCheck = delegate?.isRotateSwitchDismiss ?? false

        if !rotateCheck {
            delegate?.isNeevaMenuSheetOpen = false
        }
        delegate?.isRotateSwitchDismiss = false
    }
}
