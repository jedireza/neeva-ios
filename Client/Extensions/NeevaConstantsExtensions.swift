// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Foundation
import Shared

public enum Target {
    case client
    case xyz
}

extension NeevaConstants {
    public static var appHomeURL: URL { NeevaConstants.currentTarget == .xyz ? xyzURL : appURL }

    public static var currentTarget: Target {
        #if XYZ
            return .xyz
        #else
            return .client
        #endif
    }

    public static func isNeevaHome(url: URL?) -> Bool {
        return url?.scheme == NeevaConstants.appHomeURL.scheme
            && url?.host == NeevaConstants.appHomeURL.host
            && url?.path == NeevaConstants.appHomeURL.path
    }
}
