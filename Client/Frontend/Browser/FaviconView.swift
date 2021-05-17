//
//  FaviconView.swift
//  Client
//
//  Created by Yusuf Ozuysal on 5/16/21.
//  Copyright © 2021 Neeva. All rights reserved.
//

import SwiftUI
import Storage

private struct FaviconViewUX {
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
        imageView.layer.cornerRadius = 6 //hmm // this comment was brought over from the original code in TwoLineCell
        imageView.layer.masksToBounds = true
        return imageView
    }

    func updateUIView(_ imageView: UIImageView, context: Context) {
        imageView.setImageAndBackground(forIcon: site.icon, website: site.tileURL) { [weak imageView] in
            imageView?.image = imageView?.image?.createScaled(.init(width: size, height: size))
        }
    }
}
