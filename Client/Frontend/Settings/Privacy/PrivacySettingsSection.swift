// Copyright Neeva. All rights reserved.

import SwiftUI
import Defaults
import Shared

struct PrivacySettingsSection: View {
    @Default(.closePrivateTabs) var closePrivateTabs
    @Environment(\.onOpenURL) var openURL

    var body: some View {
        NavigationLink(
            "Data Management",
            destination: DataManagementView()
                .onAppear {
                    ClientLogger.shared.logCounter(.ViewDataManagement, attributes: EnvironmentHelper.shared.getAttributes())
                }
        )
        Toggle(isOn: $closePrivateTabs) {
            DetailedSettingsLabel(
                title: "Close Private Tabs",
                description: "When Leaving Private Browsing"
            )
        }
        NavigationLink(
            "Tracking Protection",
            destination: TrackingProtectionView()
                .navigationTitle("Tracking Protection")
                .onAppear {
                    ClientLogger.shared.logCounter(.ViewTrackingProtection, attributes: EnvironmentHelper.shared.getAttributes())
                }
        )
        NavigationLinkButton("Privacy Policy") {
            ClientLogger.shared.logCounter(.ViewPrivacyPolicy, attributes: EnvironmentHelper.shared.getAttributes())
            openURL(NeevaConstants.appPrivacyURL)
        }
    }
}

// TODO: rewrite in SwiftUI
struct TrackingProtectionView: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> some UIViewController {
        let viewController = ContentBlockerSettingViewController()
        let bvc = BrowserViewController.foregroundBVC()
        viewController.profile = bvc.profile
        viewController.tabManager = bvc.tabManager
        return viewController
    }
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {}
}

struct PrivacySettingsSection_Previews: PreviewProvider {
    static var previews: some View {
        SettingPreviewWrapper {
            SwiftUI.Section(header: Text("Privacy")) {
                PrivacySettingsSection()
            }
        }
    }
}
