import Foundation
import WebKit
import SwiftUI
import Shared

let messageHandlerName = "webui"

class WebUIMessageHelper: TabContentScript {
    fileprivate weak var tab: Tab?
    fileprivate weak var webView: WKWebView?

    init(tab: Tab, webView: WKWebView) {
        self.tab = tab
        self.webView = webView
    }
    
    static func name() -> String {
        return messageHandlerName
    }
    
    func scriptMessageHandlerName() -> String? {
        return messageHandlerName
    }
    
    func userContentController(_ userContentController: WKUserContentController, didReceiveScriptMessage message: WKScriptMessage) {

        let frameOrigin = message.frameInfo.securityOrigin
        if frameOrigin.host != NeevaConstants.appHost {
            return
        }

        guard let result = message.body as? [String: Any],
              let id = result["id"] as? String,
              let stepName = result["name"] as? String,
              let tourStep = TourStep(rawValue: stepName)
        else { return }

        switch tourStep {
        case .promptSpaceInNeevaMenu, .promptFeedbackInNeevaMenu, .promptSettingsInNeevaMenu:
            TourManager.shared.setActiveStep(id: id, stepName: tourStep, webView: self.webView! as WKWebView)
            BrowserViewController.foregroundBVC().showQuestNeevaMenuPrompt()
        default:
            break
        }
    }
}
