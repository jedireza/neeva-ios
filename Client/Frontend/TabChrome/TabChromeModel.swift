// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Combine
import Shared
import SwiftUI

enum ToolbarContentView {
    case regularContent
    case recipeContent
}

class TabChromeModel: ObservableObject {
    @Published var canGoBack: Bool

    var canReturnToSuggestions: Bool {
        guard let selectedTab = topBarDelegate?.tabManager.selectedTab,
            let currentItem = selectedTab.webView?.backForwardList.currentItem
        else {
            return false
        }

        return selectedTab.queryForNavigation.findQueryFor(navigation: currentItem) != nil
    }

    @Published var canGoForward: Bool
    @Published var urlInSpace: Bool = false

    /// True when the toolbar is inline with the location view
    /// (when in landscape or on iPad)
    @Published var inlineToolbar: Bool
    @Published var controlOpacity: Double = 1

    @Published var isPage: Bool

    var showTopCardStrip: Bool {
        FeatureFlag[.cardStrip] && FeatureFlag[.topCardStrip] && inlineToolbar
            && !isEditingLocation
    }

    var appActiveRefreshSubscription: AnyCancellable? = nil
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
                            delegate.tabContainerModel.updateContent(.hideSuggestions)
                        } else {
                            delegate.tabContainerModel.updateContent(.showSuggestions)
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

    @Published var toolBarContentView: ToolbarContentView = .regularContent

    @Published var currentCheatsheetURL: URL? = nil

    @Published var currentCheatsheetFaviconURL: URL? = nil

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
        if value {
            toolBarContentView = .regularContent
        }

        withAnimation(TabLocationViewUX.animation) {
            isEditingLocation = value
        }
    }

    func hideZeroQuery() {
        SceneDelegate.getBVC(with: topBarDelegate?.tabManager.scene).hideZeroQuery()
    }
}
