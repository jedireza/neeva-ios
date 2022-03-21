// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Foundation

public enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
}

public typealias Parameters = [String: Any]
public typealias HTTPHeaders = [String: String]

public protocol URLRequestBuilder {
    var baseURL: URL { get }
    var requestURL: URL { get }
    var path: String { get }
    var headers: HTTPHeaders { get }
    var parameters: Parameters? { get }
    var method: HTTPMethod { get }
    var urlRequest: URLRequest { get }
}

extension URLRequestBuilder {
    
    public var requestURL: URL {
        return baseURL.appendingPathComponent(path, isDirectory: false)
    }
    
    public var urlRequest: URLRequest {
        var request = URLRequest(url: requestURL)
        request.httpMethod = method.rawValue
        headers.forEach {
            request.addValue($0.value, forHTTPHeaderField: $0.key)
        }
        return request
    }
    
}
