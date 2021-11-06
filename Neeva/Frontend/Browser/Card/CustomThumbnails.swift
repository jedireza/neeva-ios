// Copyright Neeva. All rights reserved.

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
    @Published var thumbnailData = [URL: String]()
    @Published var showing = true
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
                        Button(
                            action: {
                                model.selectedThumbnail = thumbnail
                            },
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
                                    .frame(width: 64, height: 64)
                                    .cornerRadius(6)
                            }
                        ).roundedOuterBorder(
                            cornerRadius: 6,
                            color: model.selectedThumbnail == thumbnail
                                ? Color.ui.adaptive.blue : Color.clear, lineWidth: 2)
                    }
                }
            }
        }
    }
}
