// Copyright Neeva. All rights reserved.

import UIKit

extension UIDevice {
    public var useTabletInterface: Bool {
        return userInterfaceIdiom == .pad || userInterfaceIdiom == .mac
    }
}
