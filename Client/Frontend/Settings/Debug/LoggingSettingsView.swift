// Copyright Neeva. All rights reserved.

import Defaults
import Shared
import SwiftUI

struct LoggingSettingsView: View {
    @Default(.enableBrowserLogging) var enableBrowserLogging
    @Default(.enableNetworkLogging) var enableNetworkLogging
    @Default(.enableStorageLogging) var enableStorageLogging
    @Default(.enableLogToConsole) var enableLogToConsole
    @Default(.enableLogToFile) var enableLogToFile

    var body: some View {
        List {
            Section(header: Text("Categories")) {
                Group {
                    Toggle("browser", isOn: $enableBrowserLogging)
                    Toggle("network", isOn: $enableNetworkLogging)
                    Toggle("storage", isOn: $enableStorageLogging)
                }.font(.system(.body, design: .monospaced))
            }
            Section(header: Text("Options")) {
                Toggle("Log to console", isOn: $enableLogToConsole)
                Toggle("Log to file", isOn: $enableLogToFile)
            }
            DecorativeSection {
                Button("Roll Log Files") {
                    Logger.rollLogs()
                }
                Button("Snapshot Log Files") {
                    Logger.copyPreviousLogsToDocuments()
                }
            }
            DecorativeSection {
                Button("Delete Log Files") {
                    Logger.deleteLogs()
                }.accentColor(.red)
            }
        }
        .listStyle(GroupedListStyle())
        .applyToggleStyle()
    }
}

struct LoggingSettings_Previews: PreviewProvider {
    static var previews: some View {
        LoggingSettingsView()
        LoggingSettingsView().previewDevice("iPhone 8")
    }
}
