// Copyright Neeva. All rights reserved.

import Shared
import SwiftUI

struct DebugDBSettingsSection: View {
    var body: some View {
        Section(header: Text("Debug — Databases")) {
            Button("Copy Databases to App Container") {
                let documentsPath = NSSearchPathForDirectoriesInDomains(
                    .documentDirectory, .userDomainMask, true)[0]
                do {
                    let log = Logger.storage
                    try BrowserViewController.foregroundBVC().profile.files.copyMatching(
                        fromRelativeDirectory: "", toAbsoluteDirectory: documentsPath
                    ) { file in
                        log.debug("Matcher: \(file)")
                        return file.hasPrefix("browser.") || file.hasPrefix("logins.")
                            || file.hasPrefix("metadata.")
                    }
                } catch {
                    print("Couldn't export browser data: \(error).")
                }
            }
            Button("Delete Exported Databases") {
                let documentsPath = NSSearchPathForDirectoriesInDomains(
                    .documentDirectory, .userDomainMask, true)[0]
                let fileManager = FileManager.default
                do {
                    let files = try fileManager.contentsOfDirectory(atPath: documentsPath)
                    for file in files {
                        if file.hasPrefix("browser.") || file.hasPrefix("logins.") {
                            try fileManager.removeItemInDirectory(documentsPath, named: file)
                        }
                    }
                } catch {
                    print("Couldn't delete exported data: \(error).")
                }
            }
            Button("Simulate Slow Database Operations") {
                debugSimulateSlowDBOperations.toggle()
            }
        }
    }
}

struct DebugDBSettings_Previews: PreviewProvider {
    static var previews: some View {
        SettingPreviewWrapper {
            DebugDBSettingsSection()
        }
    }
}
