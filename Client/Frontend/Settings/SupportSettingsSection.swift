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
        if NeevaFeatureFlags[.welcomeTours] {
            NavigationLinkButton("Welcome Tours") {
                ClientLogger.shared.logCounter(.ViewShowTour, attributes: EnvironmentHelper.shared.getAttributes())
                openInNewTab(NeevaConstants.appWelcomeToursURL, false)
            }
        } else {
            NavigationLinkButton("Show Tour") {
                ClientLogger.shared.logCounter(.ViewShowTour, attributes: EnvironmentHelper.shared.getAttributes())
                presentIntroViewController()
            }
        }
        
        NavigationLinkButton("Help Center") {
            ClientLogger.shared.logCounter(.ViewHelpCenter, attributes: EnvironmentHelper.shared.getAttributes())
            openInNewTab(NeevaConstants.appHelpCenterURL, false)
        }
    }
}

struct SupportSettingsSection_Previews: PreviewProvider {
    static var previews: some View {
        SettingPreviewWrapper {
            Section(header: Text("Support")) {
                SupportSettingsSection()
            }
        }
    }
}
