// Copyright Neeva. All rights reserved.

import Combine

extension Publisher {
    /// Creates a publisher that delivers a tuple `(previousValue, currentValue)` with each change of the upstream publisher.
    ///
    /// This publisher will only publish starting with the second value of the upstream publisher.
    ///
    /// If you want to receive something for the first publish from the upstream publisher, `prepend()`
    /// the value you want to receive as the first `previousValue` before calling `withPrevious()`.
    ///
    /// If you only want to receive an update when the value actually changes, use `removeDuplicates()`
    /// before calling `withPrevious()`.
    func withPrevious() -> Publishers.Zip<Self, Publishers.Drop<Self>> {
        zip(self.dropFirst())
    }

    /// Runs the provided listener each time this publisher publishes.
    func forEach(_ listener: @escaping () -> Void) -> Publishers.Filter<Self> {
        filter { _ in
            listener()
            return true
        }
    }

    /// Converts the publisher’s result to an optional value, with errors being represented as `nil`.
    /// Similar to Swift’s `try?` syntax.
    func failureToNil() -> Publishers.ReplaceError<Publishers.Map<Self, Self.Output?>> {
        self.map(Optional.init)
            .replaceError(with: nil)
    }
}
