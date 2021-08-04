// Copyright Neeva. All rights reserved.

import Shared
import SwiftUI

struct NeevaFeatureFlagSettingsView: View {
    @State var needsRestart = false
    var body: some View {
        List {
            // TODO: Add support for Int, Float and String flags.
            ForEach(NeevaFeatureFlags.BoolFlag.allCases, id: \.rawValue) { flag in
                HStack {
                    Text(flag.name)
                        .font(.system(.body, design: .monospaced))
                        .fixedSize(horizontal: false, vertical: true)
                    Spacer()
                    BoolFlagView(flag: flag, onChange: { needsRestart = true })
                        .fixedSize()
                }
            }
        }
        .listStyle(GroupedListStyle())
        .overlay(DebugSettingsRestartPromptView(isVisible: needsRestart), alignment: .bottom)
    }
}

private struct BoolFlagView: View {
    @State private var flagValue: Bool
    @State private var isOverridden: Bool

    private let onChange: () -> Void
    private let flag: NeevaFeatureFlags.BoolFlag

    init(flag: NeevaFeatureFlags.BoolFlag, onChange: @escaping () -> Void) {
        self.flag = flag
        self.onChange = onChange
        self._flagValue = .init(initialValue: NeevaFeatureFlags[flag])
        self._isOverridden = .init(initialValue: NeevaFeatureFlags.isOverridden(flag))
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
                Spacer()  // fix layout issues
                Text(String(flagValue)).fontWeight(isOverridden ? .bold : .regular)
                Symbol(decorative: .chevronDown)
            }
        }
    }

    func updateState() {
        self.onChange()
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
