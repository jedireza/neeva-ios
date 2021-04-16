//
//  SpacesSearchHeaderView.swift
//
//
//  Created by Stuart Allen on 21/03/21.
//

import SwiftUI
struct SpacesSearchHeaderView: View {
    @State private var isEditing = false
    @State private var searchText = ""
    @State private var isModal = false
    var filterAction: (String) -> ()
    let onCreateSpace: ((CreateSpaceMutation.Data, String) -> ())

    public init(filterAction: @escaping (String) -> (), onCreateSpace: @escaping ((CreateSpaceMutation.Data, String) -> ())) {
        self.onCreateSpace = onCreateSpace
        self.filterAction = filterAction
    }

    var body: some View {
        HStack {
            HStack {
                TextField("Search Spaces", text: $searchText)
                    .onChange(of: searchText) {
                        self.filterAction($0)
                    }
                if (self.isEditing) {
                    Image(systemName: "xmark.circle.fill")
                        .imageScale(.medium)
                        .foregroundColor(Color(.systemGray3))
                        .padding(3)
                        .onTapGesture {
                            withAnimation {
                                self.searchText = ""
                            }
                        }
                }
            }
            .font(.system(size: 14))
            .padding(10)
            .padding(.leading, 16)
            .background(Color(.systemGray6))
            .cornerRadius(20)
            .padding(.horizontal, 10)
            .onTapGesture {
                self.isEditing = true
            }
            Button("+ Create") {
                self.isModal = true
            }.sheet(isPresented: $isModal , content: {
                CreateSpaceView(onDismiss: { result, name in
                    self.isModal = false
                    if (result != nil) {
                        self.onCreateSpace(result!, name)

                    }
                })
            })
            .padding(.trailing, 10)
        }
    }
}

struct SpacesSearchHeaderView_Previews: PreviewProvider {
    static var previews: some View {
        SpacesSearchHeaderView(filterAction: {_ in }, onCreateSpace: {_,_  in } )
    }
}

