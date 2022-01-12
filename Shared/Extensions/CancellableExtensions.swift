// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Apollo
import Combine

private struct ApolloCancellableWrapper: Combine.Cancellable {
    let apollo: Apollo.Cancellable

    func cancel() { apollo.cancel() }
}

extension Apollo.Cancellable {
    public var combine: Combine.Cancellable {
        ApolloCancellableWrapper(apollo: self)
    }
}
