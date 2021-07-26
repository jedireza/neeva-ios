/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import UIKit
import Shared

open class Favicon: Identifiable {
    open var id: Int?

    public let url: String
    public let date: Date
    open var width: Int?
    open var height: Int?

    public init(url: String, date: Date = Date()) {
        self.url = url
        self.date = date
    }
}

// TODO: Site shouldn't have all of these optional decorators. Include those in the
// cursor results, perhaps as a tuple.
open class Site {
    open var id: Int?
    var guid: String?

    open var tileURL: URL {
        url.domainURL
    }

    public let url: URL
    public let title: String
    open var metadata: PageMetadata?
     // Sites may have multiple favicons. We'll return the largest.
    open var icon: Favicon?
    open var latestVisit: Visit?

    public init(url: URL, title: String, id: Int? = nil) {
        self.url = url
        self.title = title
        self.id = id
    }

    public init(url: URL, title: String, guid: String?) {
        self.url = url
        self.title = title
        self.guid = guid
    }
}

extension Site: Hashable {
    public static func == (lhs: Site, rhs: Site) -> Bool {
        lhs.id == rhs.id && lhs.guid == rhs.guid
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(guid)
    }
}
