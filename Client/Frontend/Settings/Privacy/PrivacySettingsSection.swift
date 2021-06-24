// Copyright Neeva. All rights reserved.

import SwiftUI
import Defaults
import Shared

struct PrivacySettingsSection: View {
    @Default(.closePrivateTabs) var closePrivateTabs
    @Default(.contentBlockingEnabled) private var contentBlockingEnabled
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
        if FeatureFlag[.newTrackingProtectionSettings] {
            NavigationLink(
                "Tracking Protection",
                destination: List {
                    Section(header: Text("Global Privacy Settings").padding(.top, 21)) {
                        TrackingSettingsBlock(
                            blockTrackingCookies: .constant(true),
                            blockTrackingRequests: .constant(true),
                            upgradeToHTTPS: .constant(true)
                        )
                    }
                    TrackingAttribution()
                }
                .listStyle(GroupedListStyle())
                .applyToggleStyle()
                .navigationTitle("Tracking Protection")
                .onAppear {
                    ClientLogger.shared.logCounter(.ViewTrackingProtection, attributes: EnvironmentHelper.shared.getAttributes())
                }
            )
        } else {
            Toggle("Tracking Protection", isOn: $contentBlockingEnabled)
        }
        NavigationLinkButton("Privacy Policy") {
            ClientLogger.shared.logCounter(.ViewPrivacyPolicy, attributes: EnvironmentHelper.shared.getAttributes())
            openURL(NeevaConstants.appPrivacyURL)
        }
    }
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
