/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import SDWebImage
import Shared
import Storage
import UIKit

extension UIColor {
    var components: (red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) {
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        getRed(&r, green: &g, blue: &b, alpha: &a)
        return (r, g, b, a)
    }
}

extension UIImageView {

    public func setImageAndBackground(
        forIcon icon: Favicon?, website: URL?, completion: @escaping () -> Void
    ) {
        var site: Site?
        if let website = website {
            site = Site(url: website)
            site?.icon = icon
        }
        setFavicon(forSite: site, completion: completion)
    }

    public func setFavicon(forSite site: Site?, completion: @escaping () -> Void) {
        let defaultBackground = UIColor(light: .white, dark: .clear)

        let defaults: (image: UIImage, color: UIColor)
        if let site = site {
            defaults = FaviconResolver(site: site).fallbackContent
        } else {
            defaults = (FaviconFetcher.defaultFavicon, defaultBackground)
        }

        // If the background color is clear, we may decide to set our own background based on the theme.
        self.backgroundColor =
            defaults.color.components.alpha < 0.01 ? defaultBackground : defaults.color

        sd_setImage(with: site?.icon?.url, placeholderImage: defaults.image) { (img, err, _, _) in
            if err == nil {
                self.backgroundColor = nil  // The icon specifies its own background color.
            }
            completion()
        }
    }
}
