// Copyright Neeva. All rights reserved.

import Combine
import Foundation
import SwiftUI

class LocationViewModel: ObservableObject {
    @Published var url: URL?
    @Published var readerMode = ReaderModeState.unavailable

    @Published private var hasOnlySecureContentListener: AnyCancellable?
    /// `true` iff all assets on the page are secure (i.e. there is no mixed content)
    @Published private var hasOnlySecureContent = false
    var isSecure: Bool? { hasOnlySecureContentListener == nil ? nil : hasOnlySecureContent }

    public func updateSecureListener(with webView: WKWebView) {
        hasOnlySecureContentListener = webView.publisher(for: \.hasOnlySecureContent, options: [.initial, .new]).assign(to: \.hasOnlySecureContent, on: self)
    }

    public func resetSecureListener() {
        hasOnlySecureContentListener = nil
    }

    init() {}
    init(previewURL: URL?, hasOnlySecureContent: Bool?) {
        self.url = previewURL

        if let isSecure = isSecure {
            self.hasOnlySecureContent = isSecure
            self.hasOnlySecureContentListener = AnyCancellable({})
        } else {
            self.hasOnlySecureContentListener = nil
        }
    }
}
