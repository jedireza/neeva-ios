// Copyright © Neeva. All rights reserved.

import SwiftUI
import Shared
import Defaults

// known issue: removing an entry from this enum will cause the user’s settings to be cleared
enum ClearableDataType: String, Identifiable, Codable, CaseIterable {
    case history = "Browsing History"
    case cache = "Cache"
    case cookies = "Cookies"
    case siteData = "Offline Website Data"
    case trackingProtection = "Tracking Protection"
    case downloads = "Downloaded Files"

    var id: String { rawValue }

    func clearable(profile: Profile, tabManager: TabManager) -> Clearable {
        switch self {
        case .history:
            return HistoryClearable(profile: profile)
        case .cache:
            return CacheClearable(tabManager: tabManager)
        case .cookies:
            return CookiesClearable(tabManager: tabManager)
        case .siteData:
            return SiteDataClearable(tabManager: tabManager)
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

            Section(header: Text("Clear Private Data")) {
                ForEach(ClearableDataType.allCases) { dataType in
                    Toggle(dataType.rawValue, isOn: Binding {
                        clearDataTypes.contains(dataType)
                    } set: { isOn in
                        if isOn {
                            clearDataTypes.insert(dataType)
                        } else {
                            clearDataTypes.remove(dataType)
                        }
                    })
                }
            }.onChange(of: clearDataTypes) { _ in
                showingSuccess = false
            }

            DecorativeSection {
                HStack {
                    Spacer(minLength: 0)
                    if showingSuccess {
                        Text("Private data cleared successfully")
                            .multilineTextAlignment(.center)
                            .foregroundColor(.green)
                            .saturation(0.5)
                    } else {
                        Button("Clear Private Data") { isDeleting = true }
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
        }
        .navigationTitle("Data Management")
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
