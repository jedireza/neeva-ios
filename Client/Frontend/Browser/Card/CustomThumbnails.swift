// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import SDWebImageSwiftUI
import SwiftUI

class CustomThumbnailModel: ObservableObject {
    @Published var selectedThumbnail = URL.aboutBlank {
        didSet {
            guard let dataString = thumbnailData[selectedThumbnail] else {
                return
            }
            selectedData = "data:image/jpeg;base64," + dataString
        }
    }
    @Published var selectedData: String? = nil
    @Published var selectedSpaceThumbnailEntityID: String? = nil
    @Published var thumbnailData = [URL: String]()
    @Published var showing = true
}

enum ThumbnailPickerUX {
    static let ThumbnailSize: CGFloat = 64
    static let ThumbnailRadius: CGFloat = 6
}

struct CustomThumbnailPicker: View {
    let thumbnails: [URL]
    @ObservedObject var model: CustomThumbnailModel

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Thumbnails")
                .withFont(.headingSmall)
                .foregroundColor(.label)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(thumbnails, id: \.absoluteString) { thumbnail in
                        URLBasedThumbnailView(model: model, thumbnail: thumbnail)
                    }
                }
            }
        }
    }
}

struct SpaceThumbnailPicker: View {
    let spaceDetails: SpaceCardDetails
    @ObservedObject var model: CustomThumbnailModel

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Thumbnails")
                .withFont(.headingSmall)
                .foregroundColor(.label)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(alignment: .center) {
                    ForEach(spaceDetails.allDetails, id: \.id) { entity in
                        if let thumbnail = entity.data.thumbnail, !thumbnail.isEmpty {
                            Button(
                                action: { model.selectedSpaceThumbnailEntityID = entity.id },
                                label: {
                                    entity.thumbnail.frame(
                                        width: ThumbnailPickerUX.ThumbnailSize,
                                        height: ThumbnailPickerUX.ThumbnailSize
                                    ).cornerRadius(ThumbnailPickerUX.ThumbnailRadius)
                                }
                            )
                            .roundedOuterBorder(
                                cornerRadius: ThumbnailPickerUX.ThumbnailRadius,
                                color: model.selectedSpaceThumbnailEntityID == entity.id
                                    ? Color.ui.adaptive.blue : Color.clear, lineWidth: 2)
                        } else if entity.isImage, let thumbnail = entity.data.url {
                            URLBasedThumbnailView(model: model, thumbnail: thumbnail)
                        }
                    }
                }
            }
        }
    }
}

struct URLBasedThumbnailView: View {
    @ObservedObject var model: CustomThumbnailModel
    let thumbnail: URL

    var body: some View {
        Button(
            action: { model.selectedThumbnail = thumbnail },
            label: {
                WebImage(url: thumbnail)
                    .onSuccess { image, data, cacheType in
                        guard model.showing,
                            model.thumbnailData.index(forKey: thumbnail) == nil
                        else {
                            return
                        }

                        DispatchQueue.global(qos: .userInitiated).async {
                            // compress and encode on a background thread with
                            // user initiated priority.
                            guard
                                let data = image.jpegData(
                                    compressionQuality: 0.7
                                        - min(
                                            0.4,
                                            0.2 * floor(image.size.width / 1000)))
                            else {
                                return
                            }

                            let string = data.base64EncodedString()

                            DispatchQueue.main.async {
                                model.thumbnailData[thumbnail] = string
                            }
                        }
                    }
                    .resizable()
                    .placeholder { Color.DefaultBackground }
                    .scaledToFill()
                    .frame(
                        width: ThumbnailPickerUX.ThumbnailSize,
                        height: ThumbnailPickerUX.ThumbnailSize
                    )
                    .cornerRadius(ThumbnailPickerUX.ThumbnailRadius)
            }
        )
        .roundedOuterBorder(
            cornerRadius: ThumbnailPickerUX.ThumbnailRadius,
            color: model.selectedThumbnail == thumbnail
                ? Color.ui.adaptive.blue : Color.clear, lineWidth: 2)
    }
}
