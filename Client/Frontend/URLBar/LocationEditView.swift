// Copyright Neeva. All rights reserved.

import SwiftUI
import Shared

struct LocationEditView: View {
    @Binding var isEditing: Bool
    let onSubmit: (String) -> ()

    @EnvironmentObject private var searchQuery: SearchQueryModel
    @EnvironmentObject private var historyModel: HistorySuggestionModel

    var body: some View {
        ZStack(alignment: .leading) {
            if let query = searchQuery.value,
               let completion = historyModel.completion {
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
    struct Preview: View {
        @State var text: String?
        let activeLensBang: ActiveLensBangInfo?

        var body: some View {
            LocationEditView(isEditing: .constant(true), onSubmit: { _ in })
                .environmentObject(HistorySuggestionModel(previewSites: []))
        }
    }
    static var previews: some View {
        Group {
            LocationEditView(isEditing: .constant(true), onSubmit: { _ in })
                .environmentObject(SearchQueryModel(previewValue: ""))
            LocationEditView(isEditing: .constant(true), onSubmit: { _ in })
                .environmentObject(SearchQueryModel(previewValue: "hello, world"))
            LocationEditView(isEditing: .constant(true), onSubmit: { _ in })
                .environmentObject(SearchQueryModel(previewValue: "https://apple.com"))
        }
        .environmentObject(HistorySuggestionModel(previewSites: []))
        .frame(height: TabLocationViewUX.height)
        .background(Capsule().fill(Color.systemFill))
        .padding()
        .previewLayout(.sizeThatFits)
    }
}
