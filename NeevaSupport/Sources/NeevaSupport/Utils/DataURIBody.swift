//
//  DataURIBody.swift
//  
//
//  Created by Jed Fox on 1/18/21.
//

import Foundation

extension String {
    /// If this string represents a `data:` URL containing base64-encoded data, this returns the decoded data.
    var dataURIBody: Data? {
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
