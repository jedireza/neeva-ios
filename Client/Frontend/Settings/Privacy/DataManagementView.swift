// Copyright © Neeva. All rights reserved.

import SwiftUI
import Shared
import Defaults

// known issue: removing an entry from this enum will cause the user’s settings to be cleared
enum ClearableDataType: String, Identifiable, Codable, CaseIterable {
    case history = "Browsing History"
    case cache = "Cache"
    case cookies = "Cookies"
    case trackingProtection = "Tracking Protection"
    case downloads = "Downloaded Files"

    var id: String { rawValue }

    var description: String? {
        switch self {
        case .cookies:
            return "Clearing it will sign you out of most sites."
        default:
            return nil
        }
    }

    func clearable(profile: Profile, tabManager: TabManager) -> Clearable {
        switch self {
        case .history:
            return HistoryClearable(profile: profile)
        case .cache:
            return CacheClearable(tabManager: tabManager)
        case .cookies:
            return CookiesClearable(tabManager: tabManager)
        case .trackingProtection:
            return TrackingProtectionClearable()
        case .downloads:
            return DownloadedFilesClearable()
        }
    }
}

extension Defaults.Keys {
    fileprivate static let clearDataTypes = Defaults.Key<Set<ClearableDataType>>("profile.dataManagement.clearTypes", default: Set(ClearableDataType.allCases).filter { $0 != .downloads })
}

struct DataManagementView: View {
    @State private var clearDataTypes = Defaults[.clearDataTypes]
    @State private var isDeleting = false
    @State var showingSuccess = false
    @Environment(\.openInNewTab) var openURL

    func onClear() {
        let bvc = BrowserViewController.foregroundBVC()
        clearDataTypes
            .map { $0.clearable(profile: bvc.profile, tabManager: bvc.tabManager).clear() }
            .allSucceed()
            .uponQueue(.main) { result in
                assert(result.isSuccess, "Private data was not cleared successfully")
                Defaults[.clearDataTypes] = clearDataTypes
                showingSuccess = true
            }
    }

    var body: some View {
        List {
            DecorativeSection {
                NavigationLink("Website Data", destination: WebsiteDataView())
            }

            Section(header: Text("Data on This Device")) {
                ForEach(ClearableDataType.allCases) { dataType in
                    Toggle(isOn: Binding {
                        clearDataTypes.contains(dataType)
                    } set: { isOn in
                        if isOn {
                            clearDataTypes.insert(dataType)
                        } else {
                            clearDataTypes.remove(dataType)
                        }
                    }){
                        if let description = dataType.description {
                            DetailedSettingsLabel(title: dataType.rawValue, description: description)
                        } else {
                            Text(dataType.rawValue)
                        }
                    }
                }
            }.onChange(of: clearDataTypes) { _ in
                showingSuccess = false
            }

            Group {
                HStack {
                    Spacer(minLength: 0)
                    if showingSuccess {
                        Text("Selected data cleared successfully")
                            .multilineTextAlignment(.center)
                            .foregroundColor(.green)
                            .saturation(0.5)
                    } else {
                        Button("Clear Selected Data on This Device") { isDeleting = true }
                            .disabled(clearDataTypes.isEmpty)
                            .accentColor(.red)
                    }
                    Spacer(minLength: 0)
                }.actionSheet(isPresented: $isDeleting) {
                    ActionSheet(
                        title: Text("This action will clear all of your private data. It cannot be undone."),
                        buttons: [
                            .destructive(Text("Clear Data"), action: self.onClear),
                            .cancel()
                        ]
                    )
                }
            }

            if NeevaFeatureFlags[.neevaMemory] {
                Section(header: Text("Data in Neeva Memory")) {
                    NavigationLinkButton("Manage Neeva Memory") {
                        openURL(NeevaConstants.appMemoryModeURL, false)
                        BrowserViewController.foregroundBVC().dismissVC()
                    }
                }
            }
        }
        .navigationTitle("Clear Browsing Data")
        .listStyle(GroupedListStyle())
        .applyToggleStyle()
    }
}

struct DataManagementView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            DataManagementView()
                .navigationBarTitleDisplayMode(.inline)
        }
        NavigationView {
            DataManagementView(showingSuccess: true)
                .navigationBarTitleDisplayMode(.inline)
        }
    }
}
