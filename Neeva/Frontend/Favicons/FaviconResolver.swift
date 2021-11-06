// Copyright Neeva. All rights reserved.

import Combine
import Foundation
import Storage

/// Used to determine what favicon `URL` to use for a given `Site` and provides reasonable
/// fallback content to use when needed.
class FaviconResolver: ObservableObject {
    private let site: Site?

    /// Updated asynchronously when the favicon has been resolved.
    @Published var faviconUrl: URL?

    init(site: Site) {
        self.site = site
        if let favicon = site.icon {
            faviconUrl = favicon.url
            return
        }
        trySite(site: site)
    }

    init(favicon: Favicon) {
        site = nil
        faviconUrl = favicon.url
    }

    /// Provides fallback content for when we haven't fetched a favicon for this site yet.
    var fallbackContent: (image: UIImage, color: UIColor) {
        guard let site = site else {
            return (FaviconFetcher.defaultFavicon, .clear)
        }

        // Check to see if we have a bundled icon for this URL.
        if let bundledIcon = FaviconFetcher.getBundledIcon(forUrl: site.url) {
            let image = UIImage(contentsOfFile: bundledIcon.filePath)!
            return (image, bundledIcon.bgcolor)
        }

        // Next, check to see if we have a bundled icon for the eTLD.
        if let baseDomainURL = site.url.baseDomainURL,
            let bundledIcon = FaviconFetcher.getBundledIcon(forUrl: baseDomainURL)
        {
            let image = UIImage(contentsOfFile: bundledIcon.filePath)!
            return (image, bundledIcon.bgcolor)
        }

        // Finally, just render a generic favicon ourselves.
        return FaviconFetcher.letter(forUrl: site.url)
    }

    private func trySite(site: Site) {
        getAppDelegate().profile.favicons.getWidestFavicon(forSite: site).uponQueue(.main) {
            result in
            guard let favicon = result.successValue else {
                // Fallback to favicon matching just the domain and then finally just the eTLD.
                // E.g., starting with www.foo.com/bar, we will first try www.foo.com and then
                // finally try foo.com.
                let url = site.url
                if url.domainURL != url {
                    self.trySite(site: Site(url: url.domainURL))
                } else if let baseDomainURL = url.baseDomainURL, baseDomainURL != url {
                    self.trySite(site: Site(url: baseDomainURL))
                }
                return
            }
            self.faviconUrl = favicon.url
        }
    }
}
