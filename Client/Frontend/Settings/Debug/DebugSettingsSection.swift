// Copyright Neeva. All rights reserved.

import Defaults
import Shared
import SwiftUI

struct DebugSettingsSection: View {
    @Environment(\.onOpenURL) var openURL
    @Default(.enableGeigerCounter) var enableGeigerCounter

    var body: some View {
        Group {
            Section(header: Text(verbatim: "Debug — Neeva")) {
                makeNavigationLink(title: String("Server Feature Flags")) {
                    NeevaFeatureFlagSettingsView()
                }
                makeNavigationLink(title: String("Server User Flags")) {
                    NeevaUserFlagSettingsView()
                }
                AppHostSetting()
                #if DEBUG
                    DebugLocaleSetting()
                #endif
                NavigationLinkButton("\(String("Neeva Admin"))") {
                    openURL(NeevaConstants.appHomeURL / "admin")
                }
            }
            Section(header: Text(verbatim: "Debug — Local")) {
                makeNavigationLink(title: String("Local Feature Flags")) {
                    FeatureFlagSettingsView()
                }
                makeNavigationLink(title: String("Internal Settings")) {
                    InternalSettingsView()
                }
                makeNavigationLink(title: String("Logging")) {
                    LoggingSettingsView()
                }
                Toggle(String("Enable Geiger Counter"), isOn: $enableGeigerCounter)
                    .onChange(of: enableGeigerCounter) {
                        if $0 {
                            SceneDelegate.getCurrentSceneDelegateOrNil()?.startGeigerCounter()
                        } else {
                            SceneDelegate.getCurrentSceneDelegateOrNil()?.stopGeigerCounter()
                        }
                    }
                makeNavigationLink(title: String("Notification")) {
                    NotificationSettingsView()
                }
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
