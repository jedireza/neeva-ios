// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Foundation

extension NSItemProvider {
    convenience init(url: URL) {
        self.init(object: url as NSURL)
    }

    convenience init(id: String) {
        self.init(object: id as NSString)
    }
}
