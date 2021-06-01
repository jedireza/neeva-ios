// Copyright © Neeva. All rights reserved.

import SwiftUI

// The `openURL` environment key is not writable, so we need to roll our own.
extension EnvironmentValues {
    private struct OnOpenURLKey: EnvironmentKey {
        static var defaultValue: ((URL) -> ())? = nil
    }

    /// Provide this environment key to open URLs in an app other than Safari.
    public var onOpenURL: (URL) -> () {
        get { self[OnOpenURLKey] ?? { openURL($0) } }
        set { self[OnOpenURLKey] = newValue }
    }
}
