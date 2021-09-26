// Copyright Neeva. All rights reserved.

import SDWebImageSwiftUI
import Storage
import SwiftUI

struct FaviconView: View {
    @ObservedObject private var resolver: FaviconResolver

    /// If `site.icon` is not provided, then the `Favicon` to use will be resolved by looking in
    /// the history database for the `Favicon` associated with the `site.url`. If that is not
    /// found, then a fallback favicon will be used.
    init(forSite site: Site) {
        self.resolver = FaviconResolver(site: site)
    }

    // For use when only the `url` of a website is available.
    init(forSiteUrl url: URL) {
        self.init(forSite: Site(url: url))
    }

    // For use when only the `url` of the favicon is available.
    init(forFavicon favicon: Favicon) {
        self.resolver = FaviconResolver(favicon: favicon)
    }

    var body: some View {
        WebImage(url: resolver.faviconUrl)
            .resizable()
            .placeholder {
                let (image, bgcolor) = resolver.fallbackContent
                Image(uiImage: image)
                    .resizable()
                    .background(Color(bgcolor))
            }
            .transition(.opacity)
            .scaledToFit()
    }
}
