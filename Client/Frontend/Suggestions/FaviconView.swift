// Copyright Neeva. All rights reserved.

import Storage
import SwiftUI

private enum FaviconViewUX {
    static let IconBorderColor = UIColor(white: 0, alpha: 0.1)
    static let IconBorderWidth: CGFloat = 0.5
}

struct FaviconView: UIViewRepresentable {
    init(
        url: URL, icon: Favicon? = nil, size: CGFloat, bordered: Bool,
        defaultBackground: UIColor = .systemBackground
    ) {
        self.url = url
        self.icon = icon
        self.size = size
        self.bordered = bordered
        self.defaultBackground = defaultBackground
    }

    let url: URL
    let icon: Favicon?
    let size: CGFloat
    let bordered: Bool
    let defaultBackground: UIColor

    func makeUIView(context: Context) -> UIImageView {
        let imageView = UIImageView()
        if bordered {
            imageView.layer.borderColor = FaviconViewUX.IconBorderColor.cgColor
            imageView.layer.borderWidth = FaviconViewUX.IconBorderWidth
        }
        imageView.contentMode = .center
        return imageView
    }

    func updateUIView(_ imageView: UIImageView, context: Context) {
        imageView.setImageAndBackground(
            forIcon: icon, website: url, defaultBackground: defaultBackground
        ) { [weak imageView] in
            imageView?.image = imageView?.image?.createScaled(.init(width: size, height: size))
        }
    }
}
