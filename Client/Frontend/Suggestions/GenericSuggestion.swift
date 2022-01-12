// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

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
