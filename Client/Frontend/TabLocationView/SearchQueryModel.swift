// Copyright Neeva. All rights reserved.

import Combine

class SearchQueryModel: ObservableObject {
    @Published var value: String = ""

    init() {}

    init(previewValue: String) {
        self.value = previewValue
    }
}
