// Copyright Neeva. All rights reserved.

import Foundation

struct GenericSuggestionResult: Decodable {
    let query: String
    let suggestions: [String]

    init(from decoder: Decoder) throws {
        var array = try decoder.unkeyedContainer()
        query = try array.decode(String.self)
        suggestions = try array.decode([String].self)
    }
}
