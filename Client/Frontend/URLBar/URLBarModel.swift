// Copyright Neeva. All rights reserved.

import Foundation
import Combine

class URLBarModel: ObservableObject {
    @Published var url: URL?
    /// `true` iff all assets on the page are secure (i.e. there is no mixed content)
    @Published var isSecure = false

    @Published var isEditing = false

    @Published var reloadButton = ReloadButtonState.reload
    @Published var readerMode = ReaderModeState.unavailable
    @Published var canShare = false
    @Published var includeShareButtonInLocationView = true

    init() {}
    init(previewURL: URL?, isSecure: Bool) {
        self.url = previewURL
        self.isSecure = isSecure
    }
}
