// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Shared

enum NeevaMenuAction {
    case home
    case spaces
    case settings
    case history
    case support
    case downloads
    case referralPromo
}

extension BrowserViewController {
    func perform(neevaMenuAction: NeevaMenuAction) {
        overlayManager.hideCurrentOverlay()
        let neevaMenuAttribute = ClientLogCounterAttribute(
            key: LogConfig.UIInteractionAttribute.fromActionType,
            value: String(describing: NeevaMenuAction.self)
        )

        switch neevaMenuAction {
        case .home:
            ClientLogger.shared.logCounter(
                .OpenHome,
                attributes: EnvironmentHelper.shared.getAttributes() + [neevaMenuAttribute]
            )
            switchToTabForURLOrOpen(NeevaConstants.appSearchURL)
        case .spaces:
            ClientLogger.shared.logCounter(
                .OpenSpaces,
                attributes: EnvironmentHelper.shared.getAttributes() + [neevaMenuAttribute]
            )

            // if user started a tour, trigger navigation on webui side
            // to prevent page refresh, which will lost the states
            if TourManager.shared.userReachedStep(step: .promptSpaceInNeevaMenu) != .stopAction {
                if TourManager.shared.hasActiveStep() {
                    switchToTabForURLOrOpen(NeevaConstants.appSpacesURL)
                } else {
                    browserModel.showSpaces()
                }
            }

        case .settings:
            ClientLogger.shared.logCounter(
                .OpenSetting,
                attributes: EnvironmentHelper.shared.getAttributes() + [neevaMenuAttribute]
            )
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
                .OpenHistory,
                attributes: EnvironmentHelper.shared.getAttributes() + [neevaMenuAttribute]
            )

            let historyPanel = HistoryPanel(profile: profile)
            historyPanel.delegate = self
            historyPanel.accessibilityLabel = "History Panel"

            let navigationController = UINavigationController(rootViewController: historyPanel)
            navigationController.modalPresentationStyle = .formSheet

            present(navigationController, animated: true, completion: nil)

        case .support:
            ClientLogger.shared.logCounter(
                .OpenSendFeedback,
                attributes: EnvironmentHelper.shared.getAttributes() + [neevaMenuAttribute]
            )
            TourManager.shared.userReachedStep(tapTarget: .feedbackMenu)

            showFeedbackPanel(bvc: self, screenshot: self.feedbackImage)
        case .referralPromo:
            // log click referral promo from neeva menu
            ClientLogger.shared.logCounter(
                .OpenReferralPromo,
                attributes: EnvironmentHelper.shared.getAttributes() + [neevaMenuAttribute]
            )
            switchToTabForURLOrOpen(NeevaConstants.appReferralsURL)
            presentedViewController?.dismiss(animated: true)
        case .downloads:
            ClientLogger.shared.logCounter(
                .OpenDownloads, attributes: EnvironmentHelper.shared.getAttributes())
            openDownloadsFolderInFilesApp()
        }
    }
}
