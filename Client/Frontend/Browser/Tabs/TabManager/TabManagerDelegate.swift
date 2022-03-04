// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Storage

protocol TabManagerDelegate: AnyObject {
    func tabManager(
        _ tabManager: TabManager, didSelectedTabChange selected: Tab?, previous: Tab?,
        isRestoring: Bool, updateZeroQuery: Bool)
}

// We can't use a WeakList here because this is a protocol.
class WeakTabManagerDelegate {
    weak var value: TabManagerDelegate?

    init(value: TabManagerDelegate) {
        self.value = value
    }

    func get() -> TabManagerDelegate? {
        return value
    }
}

extension TabManager: TabEventHandler {
    func tab(_ tab: Tab, didLoadFavicon favicon: Favicon?, with: Data?) {
        // Write the tabs out again to make sure we preserve the favicon update.
        store.preserveTabs(tabs, selectedTab: selectedTab, for: scene)
    }

    func tabDidChangeContentBlocking(_ tab: Tab) {
        tab.reload()
    }
}

extension TabManager {
    func addDelegate(_ delegate: TabManagerDelegate) {
        assert(Thread.isMainThread)
        delegates.append(WeakTabManagerDelegate(value: delegate))
    }

    func removeDelegate(_ delegate: TabManagerDelegate) {
        assert(Thread.isMainThread)
        for i in 0..<delegates.count {
            let del = delegates[i]
            if delegate === del.get() || del.get() == nil {
                delegates.remove(at: i)
                return
            }
        }
    }
}
