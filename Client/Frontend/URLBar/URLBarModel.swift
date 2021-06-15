// Copyright Neeva. All rights reserved.

import Foundation

class URLBarModel: ObservableObject {
    /// `nil` when the location view is not editing, otherwise contains the currently displayed editable text.
    @Published var text: String?
    @Published var url: URL?
    /// `true` iff all assets on the page are secure (i.e. there is no mixed content)
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
