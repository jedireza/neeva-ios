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
    let dismiss: () -> Void

    #if DEBUG
        @State var showDebugSettings = true
    #else
        @State var showDebugSettings = false
    #endif

    let scrollViewAppearance = UINavigationBar.appearance().scrollEdgeAppearance

    var body: some View {
        ZStack {
            NavigationView {
                List {
                    if NeevaConstants.currentTarget != .xyz {
                        Section(header: Text("Neeva")) {
                            NeevaSettingsSection(dismissVC: dismiss, userInfo: .shared)
                        }
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
                .onDisappear(perform: TourManager.shared.notifyCurrentViewClose)
                .listStyle(.insetGrouped)
                .applyToggleStyle()
                .navigationTitle("Settings")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Done", action: dismiss)
                    }
                }
            }.navigationViewStyle(.stack)

            OverlayView(limitToOverlayType: [.toast(nil)])
        }
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

class SettingsViewController: UIHostingController<AnyView> {
    init(bvc: BrowserViewController) {
        super.init(rootView: AnyView(EmptyView()))

        self.rootView = AnyView(
            SettingsView(dismiss: { self.dismiss(animated: true, completion: nil) })
                .environment(\.openInNewTab) { url, isIncognito in
                    self.dismiss(animated: true, completion: nil)
                    bvc.openURLInNewTab(url, isIncognito: isIncognito)
                }
                .environment(\.onOpenURL) { url in
                    self.dismiss(animated: true, completion: nil)
                    bvc.openURLInNewTabPreservingIncognitoState(url)
                }
                .environment(\.settingsPresentIntroViewController) {
                    self.dismiss(animated: true) {
                        bvc.presentIntroViewController(
                            true,
                            completion: {
                                bvc.hideZeroQuery()
                            })
                    }
                }
                .environment(\.dismissScreen) {
                    self.dismiss(animated: true, completion: nil)
                }
                .environment(\.showNotificationPrompt) {
                    bvc.showAsModalOverlaySheet(
                        style: OverlayStyle(
                            showTitle: false,
                            backgroundColor: .systemBackground)
                    ) {
                        NotificationPromptViewOverlayContent()
                    } onDismiss: {
                    }
                }
                .environmentObject(bvc.browserModel)
                .environmentObject(bvc.browserModel.scrollingControlModel)
                .environmentObject(bvc.chromeModel)
                .environmentObject(bvc.overlayManager)
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
