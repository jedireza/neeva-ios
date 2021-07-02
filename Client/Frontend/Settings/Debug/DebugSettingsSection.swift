// Copyright Neeva. All rights reserved.

import SwiftUI
import Shared

struct DebugSettingsSection: View {
    @Environment(\.onOpenURL) var openURL
    
    var body: some View {
        Group {
            SwiftUI.Section(header: Text("Debug — Neeva")) {
                NavigationLink("Feature Flags", destination: FeatureFlagSettingsView().navigationTitle("Feature Flags"))
                AppHostSetting()
                NavigationLinkButton("Neeva Admin") {
                    openURL(NeevaConstants.appHomeURL / "admin")
                }
                NavigationLink("Internal Settings", destination: InternalSettingsView().navigationTitle("Internal Settings"))
            }
            DebugDBSettingsSection()
            DecorativeSection {
                Button("Force Crash App") {
                    Sentry.shared.crash()
                }.accentColor(.red)
            }
        }
        .listRowBackground(Color.red.opacity(0.2).ignoresSafeArea())
    }
}

struct DebugSettingsSection_Previews: PreviewProvider {
    static var previews: some View {
        SettingPreviewWrapper {
            DebugSettingsSection()
        }
    }
}
