// Copyright Neeva. All rights reserved.

import Defaults
import Shared
import SwiftUI

struct DebugSettingsSection: View {
    @Environment(\.onOpenURL) var openURL
    @Default(.enableGeigerCounter) var enableGeigerCounter

    var body: some View {
        Group {
            Section(header: Text(String("Debug — Neeva"))) {
                NavigationLink(
                    String("Server Feature Flags"),
                    destination: NeevaFeatureFlagSettingsView().navigationTitle(
                        "Server Feature Flags"))
                NavigationLink(
                    String("Server User Flags"),
                    destination: NeevaUserFlagSettingsView().navigationTitle(
                        String("Server User Flags")))
                AppHostSetting()
                NavigationLinkButton("\(String("Neeva Admin"))") {
                    openURL(NeevaConstants.appHomeURL / "admin")
                }
            }
            Section(header: Text(String("Debug — Local"))) {
                NavigationLink(
                    String("Local Feature Flags"),
                    destination: FeatureFlagSettingsView().navigationTitle(String("Local Feature Flags")))
                NavigationLink(
                    String("Internal Settings"),
                    destination: InternalSettingsView().navigationTitle(String("Internal Settings")))
                NavigationLink(
                    String("Logging"),
                    destination: LoggingSettingsView().navigationTitle(String("Logging")))
                Toggle(String("Enable Geiger Counter"), isOn: $enableGeigerCounter)
                    .onChange(of: enableGeigerCounter) {
                        if $0 {
                            SceneDelegate.getCurrentSceneDelegateOrNil()?.startGeigerCounter()
                        } else {
                            SceneDelegate.getCurrentSceneDelegateOrNil()?.stopGeigerCounter()
                        }
                    }
                NavigationLink(
                    String("Notification"),
                    destination: NotificationSettingsView().navigationTitle(String("Notification")))
            }
            DebugDBSettingsSection()
            DecorativeSection {
                Button(String("Force Crash App")) {
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
