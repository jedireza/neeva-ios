//
//  Space.swift
//  
//
//  Created by Jed Fox on 12/18/20.
//

import SwiftUI

/// An entry in a space list
struct SpaceListItem: View {
    let space: SpaceListController.Space
    /// - Parameter space: the space to render
    init(_ space: SpaceListController.Space) {
        self.space = space
    }
    var body: some View {
        return HStack(spacing: 15) {
            LargeSpaceIconView(space: space)
            VStack(alignment: .leading, spacing: 10) {
                Text(space.space!.name ?? "")
                    .font(.headline)
                HStack(spacing: 0) {
                    let count = space.space!.resultCount ?? 0
                    Text("\(count) item\(count == 1 ? "" : "s")")
                    Text("·").accessibility(hidden: true).padding(.horizontal, 4)
                    if let formattedDate = format(space.space!.lastModifiedTs, as: .full) {
                        Text(formattedDate)
                    }
                }.foregroundColor(.secondary)
            }
        }.padding(.vertical)
    }
}

struct SpaceView_Previews: PreviewProvider {
    static var previews: some View {
        List {
            SpaceListItem(.savedForLater)
            SpaceListItem(.stackOverflow)
        }
    }
}
