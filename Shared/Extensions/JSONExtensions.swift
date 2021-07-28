/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import Foundation
import SwiftyJSON

extension JSON {
    public func isStringOrNull() -> Bool {
        return self.isString() || self.isNull()
    }

    public func isError() -> Bool {
        return self.error != nil
    }

    public func isString() -> Bool {
        // SwiftyJSON doesn't link values to types; it's possible for `self.type == .string` but
        // `self.string` to return `nil`. Validate both.
        return self.type == .string && self.string != nil
    }

    public func isBool() -> Bool {
        return self.type == .bool
    }

    public func isArray() -> Bool {
        return self.type == .array
    }

    public func isDictionary() -> Bool {
        return self.type == .dictionary
    }

    // Bear in mind that for this function to work you need to set the value to NSNull:
    // ```
    // var myObj = JSON(…)
    // myObj["foo"] = someOptional ?? NSNull()
    // ```
    // This is… easy to get wrong.
    public func isNull() -> Bool {
        return self.type == .null
    }

    public func isInt() -> Bool {
        return self.type == .number && self.int != nil
    }

    public func isNumber() -> Bool {
        return self.type == .number && self.number != nil
    }

    public func isDouble() -> Bool {
        return self.type == .number && self.double != nil
    }

    // SwiftyJSON pretty prints the string value by default. Since all of our
    // existing code required the string to not be pretty printed, this helper
    // can be used as a shorthand for non-pretty printed strings.
    public func stringify() -> String? {
        return self.rawString(.utf8, options: [])
    }
}
