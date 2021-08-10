// Copyright Neeva. All rights reserved.

import Combine
import Foundation
import SwiftUI

class LocationViewModel: ObservableObject {
    @Published var url: URL?
    /// `true` iff all assets on the page are secure (i.e. there is no mixed content)
    @Published var isSecure = false

    @Published var readerMode = ReaderModeState.unavailable

    init() {}
    init(previewURL: URL?, isSecure: Bool) {
        self.url = previewURL
        self.isSecure = isSecure
    }
}
