// Copyright Neeva. All rights reserved.

import Foundation

extension NSItemProvider {
    convenience init(url: URL) {
        self.init(object: url as NSURL)
    }
}
