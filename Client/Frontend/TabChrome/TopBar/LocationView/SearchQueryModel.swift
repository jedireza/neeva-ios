// Copyright Neeva. All rights reserved.

import Combine

/// One per window scene. Contains the text of the location view. When `TabChromeModel/isEditingLocation`
/// is false, `SearchQueryModel/value` is not used by anything.
class SearchQueryModel: ObservableObject {
    @Published var value: String = ""

    init() {}
    init(previewValue: String) {
        self.value = previewValue
    }
}
