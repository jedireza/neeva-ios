// Copyright Neeva. All rights reserved.

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
