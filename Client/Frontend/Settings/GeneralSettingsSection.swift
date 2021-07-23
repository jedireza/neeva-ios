// Copyright Neeva. All rights reserved.

import SwiftUI
import Defaults

struct DetailedSettingsLabel: View {
    let title: String
    let description: String
    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
            Text(description)
                .foregroundColor(.secondaryLabel)
                .font(.caption)
        }
    }
}

struct GeneralSettingsSection: View {
    @Default(.showSearchSuggestions) var showSearchSuggestions
    @Default(.blockPopups) var blockPopups
    @Default(.showClipboardBar) var showClipboardBar
    @Default(.contextMenuShowLinkPreviews) var showLinkPreviews

    var body: some View {
        NavigationLink(
            "Default Browser",
            destination:
                DefaultBrowserOnboardingView(openSettings: {
                    UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!, options: [:])
                })
                .onAppear {
                    ClientLogger.shared.logCounter(.SettingDefaultBrowser, attributes: EnvironmentHelper.shared.getAttributes())
                }
        )
        Toggle("Show Search Suggestions", isOn: $showSearchSuggestions)
        Toggle("Block Pop-up Windows", isOn: $blockPopups)
        Toggle(isOn: $showClipboardBar) {
            DetailedSettingsLabel(
                title: "Offer to Open Copied Links",
                description: "When Opening Neeva"
            )
        }
        Toggle(isOn: $showLinkPreviews) {
            DetailedSettingsLabel(
                title: "Show Link Previews",
                description: "When Long-pressing Links"
            )
        }
    }
}

struct GeneralSettingsSection_Previews: PreviewProvider {
    static var previews: some View {
        SettingPreviewWrapper {
            Section(header: Text("General")) {
                GeneralSettingsSection()
            }
        }
    }
}
