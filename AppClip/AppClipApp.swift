// Copyright Neeva. All rights reserved.

import SwiftUI

@main
struct AppClipApp: App {
    static let neevaAppStorePageURL = URL(
        string: "https://apps.apple.com/us/app/neeva-browser-search-engine/id1543288638")!

    var body: some Scene {
        WindowGroup {
            ContentView()
                .onContinueUserActivity(NSUserActivityTypeBrowsingWeb, perform: handleUserActivity)
        }
    }

    func handleUserActivity(_ userActivity: NSUserActivity) {
        guard
            let incomingURL = userActivity.webpageURL,
            let components = URLComponents(url: incomingURL, resolvingAgainstBaseURL: true),
            let queryItems = components.queryItems,
            let signInToken = queryItems.first(where: { $0.name == "token" })?.value,
            components.path == "/appclip/login"
        else { return }

        AppClipHelper.saveTokenToDevice(signInToken)

        UIApplication.shared.open(
            AppClipApp.neevaAppStorePageURL, options: [:], completionHandler: nil)
    }
}
