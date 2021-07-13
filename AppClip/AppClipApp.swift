// Copyright Neeva. All rights reserved.

import SwiftUI

@main
struct AppClipApp: App {
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
        print("testValue: \(testValue)")
    }
}
