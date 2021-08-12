// Copyright Neeva. All rights reserved.

import SwiftUI

class TabChromeModel: ObservableObject {
    @Published var canGoBack: Bool
    @Published var canGoForward: Bool

    @Published var inlineToolbar: Bool
    @Published var controlOpacity: Double = 1

    @Published var isPage: Bool

    enum ReloadButtonState: String {
        case reload = "Reload"
        case stop = "Stop"
    }
    @Published var reloadButton = ReloadButtonState.reload
    @Published var estimatedProgress: Double?

    @Published private(set) var isEditingLocation = false

    init(
        canGoBack: Bool = false, canGoForward: Bool = false, isPage: Bool = false,
        inlineToolbar: Bool = false
    ) {
        self.canGoBack = canGoBack
        self.canGoForward = canGoForward
        self.isPage = isPage
        self.inlineToolbar = inlineToolbar
    }

    func setEditingLocation(to value: Bool) {
        withAnimation(TabLocationViewUX.animation.delay(0.08)) {
            isEditingLocation = value
        }
    }
}
