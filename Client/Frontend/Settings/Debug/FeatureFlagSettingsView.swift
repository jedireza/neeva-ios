// Copyright Neeva. All rights reserved.

import Defaults
import Shared
import SwiftUI

struct FeatureFlagSettingsView: View {
    @State var needsRestart = false

    @Default(FeatureFlag.defaultsKey) private var currentFeatureFlags

    var body: some View {
        List {
            ForEach(FeatureFlag.allCases.map(\.rawValue), id: \.self) { flag in
                Toggle(
                    flag,
                    isOn: Binding(
                        get: { currentFeatureFlags.contains(flag) },
                        set: { isOn in
                            needsRestart = true
                            if isOn {
                                currentFeatureFlags.insert(flag)
                            } else {
                                currentFeatureFlags.remove(flag)
                            }

                            if flag == FeatureFlag.notifications.rawValue, !isOn {
                                NotificationHelper.shared.unregisterNotifications()
                            }
                        }
                    ))
            }
        }
        .listStyle(GroupedListStyle())
        .overlay(DebugSettingsRestartPromptView(isVisible: needsRestart), alignment: .bottom)
        .applyToggleStyle()
    }
}

struct FeatureFlagSettings_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            FeatureFlagSettingsView()
                .navigationTitle("Feature Flags")
                .navigationBarTitleDisplayMode(.inline)
        }.navigationViewStyle(StackNavigationViewStyle())
        NavigationView {
            FeatureFlagSettingsView(needsRestart: true)
                .navigationTitle("Feature Flags")
                .navigationBarTitleDisplayMode(.inline)
        }.navigationViewStyle(StackNavigationViewStyle())
    }
}
