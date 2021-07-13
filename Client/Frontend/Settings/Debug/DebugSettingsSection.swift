// Copyright Neeva. All rights reserved.

import SwiftUI
import Shared
import Defaults

struct DebugSettingsSection: View {
    @Environment(\.onOpenURL) var openURL
    @Default(.enableGeigerCounter) var enableGeigerCounter

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
                Toggle("Enable Geiger Counter", isOn: $enableGeigerCounter)
                    .onChange(of: enableGeigerCounter) {
                        if $0 {
                            SceneDelegate.getCurrentSceneDelegate().startGeigerCounter()
                        } else {
                            SceneDelegate.getCurrentSceneDelegate().stopGeigerCounter()
                        }
                    }
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
