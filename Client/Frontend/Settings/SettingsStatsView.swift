// Copyright Neeva. All rights reserved.

import SwiftUI
import Shared

struct SettingsStatsView: View {
    private struct Row: View {
        let name: String
        enum Value {
            case valid(String)
            case date(Date, Text.DateStyle)
            case error(String)
            case loading
        }
        let value: () -> Value

        var body: some View {
            HStack {
                Text(name).withFont(.labelLarge)
                Spacer()
                switch value() {
                case let .valid(value):
                    Text(value)
                        .withFont(.bodyLarge)
                    Button(action: { UIPasteboard.general.string = value }) {
                        Symbol(.docOnDoc, label: "Copy")
                    }.buttonStyle(BorderlessButtonStyle())
                case let .error(error):
                    Text(error)
                        .withFont(.bodyLarge)
                        .foregroundColor(.red)
                    Button(action: { UIPasteboard.general.string = error }) {
                        Symbol(.docOnDoc, label: "Copy")
                    }.buttonStyle(BorderlessButtonStyle())
                case let .date(date, style):
                    Text(date, style: style)
                        .withFont(.bodyLarge)
                    Button(action: { UIPasteboard.general.string = date.debugDescription }) {
                        Symbol(.docOnDoc, label: "Copy")
                    }.buttonStyle(BorderlessButtonStyle())
                case .loading:
                    ProgressView()
                }
            }
        }
    }

    @ObservedObject var spaceStore = SpaceStore.shared
    @ObservedObject var userInfo = NeevaUserInfo.shared
    @EnvironmentObject var tabManager: TabManager

    var body: some View {
        List {
            Row(name: "Uptime") {
                .date(_startupTime, .relative)
            }
            Row(name: "Tabs") {
                .valid("\(tabManager.normalTabs.count)")
            }
            Row(name: "Incognito Tabs") {
                .valid("\(tabManager.privateTabs.count)")
            }
            Row(name: "Spaces") {
                switch spaceStore.state {
                case .refreshing:
                    return .loading
                case .ready:
                    return .valid("\(spaceStore.allSpaces.count)")
                case .failed:
                    return .error("Error")
                }
            }.onAppear {
                spaceStore.refresh()
            }
            Row(name: "User ID") {
                if userInfo.isLoading {
                    return .loading
                } else if let id = userInfo.id {
                    return .valid(id)
                } else {
                    return .error("Not Logged In")
                }
            }.onAppear {
                userInfo.updateKeychainTokenAndFetchUserInfo()
            }
        }
    }
}

struct SettingsStatsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsStatsView()
            .environmentObject(TabManager(profile: BrowserProfile(localName: "profile"), imageStore: nil))
    }
}
