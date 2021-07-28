// Copyright Neeva. All rights reserved.

import Defaults
import Shared
import SwiftUI

struct InternalSettingsView: View {
    @Default(.searchInputPromptDismissed) var searchInputPromptDismissed
    @Default(.introSeen) var introSeen
    @Default(.lastVersionNumber) var lastVersionNumber
    @Default(.didShowDefaultBrowserOnboarding) var didShowDefaultBrowserOnboarding
    @Default(.didDismissDefaultBrowserCard) var didDismissDefaultBrowserCard
    @Default(.didDismissReferralPromoCard) var didDismissReferralPromoCard
    @Default(.deletedSuggestedSites) var deletedSuggestedSites
    @Default(.recentlyClosedTabs) var recentlyClosedTabs
    @Default(.saveLogins) var saveLogins
    @Default(.topSitesCacheIsValid) var topSitesCacheIsValid
    @Default(.topSitesCacheSize) var topSitesCacheSize
    @Default(.appExtensionTelemetryOpenUrl) var appExtensionTelemetryOpenUrl
    @Default(.widgetKitSimpleTabKey) var widgetKitSimpleTabKey
    @Default(.widgetKitSimpleTopTab) var widgetKitSimpleTopTab

    var body: some View {
        List {
            Section(header: Text("Implicit")) {
                Toggle("searchInputPromptDismissed", isOn: $searchInputPromptDismissed)
                Toggle("introSeen", isOn: $introSeen)
                OptionalStringField("lastVersionNumber", text: $lastVersionNumber)
                Toggle("didShowDefaultBrowserOnboarding", isOn: $didShowDefaultBrowserOnboarding)
                Toggle("didDismissDefaultBrowserCard", isOn: $didDismissDefaultBrowserCard)
                Toggle("didDismissReferralPromoCard", isOn: $didDismissReferralPromoCard)
            }
            Section(header: Text("User-generated")) {
                HStack {
                    VStack(alignment: .leading) {
                        Text("deletedSuggestedSites")
                        Text(
                            "\(deletedSuggestedSites.count) site\(deletedSuggestedSites.count == 1 ? "" : "s")"
                        )
                        .foregroundColor(.secondaryLabel)
                        .font(.caption)
                    }
                    Spacer()
                    Button("Clear") { deletedSuggestedSites = [] }
                        .font(.body)
                        .accentColor(.red)
                        .buttonStyle(BorderlessButtonStyle())
                }
                OptionalDataKeyView("recentlyClosedTabs", data: $recentlyClosedTabs)
            }

            Section(header: Text("Miscellaneous")) {
                // enable if you’re working on logins and need access
                Toggle("saveLogins", isOn: $saveLogins)
                    .disabled(!saveLogins)

                OptionalBooleanField(
                    "appExtensionTelemetryOpenUrl", value: $appExtensionTelemetryOpenUrl)
            }

            Section(header: Text("Top Sites Cache")) {
                HStack {
                    Text("topSitesCacheIsValid")
                    Spacer()
                    Text(String(topSitesCacheIsValid))
                        .foregroundColor(.secondaryLabel)
                }
                OptionalNumberField("topSitesCacheSize", number: $topSitesCacheSize)
            }

            Section(header: Text("WidgetKit")) {
                OptionalDataKeyView("widgetKitSimpleTabKey", data: $widgetKitSimpleTabKey)
                OptionalDataKeyView("widgetKitSimpleTopTab", data: $widgetKitSimpleTopTab)
            }
        }
        .font(.system(.footnote, design: .monospaced))
        .minimumScaleFactor(0.75)
        .listStyle(GroupedListStyle())
        .applyToggleStyle()
    }
}

private struct OptionalBooleanField: View {
    init(_ title: String, value: Binding<Bool?>) {
        self.title = title
        self._value = value
    }

    let title: String
    @Binding var value: Bool?

    var body: some View {
        HStack {
            Text(title)
            Spacer()
            Menu {
                Button {
                    value = true
                } label: {
                    if value == true {
                        Label("true", systemSymbol: .checkmark)
                    } else {
                        Text("true")
                    }
                }
                Button {
                    value = false
                } label: {
                    if value == false {
                        Label("false", systemSymbol: .checkmark)
                    } else {
                        Text("false")
                    }
                }
                Button {
                    value = nil
                } label: {
                    if value == nil {
                        Label("nil", systemSymbol: .checkmark)
                    } else {
                        Text("nil")
                    }
                }
            } label: {
                HStack {
                    Text(value.map { String($0) } ?? "nil")
                    Symbol(.chevronDown)
                }
            }
        }
    }
}

private struct OptionalNumberField<Number: FixedWidthInteger>: View {
    init(_ title: String, number: Binding<Number?>) {
        self.title = title
        self._number = number
    }

    let title: String
    @Binding var number: Number?

    var body: some View {
        HStack {
            Text(title)
            TextField(
                "nil",
                text: Binding(
                    get: { number.map { String($0) } ?? "" },
                    set: {
                        if let parsed = Number($0) {
                            number = parsed
                        } else if $0.isEmpty {
                            number = nil
                        }
                    }
                )
            ).multilineTextAlignment(.trailing)
        }
    }
}

private struct NumberField<Number: FixedWidthInteger>: View {
    init(_ title: String, number: Binding<Number>) {
        self.title = title
        self._number = number
    }

    let title: String
    @Binding var number: Number
    var body: some View {
        HStack {
            Text(title)
            TextField(
                "0",
                text: Binding(
                    get: { String(number) },
                    set: {
                        if let parsed = Number($0) {
                            number = parsed
                        }
                    }
                )
            ).multilineTextAlignment(.trailing)
        }
    }
}

private struct OptionalStringField: View {
    init(_ title: String, text: Binding<String?>) {
        self.title = title
        self._text = text
    }

    let title: String
    @Binding var text: String?

    var body: some View {
        HStack {
            Text(title)
            TextField(
                "nil",
                text: Binding(
                    get: { text ?? "" },
                    set: { text = $0.isEmpty ? nil : $0 }
                )
            ).multilineTextAlignment(.trailing)
        }
    }
}

private struct OptionalDataKeyView: View {
    init(_ name: String, data: Binding<Data?>) {
        self.name = name
        self._data = data
    }

    let name: String
    @Binding var data: Data?

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(name)
                Group {
                    if let data = data {
                        Text(ByteCountFormatter().string(fromByteCount: Int64(data.count)))
                            .font(.caption)
                    } else {
                        Text("nil")
                            .font(.system(.caption, design: .monospaced))
                    }
                }
                .foregroundColor(.secondaryLabel)
            }
            Spacer()
            Button("Clear") { data = nil }
                .font(.body)
                .accentColor(.red)
                .buttonStyle(BorderlessButtonStyle())
        }
    }
}

struct InternalSettings_Previews: PreviewProvider {
    static var previews: some View {
        InternalSettingsView()
        InternalSettingsView().previewDevice("iPhone 8")
    }
}
