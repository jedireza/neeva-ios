// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Shared
import SwiftUI

extension EnvironmentValues {
    private struct PresentIntroKey: EnvironmentKey {
        static var defaultValue = { () -> Void in
            fatalError("Specify an environment value for \\.settingsPresentIntroViewController")
        }
    }
    public var settingsPresentIntroViewController: () -> Void {
        get { self[PresentIntroKey.self] }
        set { self[PresentIntroKey.self] = newValue }
    }
}

struct SettingsView: View {
    @Environment(\.presentationMode) @Binding var presentation

    #if DEBUG
        @State var showDebugSettings = true
    #else
        @State var showDebugSettings = false
    #endif

    let scrollViewAppearance = UINavigationBar.appearance().scrollEdgeAppearance

    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Neeva")) {
                    NeevaSettingsSection(userInfo: .shared)
                }
                Section(header: Text("General")) {
                    GeneralSettingsSection()
                }
                Section(header: Text("Privacy")) {
                    PrivacySettingsSection()
                }
                Section(header: Text("Support")) {
                    SupportSettingsSection()
                }
                Section(header: Text("About")) {
                    AboutSettingsSection(showDebugSettings: $showDebugSettings)
                }
                if showDebugSettings {
                    DebugSettingsSection()
                }
            }
            .listStyle(.insetGrouped)
            .applyToggleStyle()
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        presentation.dismiss()
                    }
                }
            }
        }
        .navigationViewStyle(.stack)
        .onDisappear(perform: TourManager.shared.notifyCurrentViewClose)
    }
}

struct SettingPreviewWrapper<Content: View>: View {
    let content: () -> Content
    init(@ViewBuilder _ content: @escaping () -> Content) {
        self.content = content
    }
    var body: some View {
        NavigationView {
            List {
                content()
            }
            .listStyle(.insetGrouped)
            .applyToggleStyle()
            .navigationBarHidden(true)
            .navigationBarTitleDisplayMode(.inline)
        }.navigationViewStyle(.stack)

    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
