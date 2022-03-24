// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Defaults
import SDWebImageSwiftUI
import SFSafeSymbols
import Shared
import SwiftUI
import UIKit

public enum Web3Theme: String {

    public init(with slug: String?) {
        guard let slug = slug else {
            self = .default
            return
        }
        self = Web3Theme(rawValue: slug) ?? .default
    }

    public static var allCases: [Web3Theme] {
        return [
            .azuki,
            .coolCats,
            .cryptoCoven,
        ]
    }

    case azuki = "azuki"
    case coolCats = "cool-cats-nft"
    case cryptoCoven = "cryptocoven"
    case `default` = ""
}

extension Web3Theme {

    @ViewBuilder
    public var backButton: some View {
        switch self {
        case .default:
            Symbol(
                .arrowBackward,
                size: 20,
                weight: .medium,
                label: .TabToolbarBackAccessibilityLabel
            )
        case .azuki:
            Image("azuki_back")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 24)
        case .cryptoCoven:
            Image(
                uiImage: UIImage(named: "cryptocoven_back")!
                    .withRenderingMode(.alwaysTemplate)
            )
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 22)
            .foregroundColor(.label)
        case .coolCats:
            Image("coolcats_back")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 36)
        }
    }

    @ViewBuilder
    public var overflowButton: some View {
        switch self {
        case .default:
            Symbol(
                .ellipsisCircle,
                size: 20, weight: .medium,
                label: .TabToolbarMoreAccessibilityLabel)
        case .azuki:
            Image("azuki_overflow")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 24)
        case .cryptoCoven:
            Image(
                uiImage:
                    UIImage(named: "cryptocoven_overflow")!
                    .withRenderingMode(.alwaysTemplate)
            )
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 22)
            .foregroundColor(.label)
        case .coolCats:
            Image("coolcats_overflow")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 36)
        }
    }

    @ViewBuilder
    public var walletButton: some View {
        switch self {
        case .default:
            Image("wallet-illustration")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 32)
                .accessibilityLabel("Neeva Wallet")
        case .azuki, .cryptoCoven, .coolCats:
            WebImage(url: asset?.imageURL)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 32)
                .cornerRadius(16)
                .accessibilityLabel("Neeva Wallet")
        }
    }

    @ViewBuilder
    public var lazyTabButton: some View {
        switch self {
        case .default:
            Symbol(
                .plus,
                size: 20,
                weight: .medium,
                label: .TabToolbarBackAccessibilityLabel
            )
        case .azuki:
            Image("azuki_magnifier")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 24)
        case .cryptoCoven:
            Image(
                uiImage: UIImage(named: "cryptocoven_magnifier")!
                    .withRenderingMode(.alwaysTemplate)
            )
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 22)
            .foregroundColor(.label)
        case .coolCats:
            Image("coolcats_magnifier")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 24)
        }
    }

    public var tabsImage: UIImage? {
        switch self {
        case .default:
            return Symbol.uiImage(
                .squareOnSquare,
                size: 20,
                weight: .medium
            )
        case .azuki:
            return UIImage(named: "azuki_tabs")?
                .scalePreservingAspectRatio(
                    targetSize: CGSize(width: 24, height: 24)
                )
                .withRenderingMode(.alwaysOriginal)
        case .cryptoCoven:
            return UIImage(named: "cryptocoven_tabs")?
                .scalePreservingAspectRatio(
                    targetSize: CGSize(width: 36, height: 36)
                )
                .withRenderingMode(.alwaysTemplate)
        case .coolCats:
            return UIImage(named: "coolcats_tabs")?
                .scalePreservingAspectRatio(
                    targetSize: CGSize(width: 36, height: 36)
                )
                .withRenderingMode(.alwaysOriginal)
        }
    }

    public var backgroundColor: Color {
        switch self {
        case .default:
            return Color.DefaultBackground
        case .azuki:
            return Color(UIColor(named: "azuki_background")!)
        case .cryptoCoven:
            return Color(UIColor(named: "cryptocoven_background")!)
        case .coolCats:
            return Color(UIColor(named: "coolcats_background")!)
        }
    }

    public var asset: Asset? {
        guard
            let asset = AssetStore.shared.assets.first(where: {
                $0.collection?.openSeaSlug == rawValue
            })
        else {
            return nil
        }
        return asset
    }
}

extension UIImage {
    fileprivate func scalePreservingAspectRatio(targetSize: CGSize) -> UIImage {
        let widthRatio = targetSize.width / size.width
        let heightRatio = targetSize.height / size.height

        let scaleFactor = min(widthRatio, heightRatio)

        let scaledImageSize = CGSize(
            width: size.width * scaleFactor,
            height: size.height * scaleFactor
        )

        let renderer = UIGraphicsImageRenderer(
            size: scaledImageSize
        )

        let scaledImage = renderer.image { _ in
            self.draw(
                in: CGRect(
                    origin: .zero,
                    size: scaledImageSize
                ))
        }

        return scaledImage
    }
}
