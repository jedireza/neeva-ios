/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import Foundation

extension Collection {
    /// Returns the element at the specified index iff it is within bounds, otherwise nil.
    public subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

extension Array where Element: Equatable {
    /// Returns this array, with all duplicate elements removed
    public func removeDuplicates() -> [Element] {
        var result = [Element]()
        for value in self {
            if !result.contains(value) {
                result.append(value)
            }
        }
        return result
    }
}

extension ArraySlice {
    /// Convert an `ArraySlice` to an `Array`.
    /// Useful in a chaining context.
    public func toArray() -> [Element] {
        Array(self)
    }
}
