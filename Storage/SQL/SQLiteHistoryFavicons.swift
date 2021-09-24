/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import Foundation
import Shared
import XCGLogger

private let log = Logger.storage

class FaviconLookupError: MaybeErrorType {
    let site: Site
    init(site: Site) {
        self.site = site
    }
    var description: String {
        return "Unable to find favicon for site: \(site.url)"
    }
}

extension SQLiteHistory: Favicons {
    /// This method assumes that the site has already been recorded
    /// in the history table.
    public func addFavicon(_ icon: Favicon, forSite site: Site) -> Deferred<Maybe<Int>> {
        func doChange(_ query: String, args: Args?) -> Deferred<Maybe<Int>> {
            return db.withConnection { conn -> Int in
                // Blind! We don't see failure here.
                let id = self.favicons.insertOrUpdateFaviconInTransaction(icon, conn: conn)

                // Now set up the mapping.
                try conn.executeChange(query, withArgs: args)

                guard let faviconID = id else {
                    let err = DatabaseError(description: "Error adding favicon. ID = 0")
                    log.error("encountered an error: \(err.localizedDescription)")
                    throw err
                }

                return faviconID
            }
        }

        let siteSubselect = "(SELECT id FROM history WHERE url = ?)"
        let iconSubselect = "(SELECT id FROM favicons WHERE url = ?)"
        let insertOrIgnore = "INSERT OR IGNORE INTO favicon_sites (siteID, faviconID) VALUES "
        if let iconID = icon.id {
            // Easy!
            if let siteID = site.id {
                // So easy!
                let args: Args? = [siteID, iconID]
                return doChange("\(insertOrIgnore) (?, ?)", args: args)
            }

            // Nearly easy.
            let args: Args? = [site.url.absoluteString, iconID]
            return doChange("\(insertOrIgnore) (\(siteSubselect), ?)", args: args)

        }

        // Sigh.
        if let siteID = site.id {
            let args: Args? = [siteID, icon.url.absoluteString]
            return doChange("\(insertOrIgnore) (?, \(iconSubselect))", args: args)
        }

        // The worst.
        let args: Args? = [site.url.absoluteString, icon.url.absoluteString]
        return doChange("\(insertOrIgnore) (\(siteSubselect), \(iconSubselect))", args: args)
    }

    public func getWidestFavicon(forSite site: Site) -> Deferred<Maybe<Favicon>> {
        func queryBySiteID(_ id: Int) -> Deferred<Maybe<Cursor<Favicon?>>> {
            let sql = """
                SELECT iconID, iconURL, iconDate
                FROM (
                    SELECT iconID, iconURL, iconDate
                    FROM view_favicons_widest
                    WHERE siteID = ?
                ) LIMIT 1
                """
            let args: Args = [id]
            return db.runQueryConcurrently(
                sql, args: args, factory: SQLiteHistory.iconColumnFactory)
        }

        func queryBySiteURL(_ url: URL) -> Deferred<Maybe<Cursor<Favicon?>>> {
            let sql = """
                SELECT iconID, iconURL, iconDate
                FROM (
                    SELECT iconID, iconURL, iconDate
                    FROM view_favicons_widest, history
                    WHERE history.id = siteID AND history.url = ?
                ) LIMIT 1
                """
            let args: Args = [url.absoluteString]
            return db.runQueryConcurrently(
                sql, args: args, factory: SQLiteHistory.iconColumnFactory)
        }

        func queryBySite(_ site: Site) -> Deferred<Maybe<Cursor<Favicon?>>> {
            if let id = site.id {
                return queryBySiteID(id)
            }
            return queryBySiteURL(site.url)
        }

        let deferred = CancellableDeferred<Maybe<Favicon>>()
        queryBySite(site).upon { result in
            guard let favicons = result.successValue,
                let favicon = favicons[0],
                let unwrapped = favicon
            else {
                deferred.fill(Maybe(failure: FaviconLookupError(site: site)))
                return
            }
            deferred.fill(Maybe(success: unwrapped))
        }
        return deferred
    }
}
