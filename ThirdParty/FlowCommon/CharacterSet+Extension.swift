// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Foundation

extension CharacterSet {
    public func isMember(_ c: UnicodeScalar) -> Bool {
        return contains(UnicodeScalar(c.value)!)
    }
}
