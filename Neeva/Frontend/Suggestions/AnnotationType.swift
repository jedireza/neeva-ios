// Copyright Neeva. All rights reserved.

import Apollo
import Foundation
import Shared

// ****** IMPORTANT *****
// Please KEEP IN SYNC with "suggest/schema.go"'s
// annotationType in the main repo.
// ***********************
enum AnnotationType: String {
    /// Default annotation type
    case unknown = ""
    /// `AnnotationTypeCalculator` indicates the type is a calculator result
    case calculator = "Calculator"
    /// `AnnotationTypeWikipedia` indicates the type is a wikipedia annotation
    case wikipedia = "Wikipedia"
    /// `AnnotationTypeStock` indicated the type is a stock annotation
    case stock = "Stock"
    /// `AnnotationTypeContact` indicated the type is a contact annotation
    case contact = "Contact"
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

extension SuggestionsQuery.Data.Suggest.QuerySuggestion {
    func hasSupportedAnnotationType() -> Bool {
        return AnnotationType(annotation: annotation) == .calculator
            || AnnotationType(annotation: annotation) == .stock
            || AnnotationType(annotation: annotation) == .wikipedia
    }
}
