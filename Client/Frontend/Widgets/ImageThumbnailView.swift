// Copyright Neeva. All rights reserved.

import Foundation
import SwiftUI

class ImageThumbnailModel: ObservableObject {
    private let imageData: Data
    @Published var cachedImage: UIImage?

    init(imageData: Data) {
        self.imageData = imageData
    }

    func getImage() -> UIImage? {
        if let image = cachedImage {
            return image
        }
        DispatchQueue.global().async {
            let image = UIImage.imageFromDataThreadSafe(self.imageData)
            DispatchQueue.main.async {
                self.cachedImage = image
            }
        }
        return nil
    }
}

struct ImageThumbnailView: View {
    @ObservedObject var model: ImageThumbnailModel

    var body: some View {
        if let image = model.getImage() {
            Image(uiImage: image)
                .resizable()
                .aspectRatio(contentMode: .fill)
        } else {
            Color.tertiarySystemFill
        }
    }
}
