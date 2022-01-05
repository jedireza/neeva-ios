// Copyright Neeva. All rights reserved.

import SwiftUI

extension Mirror {
    subscript(key: String?) -> Any? {
        children.first { $0.label == key }?.value
    }
}

extension LocalizedStringKey {
    // Adapted & extended from https://stackoverflow.com/a/64429555/5244995
    public var stringValue: String? {
        let mirror = Mirror(reflecting: self)

        guard
            let key = mirror["key"] as? String,
            let hasFormatting = mirror["hasFormatting"] as? Bool
        else { return nil }

        if hasFormatting {
            return nil
        } else {
            return NSLocalizedString(key, comment: "")
        }
    }
}
