// Copyright Neeva. All rights reserved.

import Foundation
import Combine

class URLBarModel: ObservableObject {
    @Published var url: URL?
    /// `true` iff all assets on the page are secure (i.e. there is no mixed content)
    @Published var isSecure = false

    @Published var reloadButton = ReloadButtonState.reload
    @Published var readerMode = ReaderModeState.unavailable
    @Published var canShare = false

    init() {}
    init(url: URL?) {
        self.url = url
    }
}
