// Copyright Neeva. All rights reserved.

import Foundation

class URLBarModel: ObservableObject {
    @Published var url: URL?
    @Published var isSecure = false
    @Published var reloadButton = ReloadButtonState.reload
    @Published var readerMode = ReaderModeState.unavailable

    init() {}
    init(url: URL?) {
        self.url = url
    }
    init(url: StringLiteralType) {
        self.url = URL(string: url)
    }
}
