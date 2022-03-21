// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Foundation

public enum OpenSeaAPI: URLRequestBuilder {
    case collection(slug: String)
    case assets(owner: String)
}

extension OpenSeaAPI {
    public var baseURL: URL {
        return URL(string: "https://api.opensea.io/api/v1/")!
    }
    
    public var path: String {
        switch self {
        case .collection(slug: let slug):
            return "collection/" + slug
        case .assets(owner: let owner):
            return "assets?order_direction=desc&offset=0&owner=" + owner
        }
    }
    
    public var headers: HTTPHeaders {
        switch self {
        case .assets:
            if let apiKey = Bundle.main.object(forInfoDictionaryKey: "OPENSEA_API_KEY") as? String {
                return [
                    "Accept": "application/json",
                 "X-API-KEY": apiKey,
                ]
            }
            return ["Accept": "application/json"]
        case .collection:
            return [:]
        }
    }
    
    public var parameters: Parameters? {
        return nil
    }
    
    public var method: HTTPMethod {
        return .get
    }
}
