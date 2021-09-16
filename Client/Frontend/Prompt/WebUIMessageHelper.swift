import Foundation
import Shared
import SwiftUI
import WebKit

let messageHandlerName = "webui"

class WebUIMessageHelper: TabContentScript {
    fileprivate weak var tab: Tab?
    fileprivate weak var webView: WKWebView?
    fileprivate weak var tabManager: TabManager?

    init(tab: Tab, webView: WKWebView, tabManager: TabManager) {
        self.tab = tab
        self.webView = webView
        self.tabManager = tabManager
    }

    static func name() -> String {
        return messageHandlerName
    }

    func scriptMessageHandlerName() -> String? {
        return messageHandlerName
    }

    func userContentController(
        _ userContentController: WKUserContentController,
        didReceiveScriptMessage message: WKScriptMessage
    ) {
        let frameOrigin = message.frameInfo.securityOrigin

        if frameOrigin.host != NeevaConstants.appHost {
            return
        }

        guard let result = message.body as? [String: Any],
            let id = result["id"] as? String,
            let name = result["name"] as? String,
            let tourStep = TourStep(rawValue: name)
        else { return }

        if tourStep == .skipTour || tourStep == .completeTour {
            handleShouldShowNotificationPrompt(id: id, tourStep: tourStep)
        }

        if NeevaFeatureFlags[.browserQuests] {
            handleQuestEvent(id: id, tourStep: tourStep)
        }
    }

    func handleQuestEvent(id: String, tourStep: TourStep) {
        let bvc = SceneDelegate.getBVC(with: tabManager?.scene)

        switch tourStep {
        case .promptSpaceInNeevaMenu, .promptFeedbackInNeevaMenu, .promptSettingsInNeevaMenu:
            TourManager.shared.setActiveStep(
                id: id, stepName: tourStep, webView: self.webView! as WKWebView)
            bvc.showQuestNeevaMenuPrompt()
        case .openFeedbackPanelWithInputFieldHighlight:
            TourManager.shared.setActiveStep(
                id: id, stepName: tourStep, webView: self.webView! as WKWebView)
            showFeedbackPanel(bvc: bvc)
        default:
            break
        }
    }

    func handleShouldShowNotificationPrompt(id: String, tourStep: TourStep) {
        let bvc = SceneDelegate.getBVC(with: tabManager?.scene)
        NotificationPermissionHelper.shared.didAlreadyRequestPermission { requested in
            if requested {
                return
            }
            ClientLogger.shared.logCounter(
                .ShowNotificationPrompt,
                attributes: [
                    ClientLogCounterAttribute(
                        key: LogConfig.NotificationAttribute.notificationPromptCallSite,
                        value: tourStep.rawValue)
                ]
            )

            bvc.showAsModalOverlaySheet(
                style: OverlaySheetStyle(
                    showTitle: false,
                    backgroundColor: .systemBackground)
            ) {
                NotificationPromptViewOverlayContent()
            } onDismiss: {
                ClientLogger.shared.logCounter(.NotificationPromptSkip)
            }
        }
    }
}
