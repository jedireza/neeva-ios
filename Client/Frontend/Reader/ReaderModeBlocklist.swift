// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Foundation

struct ReaderModeBlocklist {
    // (host suffix, path prefix)
    static let blockedSites: [(String, String)] = [
        ("neeva.com", "/search"),
        ("neeva.com", "/spaces"),
        ("google.com", "/search"),
        ("twitter.com", "/home"),
        ("carfax.com", "/vehicle"),
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
