// Copyright Neeva. All rights reserved.

import Foundation

class TabToolbarModel: ObservableObject {
    @Published var canGoBack: Bool
    @Published var canGoForward: Bool
    @Published var isPage: Bool

    init(canGoBack: Bool = false, canGoForward: Bool = false, isPage: Bool = false) {
        self.canGoBack = canGoBack
        self.canGoForward = canGoForward
        self.isPage = isPage
    }
}
