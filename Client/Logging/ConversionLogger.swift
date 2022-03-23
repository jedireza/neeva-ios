// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Defaults
import Foundation
import Shared
import StoreKit

/// Reports conversion events to SKAdNetwork. Avoids reporting the same event
/// more than once, so it is safe to call `log(event:)` multiple times for the
/// same event.
class ConversionLogger {
    enum Event: Int {
        case launchedApp = 0
        case visitedDefaultBrowserSettings = 10
        case handledNavigationAsDefaultBrowser = 20
    }

    static func log(event: Event) {
        guard event.rawValue > Defaults[.lastReportedConversionEvent] else {
            return
        }
        Defaults[.lastReportedConversionEvent] = event.rawValue
        if event.rawValue == 0 {
            SKAdNetwork.registerAppForAdNetworkAttribution()
        } else {
            SKAdNetwork.updateConversionValue(event.rawValue)
        }
    }
}
