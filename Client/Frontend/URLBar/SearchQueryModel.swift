// Copyright Neeva. All rights reserved.

import Combine

class SearchQueryModel: ObservableObject {
    static let shared = SearchQueryModel()

    private init() {}

    init(previewValue: String) {
        self.value = previewValue
    }

    @Published var value: String = ""
}
