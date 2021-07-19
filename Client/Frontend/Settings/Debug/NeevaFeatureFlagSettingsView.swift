// Copyright Neeva. All rights reserved.

import SwiftUI
import Shared

struct NeevaFeatureFlagSettingsView: View {
    var body: some View {
        List {
            // TODO: Add support for Int, Float and String flags.
            ForEach(NeevaFeatureFlags.BoolFlag.allCases, id: \.rawValue) { flag in
                HStack {
                    Text(flag.name).font(.system(.body, design: .monospaced)).fixedSize()
                    BoolFlagView(flag: flag)
                }
            }
        }.listStyle(GroupedListStyle())
    }
}

fileprivate struct BoolFlagView: View {
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

struct NeevaFeatureFlagSettings_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            NeevaFeatureFlagSettingsView()
                .navigationTitle("Server Feature Flags")
                .navigationBarTitleDisplayMode(.inline)
        }.navigationViewStyle(StackNavigationViewStyle())
    }
}
