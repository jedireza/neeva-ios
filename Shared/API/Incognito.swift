// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Foundation

extension StartIncognitoMutation {
    public convenience init(url: URL) {
        var redirect = url.path
        if let query = url.query {
            redirect += "?" + query
        }
        if let fragment = url.fragment {
            redirect += "#" + fragment
        }
        self.init(redirect: redirect)
    }
}
