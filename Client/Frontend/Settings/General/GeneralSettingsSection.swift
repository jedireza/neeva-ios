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
    @Default(.mailToOption) var mailToOption
    @Default(.blockPopups) var blockPopups
    @Default(.showClipboardBar) var showClipboardBar
    @Default(.contextMenuShowLinkPreviews) var showLinkPreviews

    var body: some View {
        Toggle("Show Search Suggestions", isOn: $showSearchSuggestions)
        // have to pass the binding down otherwise this view is not updated
        // see: https://github.com/sindresorhus/Defaults/issues/59
        NavigationLink(destination: MailAppSetting(mailToOption: $mailToOption)) {
            HStack {
                Text("Mail App")
                Spacer()
                if mailToOption != "mailto:",
                   let name = MailAppSetting.mailProviderSource.first { $0.scheme == mailToOption }?.name {
                    Text(name)
                        .foregroundColor(.secondaryLabel)
                }
            }
        }
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
            SwiftUI.Section(header: Text("General")) {
                GeneralSettingsSection()
            }
        }
    }
}
