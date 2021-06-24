// Copyright Neeva. All rights reserved.

import SwiftUI
import Shared

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
                    SupportSettingsSection(onDismiss: {
                        dismiss()
                    })
                }
                SwiftUI.Section(header: Text("About")) {
                    AboutSettingsSection(showDebugSettings: $showDebugSettings)
                }
                if showDebugSettings {
                    DebugSettingsSection()
                }
            }
            .listStyle(GroupedListStyle())
            .applyToggleStyle()
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done", action: dismiss)
                }
            }
        }.navigationViewStyle(StackNavigationViewStyle())
        .onDisappear(perform: viewDidDisappear)
    }

    private func viewDidDisappear() {
        TourManager.shared.notifyCurrentViewClose()
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
            .applyToggleStyle()
            .navigationBarHidden(true)
            .navigationBarTitleDisplayMode(.inline)
        }.navigationViewStyle(StackNavigationViewStyle())

    }
}

class SettingsViewController: UIHostingController<AnyView> {
    init(bvc: BrowserViewController) {
        super.init(rootView: AnyView(EmptyView()))

        self.rootView = AnyView(
            SettingsView(dismiss: { self.dismiss(animated: true, completion: nil) })
                .environment(\.openInNewTab) { url, isPrivate in
                    self.dismiss(animated: true, completion: nil)
                    bvc.openURLInNewTab(url, isPrivate: isPrivate)
                }
                .environment(\.onOpenURL) { url in
                    self.dismiss(animated: true, completion: nil)
                    bvc.openURLInNewTabPreservingIncognitoState(url)
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
