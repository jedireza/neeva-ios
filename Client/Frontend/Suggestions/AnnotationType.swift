// Copyright Neeva. All rights reserved.

import Apollo
import Foundation
import Shared

enum AnnotationType: String {
    case unknown = ""
    case calculator = "Calculator"
    case wikipedia = "Wikipedia"

}

extension AnnotationType {
    init?(annotation: Shared.SuggestionsQuery.Data.Suggest.QuerySuggestion.Annotation?) {
        if let annotation = annotation,
            let annotationType = annotation.annotationType
        {
            self.init(rawValue: annotationType)
        } else {
            return nil
        }
    }
}
