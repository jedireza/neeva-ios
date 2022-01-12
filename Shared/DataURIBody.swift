// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Foundation

extension String {
    /// If this string represents a `data:` URL containing base64-encoded data, this returns the decoded data.
    public var dataURIBody: Data? {
        guard starts(with: "data:") else { return nil }
        guard let payloadStart = range(of: ",")?.upperBound else { return nil }
        let payload = String(self[payloadStart..<self.endIndex])
        if range(of: "base64,")?.upperBound == payloadStart {
            return Data(base64Encoded: payload)
        } else {
            // TODO: implement support for non-base64 data URIs if needed
            return nil
        }
    }
}
