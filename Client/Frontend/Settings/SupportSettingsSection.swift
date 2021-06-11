// Copyright Neeva. All rights reserved.

import SwiftUI
import Shared

struct SupportSettingsSection: View {
    @Environment(\.openInNewTab) var openInNewTab
    @Environment(\.settingsPresentIntroViewController) var presentIntroViewController
    
    let onDismiss: (() -> ())?
    init(onDismiss: (() -> ())? = nil) {
        self.onDismiss = onDismiss
    }
    
    var body: some View {
        NavigationLinkButton("Show Tour") {
            ClientLogger.shared.logCounter(.ViewShowTour, attributes: EnvironmentHelper.shared.getAttributes())
            presentIntroViewController()
        }
        SheetNavigationLink("Send Feedback") {
            // TODO: make SendFeedbackView’s NavigationView optional so we can push it?
            // also TODO: figure out how to send a screenshot here
            SendFeedbackView(screenshot: nil, url: nil, onDismiss: {
                if let onDismiss = onDismiss {
                    onDismiss()
                }
            }).environment(\.onOpenURL) { url in openInNewTab(url, false) }
        }
        NavigationLinkButton("Help") {
            ClientLogger.shared.logCounter(.ViewHelp, attributes: EnvironmentHelper.shared.getAttributes())
            openInNewTab(NeevaConstants.appHelpCenterURL, false)
        }
    }
}

struct SupportSettingsSection_Previews: PreviewProvider {
    static var previews: some View {
        SettingPreviewWrapper {
            SwiftUI.Section(header: Text("Support")) {
                SupportSettingsSection()
            }
        }
    }
}
