// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Foundation

class ContentVisibilityModel: ObservableObject {
    /// True when the WebView should be shown.
    @Published private(set) var showContent: Bool = true

    func update(showContent: Bool) {
        // Avoid spurious events.
        if self.showContent != showContent {
            self.showContent = showContent
        }
    }
}
