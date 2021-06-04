//
//  SettingsView.swift
//  Client
//
//  Copyright © 2021 Neeva. All rights reserved.
//

import SwiftUI
import Shared

extension EnvironmentValues {
    private struct OpenInNonPrivateTabKey: EnvironmentKey {
        static var defaultValue = { (url: URL) -> () in fatalError("Specify an environment value for settingsOpenURLInNewNonPrivateTab")}
    }
    public var settingsOpenURLInNewNonPrivateTab: (URL) -> () {
        get { self[OpenInNonPrivateTabKey] }
        set { self[OpenInNonPrivateTabKey] = newValue }
    }
}

extension EnvironmentValues {
    private struct PresentIntroKey: EnvironmentKey {
        static var defaultValue = { () -> () in fatalError("Specify an environment value for settingsOpenURLInNewNonPrivateTab")}
    }
    public var settingsPresentIntroViewController: () -> () {
        get { self[PresentIntroKey] }
        set { self[PresentIntroKey] = newValue }
    }
}

struct SettingsView: View {
    let dismiss: () -> ()

    #if DEV
    @State var showDebugSettings = true
    #else
    @State var showDebugSettings = false
    #endif

    var body: some View {
        NavigationView {
            List {
                SwiftUI.Section(header: Text("Neeva")) {
                    NeevaSettingsSection(userInfo: .shared)
                }
                SwiftUI.Section(header: Text("General")) {
                    GeneralSettingsSection()
                }
                SwiftUI.Section(header: Text("Privacy")) {
                    PrivacySettingsSection()
                }
                SwiftUI.Section(header: Text("Support")) {
                    SupportSettingsSection()
                }
                SwiftUI.Section(header: Text("About")) {
                    AboutSettingsSection(showDebugSettings: $showDebugSettings)
                }
                if showDebugSettings {
                    DebugSettingsSection()
                }
            }
            .listStyle(GroupedListStyle())
            .toggleStyle(SwitchToggleStyle(tint: .blue))
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done", action: dismiss)
                }
            }
        }.navigationViewStyle(StackNavigationViewStyle())
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
            .listStyle(GroupedListStyle())
            .toggleStyle(SwitchToggleStyle(tint: .blue))
            .navigationBarHidden(true)
            .navigationBarTitleDisplayMode(.inline)
        }.navigationViewStyle(StackNavigationViewStyle())

    }
}

class SettingsViewController: UIHostingController<AnyView> {
    init(bvc: BrowserViewController) {
        super.init(rootView: AnyView(EmptyView()))

        self.rootView = AnyView(
            SettingsView(dismiss: dismissVC)
                .environment(\.settingsOpenURLInNewNonPrivateTab) { url in
                    self.dismissVC()
                    bvc.settingsOpenURLInNewNonPrivateTab(url)
                }
                .environment(\.onOpenURL) { url in
                    self.dismissVC()
                    bvc.settingsOpenURLInNewTab(url)
                }
                .environment(\.settingsPresentIntroViewController) {
                    self.dismiss(animated: true) {
                        bvc.presentIntroViewController(true)
                    }
                }
        )
    }

    @objc required dynamic init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView(dismiss: {})
    }
}
