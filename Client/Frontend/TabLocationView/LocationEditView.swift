// Copyright Neeva. All rights reserved.

import Shared
import SwiftUI

struct LocationEditView: View {
    @Binding var isEditing: Bool
    let onSubmit: (String) -> Void

    @EnvironmentObject private var searchQuery: SearchQueryModel
    @EnvironmentObject private var suggestionModel: SuggestionModel

    var body: some View {
        ZStack(alignment: .leading) {
            if let query = suggestionModel.queryModel.value,
                let completion = suggestionModel.completion
            {
                HStack(spacing: 0) {
                    Text(query)
                        .foregroundColor(.clear)
                    Text(completion)
                        .padding(.vertical, 1)
                        .padding(.trailing, 3)
                        .background(Color.textSelectionHighlight.cornerRadius(2))
                        .padding(.vertical, -1)
                }
                .accessibilityHidden(true)
                .font(.system(size: 16))
            }

            LocationTextField(text: $searchQuery.value, editing: $isEditing, onSubmit: onSubmit)
        }
        .padding(.trailing, 6)
    }
}

struct LocationTextField_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            LocationEditView(isEditing: .constant(true), onSubmit: { _ in })
                .environmentObject(SearchQueryModel(previewValue: ""))
            LocationEditView(isEditing: .constant(true), onSubmit: { _ in })
                .environmentObject(SearchQueryModel(previewValue: "hello, world"))
            LocationEditView(isEditing: .constant(true), onSubmit: { _ in })
                .environmentObject(SearchQueryModel(previewValue: "https://apple.com"))
        }
        .environmentObject(SuggestionModel(previewSites: []))
        .frame(height: TabLocationViewUX.height)
        .background(Capsule().fill(Color.systemFill))
        .padding()
        .previewLayout(.sizeThatFits)
    }
}
