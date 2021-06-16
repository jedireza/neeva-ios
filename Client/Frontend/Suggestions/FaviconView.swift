// Copyright Neeva. All rights reserved.

import SwiftUI
import Storage

private enum FaviconViewUX {
    static let IconBorderColor = UIColor(white: 0, alpha: 0.1)
    static let IconBorderWidth: CGFloat = 0.5
}

struct FaviconView: UIViewRepresentable {
    let site: Site
    let size: CGFloat
    let bordered: Bool

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
        imageView.setImageAndBackground(forIcon: site.icon, website: site.tileURL) { [weak imageView] in
            imageView?.image = imageView?.image?.createScaled(.init(width: size, height: size))
        }
    }
}
