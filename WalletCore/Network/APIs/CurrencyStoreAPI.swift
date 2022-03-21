// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

public enum CurrencyStoreAPI: URLRequestBuilder {
    case currencies
}

extension CurrencyStoreAPI {
    public var baseURL: URL {
        return URL(string: "https://api.coingecko.com/api/v3//")!
    }
    
    public var path: String {
        switch self {
        case .currencies:
            return "simple/price?ids=ethereum%2Cmatic-network%2Cusd-coin%2Ctether%2Cshiba-inu&vs_currencies=usd&include_24hr_change=true&include_last_updated_at=true"
        }
    }
    
    public var headers: HTTPHeaders {
        switch self {
        case .currencies:
            return ["Accept": "application/json"]
        }
    }
    
    public var parameters: Parameters? {
        return nil
    }
    
    public var method: HTTPMethod {
        return .get
    }
}
