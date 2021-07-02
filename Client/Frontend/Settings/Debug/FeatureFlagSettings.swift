// Copyright Neeva. All rights reserved.

import SwiftUI
import Shared
import Defaults

struct FeatureFlagSettingsView: View {
    @Default(FeatureFlag.defaultsKey) var key
    var body: some View {
        List {
            Section(header: Text("Local")) {
                // trigger updates when toggling
                let _ = key
                ForEach(FeatureFlag.allCases, id: \.rawValue) { flag in
                    Toggle(flag.rawValue, isOn: Binding(
                        get: { FeatureFlag[flag] },
                        set: { FeatureFlag[flag] = $0 }
                    ))
                }
            }

            Section(header: Text("Server Controlled")) {
                // TODO: Add support for Int, Float and String flags.
                ForEach(NeevaFeatureFlags.BoolFlag.allCases, id: \.rawValue) { flag in
                    HStack {
                        Text(flag.name).font(.system(.body, design: .monospaced)).fixedSize()
                        BoolFlagView(flag: flag)
                    }
                }
            }
        }
        .listStyle(GroupedListStyle())
        .applyToggleStyle()
    }

    struct BoolFlagView: View {
        @State private var flagValue: Bool
        @State private var isOverridden: Bool

        private let flag: NeevaFeatureFlags.BoolFlag

        init(flag: NeevaFeatureFlags.BoolFlag) {
            self.flag = flag
            self.flagValue = NeevaFeatureFlags[flag]
            self.isOverridden = NeevaFeatureFlags.isOverridden(flag)
        }

        var body: some View {
            Menu {
                Button {
                    NeevaFeatureFlags[flag] = true
                    updateState()
                } label: {
                    if flagValue && isOverridden {
                        Label("True", systemSymbol: .checkmark)
                    } else {
                        Text("True")
                    }
                }
                Button {
                    NeevaFeatureFlags[flag] = false
                    updateState()
                } label: {
                    if !flagValue && isOverridden {
                        Label("False", systemSymbol: .checkmark)
                    } else {
                        Text("False")
                    }
                }
                Button {
                    NeevaFeatureFlags.reset(flag)
                    updateState()
                } label: {
                    if isOverridden {
                        Text("Default")
                    } else {
                        Label("Default", systemSymbol: .checkmark)
                    }
                }
            } label: {
                HStack {
                    Spacer() // fix layout issues
                    Text(String(flagValue)).fontWeight(isOverridden ? .bold : .regular)
                    Symbol(.chevronDown)
                }
            }
        }

        func updateState() {
            self.flagValue = NeevaFeatureFlags[flag]
            self.isOverridden = NeevaFeatureFlags.isOverridden(flag)
        }
    }
}

struct FeatureFlagSettings_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            FeatureFlagSettingsView()
                .navigationTitle("Feature Flags")
                .navigationBarTitleDisplayMode(.inline)
        }.navigationViewStyle(StackNavigationViewStyle())
    }
}
