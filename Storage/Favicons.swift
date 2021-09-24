/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import Shared
import UIKit

public protocol Favicons {
    /// Adds a mapping from Site to Favicon. A Site can have many associated Favicons,
    /// each with a unique URL.
    ///
    /// If `icon.id` is `nil`, then the `id` for the favicon will be resolved by
    /// looking up `icon.url` (or inserting it) in the `favicons` table.
    ///
    /// If `site.id` is `nil`, then the `id` for the site will be resolved by looking
    /// up `site.url` in the `history` table.
    ///
    /// Note: The `width` and `height` fields of `icon` should be set before calling
    /// this function.
    ///
    /// On success, returns the ID of the added favicon.
    @discardableResult func addFavicon(_ icon: Favicon, forSite site: Site) -> Deferred<Maybe<Int>>

    /// Looks up and returns the widest favicon for the given site.
    ///
    /// If `site.id` is `nil`, then the `id` for the site will be resolved by looking
    /// up `site.url` in the `history` table.
    ///
    /// On success, returns the corresponding `Favicon`.
    func getWidestFavicon(forSite site: Site) -> Deferred<Maybe<Favicon>>
}
