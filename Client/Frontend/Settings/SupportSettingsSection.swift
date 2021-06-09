// Copyright Neeva. All rights reserved.

import SwiftUI
import Shared

struct SupportSettingsSection: View {
    @Environment(\.settingsOpenURLInNewNonPrivateTab) var openURLInNewNonPrivateTab
    @Environment(\.onOpenURL) var openURL
    @Environment(\.settingsPresentIntroViewController) var presentIntroViewController
    var body: some View {
        NavigationLinkButton("Show Tour") {
            ClientLogger.shared.logCounter(.ViewShowTour, attributes: EnvironmentHelper.shared.getAttributes())
            presentIntroViewController()
        }
        SheetNavigationLink("Send Feedback") {
            // TODO: make SendFeedbackView’s NavigationView optional so we can push it?
            // also TODO: figure out how to send a screenshot here
            SendFeedbackView(screenshot: nil, url: nil)
                .environment(\.onOpenURL, openURLInNewNonPrivateTab)
        }
        NavigationLinkButton("Help") {
            ClientLogger.shared.logCounter(.ViewHelp, attributes: EnvironmentHelper.shared.getAttributes())
            openURL(NeevaConstants.appHelpCenterURL)
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
