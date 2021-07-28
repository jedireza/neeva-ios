/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import Defaults
import Foundation
import Shared

struct WidgetKitTopSiteModel: Codable {
    var title: String
    var faviconUrl: String
    var url: URL
    var imageKey: String

    static let userDefaults = UserDefaults(suiteName: AppInfo.sharedContainerIdentifier)!

    static func save(widgetKitTopSites: [WidgetKitTopSiteModel]) {
        Defaults[.widgetKitSimpleTopTab] = try? JSONEncoder().encode(widgetKitTopSites)
    }

    static func get() -> [WidgetKitTopSiteModel] {
        if let topSites = Defaults[.widgetKitSimpleTopTab] {
            do {
                let jsonDecoder = JSONDecoder()
                let sites = try jsonDecoder.decode([WidgetKitTopSiteModel].self, from: topSites)
                return sites
            } catch {
                print("Error occured")
            }
        }
        return [WidgetKitTopSiteModel]()
    }
}
