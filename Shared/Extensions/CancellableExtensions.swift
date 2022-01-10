// Copyright Neeva. All rights reserved.

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
