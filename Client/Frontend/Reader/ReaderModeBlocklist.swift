// Copyright Neeva. All rights reserved.

import Foundation

struct ReaderModeBlocklist {
    // (host suffix, path prefix)
    static let blockedSites: [(String, String)] = [
        ("neeva.com", "/search"),
        ("google.com", "/search"),
        ("twitter.com", "/home"),
        ("carfax.com", "/vehicle")
    ]

    static func isSiteBlocked(url: URL) -> Bool {
        guard let host = url.host else {
            return false
        }

        for site in blockedSites {
            if host.hasSuffix(site.0) && url.path.hasPrefix(site.1) {
                return true
            }
        }

        return false
    }
}
