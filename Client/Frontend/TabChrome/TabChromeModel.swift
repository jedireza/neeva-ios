// Copyright Neeva. All rights reserved.

import Combine
import SwiftUI

class TabChromeModel: ObservableObject {
    @Published var canGoBack: Bool
    @Published var canGoForward: Bool

    /// True when the toolbar is inline with the location view
    /// (when in landscape or on iPad)
    @Published var inlineToolbar: Bool
    @Published var controlOpacity: Double = 1

    @Published var isPage: Bool

    private var subscriptions: Set<AnyCancellable> = []
    weak var topBarDelegate: TopBarDelegate? {
        didSet {
            $isEditingLocation
                .withPrevious()
                .sink { [weak topBarDelegate] change in
                    switch change {
                    case (false, true):
                        topBarDelegate?.urlBarDidEnterOverlayMode()
                    case (true, false):
                        topBarDelegate?.urlBarDidLeaveOverlayMode()
                    default: break
                    }
                }
                .store(in: &subscriptions)
            $isEditingLocation
                .combineLatest(topBarDelegate!.searchQueryModel.$value)
                .withPrevious()
                .sink { [weak topBarDelegate] (prev, current) in
                    let (prevEditing, _) = prev
                    let (isEditing, query) = current
                    if let delegate = topBarDelegate, (prevEditing, isEditing) == (true, true) {
                        if query.isEmpty {
                            delegate.tabContentHost.updateContent(.hideSuggestions)
                        } else {
                            delegate.tabContentHost.updateContent(.showSuggestions)
                        }
                    }
                }
                .store(in: &subscriptions)
        }
    }
    weak var toolbarDelegate: ToolbarDelegate?

    enum ReloadButtonState: String {
        case reload = "Reload"
        case stop = "Stop"
    }
    var reloadButton: ReloadButtonState {
        estimatedProgress == 1 || estimatedProgress == nil ? .reload : .stop
    }
    @Published var estimatedProgress: Double?

    @Published private(set) var isEditingLocation = false

    @Published var showNeevaMenuTourPrompt = false

    init(
        canGoBack: Bool = false, canGoForward: Bool = false, isPage: Bool = false,
        inlineToolbar: Bool = false, estimatedProgress: Double? = nil
    ) {
        self.canGoBack = canGoBack
        self.canGoForward = canGoForward
        self.isPage = isPage
        self.inlineToolbar = inlineToolbar
        self.estimatedProgress = estimatedProgress
    }

    /// Calls the address bar to be selected and enter editing mode
    func triggerOverlay() {
        isEditingLocation = true
    }

    func setEditingLocation(to value: Bool) {
        withAnimation(TabLocationViewUX.animation.delay(0.08)) {
            isEditingLocation = value
        }
    }
}
