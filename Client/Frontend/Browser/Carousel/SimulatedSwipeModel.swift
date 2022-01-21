// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import UIKit

class SimulatedSwipeModel: ObservableObject {
    @Published var offset: CGFloat = 0
    var tabManager: TabManager
    var chromeModel: TabChromeModel
    var swipeDirection: SwipeDirection
    var forwardUrlMap = [String: [URL]?]()
    var progressModel = CarouselProgressModel(urls: [], index: 0)
    var hidden = true

    func canGoBack() -> Bool {
        return swipeDirection == .back && !hidden
    }

    func canGoForward() -> Bool {
        return swipeDirection == .forward && !hidden
    }

    @discardableResult func goBack() -> Bool {
        guard canGoBack(), swipeDirection == .back, let tab = tabManager.selectedTab else {
            return false
        }

        if let _ = tab.parent {
            tabManager.removeTabAndUpdateSelectedTab(tab)
        } else if let id = tab.parentSpaceID {
            SceneDelegate.getBVC(with: tabManager.scene).browserModel.openSpace(spaceID: id)
        } else {
            return false
        }

        offset = 0

        return true
    }

    @discardableResult func goForward() -> Bool {
        guard canGoForward(), swipeDirection == .forward, let tab = tabManager.selectedTab,
            let urls = forwardUrlMap[tab.tabUUID]!
        else {
            return false
        }

        let index = urls.firstIndex(of: tab.currentURL()!) ?? -1
        // If we are here, we have already fake animated and it is too late
        assert(index < urls.count - 1)
        tab.loadRequest(URLRequest(url: urls[index + 1]))
        return true
    }

    init(tabManager: TabManager, chromeModel: TabChromeModel, swipeDirection: SwipeDirection) {
        self.tabManager = tabManager
        self.chromeModel = chromeModel
        self.swipeDirection = swipeDirection
    }
}
