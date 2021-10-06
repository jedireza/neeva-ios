// Copyright Neeva. All rights reserved.

import Shared

enum NeevaMenuAction {
    case home
    case spaces
    case settings
    case history
    case feedback
    case referralPromo
}

extension BrowserViewController {
    func perform(neevaMenuAction: NeevaMenuAction) {
        switch neevaMenuAction {
        case .home:
            ClientLogger.shared.logCounter(
                .OpenHome, attributes: EnvironmentHelper.shared.getAttributes())
            switchToTabForURLOrOpen(NeevaConstants.appHomeURL)

        case .spaces:
            ClientLogger.shared.logCounter(
                .OpenSpaces, attributes: EnvironmentHelper.shared.getAttributes())

            // if user started a tour, trigger navigation on webui side
            // to prevent page refresh, which will lost the states
            if TourManager.shared.userReachedStep(step: .promptSpaceInNeevaMenu) != .stopAction {
                switchToTabForURLOrOpen(NeevaConstants.appSpacesURL)
            }

        case .settings:
            ClientLogger.shared.logCounter(
                .OpenSetting, attributes: EnvironmentHelper.shared.getAttributes())
            TourManager.shared.userReachedStep(tapTarget: .settingMenu)
            let action = {
                let controller = SettingsViewController(bvc: self)
                self.present(controller, animated: true)
            }

            // For the connected apps tour prompt
            if let presentedViewController = presentedViewController {
                presentedViewController.dismiss(animated: true, completion: action)
            } else {
                action()
            }

        case .history:
            ClientLogger.shared.logCounter(
                .OpenHistory, attributes: EnvironmentHelper.shared.getAttributes())

            let historyPanel = HistoryPanel(profile: profile)
            historyPanel.delegate = self
            historyPanel.accessibilityLabel = "History Panel"

            let navigationController = UINavigationController(rootViewController: historyPanel)
            navigationController.modalPresentationStyle = .formSheet

            present(navigationController, animated: true, completion: nil)

        case .feedback:
            ClientLogger.shared.logCounter(
                .OpenSendFeedback, attributes: EnvironmentHelper.shared.getAttributes())
            TourManager.shared.userReachedStep(tapTarget: .feedbackMenu)

            showFeedbackPanel(bvc: self, screenshot: self.feedbackImage)
        case .referralPromo:
            // log click referral promo from neeva menu
            var attributes = EnvironmentHelper.shared.getAttributes()
            attributes.append(ClientLogCounterAttribute(key: "source", value: "neeva menu"))
            ClientLogger.shared.logCounter(
                .OpenReferralPromo, attributes: attributes)
            switchToTabForURLOrOpen(NeevaConstants.appReferralsURL)
            presentedViewController?.dismiss(animated: true)
        }
    }
}
