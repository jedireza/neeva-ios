// Copyright Neeva. All rights reserved.

import SwiftUI
import Shared
import Defaults

struct FeatureFlagSettingsView: View {
    @State var needsRestart = false

    @Default(FeatureFlag.defaultsKey) private var currentFeatureFlags

    var body: some View {
        List {
            ForEach(FeatureFlag.allCases.map(\.rawValue), id: \.self) { flag in
                Toggle(flag, isOn: Binding(
                    get: { currentFeatureFlags.contains(flag) },
                    set: { isOn in
                        needsRestart = true
                        if isOn {
                            currentFeatureFlags.insert(flag)
                        } else {
                            currentFeatureFlags.remove(flag)
                        }
                    }
                ))
            }
        }
        .listStyle(GroupedListStyle())
        .overlay(Group {
            if needsRestart {
                HStack {
                    Spacer()
                    Text("Quit Neeva from the App Switcher and relaunch for feature flag changes to take effect")
                        .withFont(.labelLarge)
                        .multilineTextAlignment(.center)
                        .padding()
                    Spacer()
                }.background(
                    Color.groupedBackground
                        .overlay(Color.tertiarySystemFill)
                        .ignoresSafeArea()
                )
            }
        }, alignment: .bottom)
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
