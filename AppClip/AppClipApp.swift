// Copyright Neeva. All rights reserved.

import SwiftUI

@main
struct AppClipApp: App {
    static let appClipSuiteName = "group.co.neeva.app.ios.browser.app-clip.login"

    var body: some Scene {
        WindowGroup {
            ContentView()
                .onContinueUserActivity(NSUserActivityTypeBrowsingWeb, perform: handleUserActivity)
        }
    }

    func handleUserActivity(_ userActivity: NSUserActivity) {
        guard let incomingURL = userActivity.webpageURL,
              let components = URLComponents(url: incomingURL, resolvingAgainstBaseURL: true),
              let queryItems = components.queryItems else { return }

        guard let testValue = queryItems.first(where: { $0.name == "testValue" })?.value else { return }
        AppClipApp.saveDataToDevice(data: testValue)
    }

    static func saveDataToDevice(data: String) {
        guard let containerURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appClipSuiteName)?.appendingPathComponent("AppClipValue") else {
            return
        }

        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(data)
            try data.write(to: containerURL)
        } catch {
            print("Whoops, an error occured: \(error)")
        }
    }
}
