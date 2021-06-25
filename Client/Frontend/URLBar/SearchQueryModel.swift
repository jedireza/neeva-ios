// Copyright Neeva. All rights reserved.

import Combine

class SearchQueryModel: ObservableObject {
    static let shared = SearchQueryModel()

    private init() {}

    @Published var value: String? = nil

    var isEditing: Bool { value != nil }
    var isEmpty: Bool { value?.isEmpty ?? true }
}
