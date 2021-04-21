// Copyright Neeva. All rights reserved.

import SwiftUI
struct SpacesSearchHeaderView: View {
    @State private var isEditing = false
    @State private var searchText = ""

    let filterAction: (String) -> ()
    let createAction: () -> ()

    public init(filterAction: @escaping (String) -> (), createAction: @escaping () -> ()) {
        self.filterAction = filterAction
        self.createAction = createAction
    }

    var body: some View {
        HStack {
            HStack {
                Image(systemName: "magnifyingglass")
                    .imageScale(.medium)
                    .foregroundColor(.secondary)
                    .font(.system(size: 16))
                TextField("Search Spaces", text: $searchText)
                    .onChange(of: searchText) {
                        self.filterAction($0)
                    }
                if (self.isEditing && !self.searchText.isEmpty) {
                    Image(systemName: "xmark.circle.fill")
                        .imageScale(.medium)
                        .foregroundColor(.secondary)
                        .padding([.leading, .trailing], 2)
                        .onTapGesture {
                            withAnimation {
                                self.searchText = ""
                            }
                        }
                }
            }
            .font(.system(size: 14))
            .padding(10)
            .padding(.leading, 6)
            .background(Color(.systemGray6))
            .cornerRadius(20)
            .padding(.horizontal, 10)
            .onTapGesture {
                self.isEditing = true
            }
            Button("+ Create") {
                self.createAction()
            }
            .padding(.trailing, 10)
        }
    }
}

struct SpacesSearchHeaderView_Previews: PreviewProvider {
    static var previews: some View {
        SpacesSearchHeaderView(filterAction: {_ in }, createAction: { } )
    }
}

